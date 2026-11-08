# Private Google Drive build delivery

## Run and find the files

On firmware main, open **Actions → Build Firmware → Run workflow**. Select the
device and variant, and enter a new **build_tag** (letters/digits, dots,
hyphens/underscores; start with a letter or digit; 1–80 characters, e.g.
v1.2.3, 25.12.5-rc1 or Release-AW1K_1.0). Start with validate_only=true and a
separate unused validation tag. This is a manually requested transport check,
not a public-repository test workflow. Full compilation uses validate_only=false.

All generated files are ordinary, individually downloadable Drive files:

    ROOT/
      passwall1/
        v2026-11-08-passwall1/
          images/
            <profile>-sysupgrade.bin
            <profile>-factory.ubi
          metadata/
            build.json
            profiles.json
            config
            sources.lock.json
            ...
          logs/
            build-<timestamp>-<id>.log
          result.json
          SHA256SUMS
          PENDING.json
          COMPLETE.json

The exact layout is **ROOT/<variant>/<build-tag>/**. There is no device folder,
ZIP, tarball, GitHub Actions artifact (including logs/validation proof), or
release upload in this build path. Image names/formats come from the selected
profile, not a hardcoded router or extension list. Open images/ for individual
firmware images. Metadata retains device, variant, target/subtarget/profile,
builder/firmware commits, OpenWrt/feed pins and image SHA-256 digests.
Validation deliveries contain result/checksums/logs/control files, not images.
Build summaries link the private folder; links do not grant access.

## One-time authentication prerequisites (operator controlled)

* In BOTH repositories set Actions variable **DRIVE_ROOT_FOLDER_ID** to the
  chosen existing private root folder ID. It is request-bound, checked against
  the builder variable, and must match the rclone remote root. No root is
  device-hardcoded. Different devices sharing a variant must use different tags.
* On your own PC configure maintained [rclone](https://rclone.org/drive/), remote
  name **noobwrt**, backend **drive**, normal personal Drive (no Shared Drive),
  own Desktop OAuth client, scope **drive**, and root_folder_id equal to ROOT.
  Scope drive.file cannot generally access a pre-existing web-created folder.
  Test with `rclone lsd noobwrt:`. Do not run copy/sync/link/public-sharing tests.
* Store ONLY the [noobwrt] section as private builder Actions secret
  **RCLONE_CONFIG**, preferably in its protected **firmware-build** environment.
  Accepted keys: type, client_id, client_secret, scope, token, root_folder_id,
  and optional empty team_drive. Never put OAuth config in chat, source, logs,
  the public caller, or an issue. Other remotes/extra settings are rejected.
* The workflow creates a unique temporary config file with mode 0600, removes
  the secret and all inherited RCLONE_* overrides from the subprocess environment, and deletes the config on normal
  success/failure. Rclone can refresh OAuth in that temporary file. Abrupt host
  loss/SIGKILL cannot guarantee cleanup: secure RUNNER_TEMP/host storage and
  rotate credentials after suspected compromise. No credentials enter Docker
  compilation or build logs. Provider diagnostics are suppressed, not echoed.
* The runner requires an operator-reviewed rclone installation on PATH. This
  change does not install software or alter the host. Validation fails before
  compilation if rclone is unavailable. Reserve sufficient temporary disk for
  payload plus a full downloaded readback (twice sequentially).
* Public firmware secret **TOKEN** must be valid and scoped ONLY to private
  NoobWRT/noobwrt-builder: Actions read/write, Contents read, Metadata read.
  It dispatches/inspects exact runs and reads job metadata; no Drive, Checks,
  release-write or callback credential is required in the caller. HTTP 401 is
  expired/invalid auth; 403/404 may require repository/org approval/SSO.

**root_folder_id is a path boundary, NOT an OAuth security boundary.** Scope
**drive** can access the account's other Drive data. Prefer a dedicated Google
account with only this folder shared to it as Editor. Keep the root and inherited
permissions private; the uploader never creates/changes sharing permissions.
GitHub environment/branch protection and trusted workflow writers remain required.

## Fail-closed publication and receipt

Schema-2 request fields are exactly schema_version, firmware_repository,
firmware_sha, builder_sha, request_id, device, variant, validate_only, clean,
verbose, build_tag and drive_root_id. Both repositories share identical
scripts/dispatch_protocol.py. Inputs use canonical full SHA/identifier/boolean
validation; subprocesses use argument arrays, not caller-controlled shell code.
The trusted repository allowlist is authorization, not device policy.

The builder verifies exact checked-out commits and origin/main ancestry. Full
build packaging verifies the complete local SHA256SUMS file set, engine commits,
device/variant and individual image digests. Delivery also checks target/profile
against the reviewed definition and exact profiles.json selected image set.
Output/log/result directories are unique under RUNNER_TEMP per job/attempt;
existing runner checkout output, legacy volumes and active builds are untouched.

The root must have ONE serialized publisher. The workflow retains global
external-firmware-runner concurrency with cancel-in-progress=false. Do not
publish from another repository/workflow/manual uploader to the same root while
it runs. Google Drive permits duplicate names and has no atomic create-if-absent
folder operation: rclone cannot supply a distributed lock. Under this explicit
single-writer contract the builder refuses every existing tag, including empty,
failed or partial folders. It checks duplicate paths/shortcuts and folder ID,
uses immutable copy with automatic retries disabled, and never delete/sync/
overwrite/resume operations. External simultaneous writers violate the contract;
this is not a claim of atomic multi-writer tag reservation.

PENDING.json is uploaded first. Payload files follow. The builder lists the
exact remote file set, downloads ALL remote bytes to a fresh temporary directory
using rclone, and computes SHA-256 for every file (including SHA256SUMS). No
size-only, provider-MD5-only, or upload-success-only verification is accepted.
Only after that passes is COMPLETE.json uploaded LAST. The entire final set,
including COMPLETE.json, is downloaded and SHA-256 checked again before emitting
an attestation. SHA256SUMS covers payload files; COMPLETE.json additionally binds
its digest and all payload hashes to the complete request, run ID/attempt,
folder ID, path and profile. Publication controls are not circularly self-hashed.
PENDING.json remains for history and does not negate a verified COMPLETE.json.

The successful receipt job has an authenticated Actions job name:

    drive-v1:<request-sha256>:<SHA256SUMS-sha256>:<COMPLETE-sha256>:<folder-id>

The caller selects only external-<request_id>, workflow_dispatch, the resolved
builder head SHA and request creation time, waits for success, and reads jobs
from THAT run's exact run_attempt via GitHub Actions API. It requires exactly one
successful receipt job with matching run ID/head SHA and full canonical request
hash. It rejects missing/ambiguous/malformed/wrong-request/failed receipts.
The exact ASCII job-name byte length is checked immediately after reserving the
Drive folder ID and BEFORE writing/uploading any files. An unusually long folder
ID that exceeds 255 bytes for the complete name fails closed and can leave only
an empty reserved folder (Drive generates the ID at folder creation); it never
uploads pending/payload/completion files. Never reuse that reserved tag.
Job metadata carries only a bounded completion attestation, not firmware/logs or
an Actions artifact. No broad Drive credential is added to the caller.

**Trust statement:** caller authenticates the trusted builder's downloaded-byte
verification attestation; caller does NOT independently download Drive data.
This has the existing trusted-builder/workflow-writer boundary, not a signature
or proof that firmware is safe to flash. For manual independent verification,
download files from the private folder and compare SHA256SUMS plus the
SHA256SUMS/COMPLETE digests displayed in the caller summary.

## Failure and rollout

A compile failure attempts to deliver logs and failed result/checksums to the
same unused tag, with failed/pending state and NO COMPLETE or success attestation.
Network/delivery failures can leave partial folders; never automatically delete,
resume, rerun, or reuse a tag. Pick a NEW tag only after inspecting the prior run.
A final readback failure can leave COMPLETE remotely but produces no successful
receipt: trust the exact successful run/attestation as well as the completion
file. The caller wait is bounded at 300 minutes (315-minute hosted job timeout).
The obsolete Jenkins-to-GitHub release workflow is removed; historical published
releases are untouched. No new public tests/validate workflow is introduced. Builder tests cover mocked
transport and caller protocol; real Drive and Actions job-name roundtrip remain
unproved until auth and an operator-reviewed rclone prerequisite are available.

Merge the paired protocol changes together only after review. First prove one
new validation tag, inspect private ACLs/files/checksums/receipt and collision
failure, then authorize one new full-build tag. Do not touch/retry an existing
full compilation just to test transport. Do not blindly retry on timeout.

References: [rclone Drive](https://rclone.org/drive/),
[immutable copy](https://rclone.org/commands/rclone_copy/),
[JSON inventory](https://rclone.org/commands/rclone_lsjson/).

The GitHub job metadata transport uses the documented
[workflow run attempt jobs API](https://docs.github.com/en/rest/actions/workflow-jobs#list-jobs-for-a-workflow-run-attempt).
