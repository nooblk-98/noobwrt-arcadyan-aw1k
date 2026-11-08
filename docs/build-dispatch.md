# Firmware builds across repositories

## Ownership

This repository owns firmware definitions, overlays, packages, source pins and
AW1000 hooks. NoobWRT/arcadyan-aw1000-builder owns the build engine and its
self-hosted runner. Generated images are Release assets, not tracked source.

## Run a build

On this repository's main branch open **Actions → Build Firmware → Run workflow**.
Choose device arcadyan-aw1000 and variant passwall2. Start with validate_only=true:
this proves request, reviewed-commit validation, result upload/download, provenance
and checksums without compiling or using the persistent runner.

For compilation set validate_only=false. Optional release_tag=vX.Y.Z creates a
**draft** release only after verification; existing releases/tags are never
clobbered. Leave it empty for an artifact-only build. Publishing the draft is a
separate maintainer decision. The legacy Jenkins release workflow is retained
until the migrated full-build path has been proved.

## Authentication (no new copied credentials)

The existing repository secret TOKEN is used only by the hosted request job.
It must have access to NoobWRT/arcadyan-aw1000-builder with **Actions: read and
write** (dispatch workflow, inspect runs, download artifacts), and Metadata: read.
For a classic PAT, private repository access may require repo; prefer a scoped
GitHub App installation token or a fine-grained PAT instead of broad credentials.
The current implementation does not create tokens, change the secret or assume
that the existing TOKEN has sufficient access. A 403/404 on dispatch is an
explicit authentication blocker, not a successful build. An organization may
require approving the fine-grained token or enabling SSO.

GITHUB_TOKEN remains contents:read during compilation; the separate draft-release
job gets contents:write only in this firmware repository. No callback secret is
needed in the builder. Fork PR validation receives no TOKEN and never schedules
the persistent runner.

## Request and verification protocol

The caller resolves the builder default branch to an exact SHA. It dispatches
external-build.yml with two inputs: request (schema-1 JSON) and request_id. The
request records firmware_repository, firmware_sha, builder_sha, request_id,
device, variant, validate_only, clean and verbose. Only the allowlisted firmware
repository and canonical SHA/identifier/boolean values are accepted.

The builder checks its own SHA and that the firmware commit is an ancestor of
origin/main, and that builder SHA is on origin/passwall2+stable. Validation runs
on a disposable GitHub-hosted runner without executing firmware hooks. Only
reviewed full builds proceed to the builder's existing self-hosted runner.

A unique run-name external-<request_id> binds the caller to the builder run.
The caller accepts only that exact workflow-dispatch run with matching head_sha
and creation time. It waits at most 260 minutes (275-minute job timeout), polls
at 30-second intervals, and fails on unsuccessful runs. Concurrent caller jobs
are serialized; the builder serializes external requests independently. If the
builder branch changes between SHA resolution and dispatch the request fails
closed. Do not retry blindly after a caller timeout; inspect the existing run.

Result artifact firmware-result-<request_id> contains result.json, SHA256SUMS,
images/ for full builds, and a metadata allowlist. The caller downloads from the
exact run, rejects zip traversal/symlinks/duplicates, checks every file checksum,
compares the complete request and builder run ID, and checks the engine's commit,
device, variant and image checksums before creating verified-firmware-<request_id>.
Checksums establish integrity and provenance consistency, not a cryptographic
signature or proof that arbitrary firmware is safe to flash.

## Persistent state and phone support

External builds use noobwrt-ext-src-<hash> and noobwrt-ext-ccache-<hash> volumes.
The hash includes builder SHA, device, variant and the definition tree, preventing
cross-router/configuration contamination. Legacy volumes are untouched. Builds
are capped at four compiler jobs to protect the shared host. Volume garbage
collection is a manual maintenance task: inspect usage; never globally prune.

Phone driver, daemon and LuCI app come from the feed. There is no copied RJ11
submodule in the external path. The device-owned hook currently still needs the
private stock SLIC tables; for AW1000 only the runner mounts
/home/lahiru/aw1000-rj11/private read-only at /private. Source tables and raw build
trees are never uploaded; the generated runtime SLIC patch is inside the firmware
image when enabled. Only an explicit image/metadata allowlist is packaged.

## Local checks

    python3 -m unittest discover -s tests -p 'test_dispatch*.py' -v
    bash ../builder/scripts/build-firmware.sh --firmware-dir "$PWD" --device arcadyan-aw1000 --variant passwall2 --validate-only

Firmware engine/definition contracts are documented in the builder's
external-firmware documentation. Keep scripts/dispatch_protocol.py and its tests
identical in both repositories when changing the request schema.
