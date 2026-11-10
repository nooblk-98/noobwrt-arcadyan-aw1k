---
name: release
description: Write NoobWRT firmware release notes (pre-release, rebuild, or final) with the shared layout, then publish them to the GitHub release. Any agent preparing a NoobWRT release uses this so every release looks the same.
---

# NoobWRT release notes

Every NoobWRT release, pre-release and rebuild uses the same body layout. Fill the template
`templates/release-notes.md` next to this file; never invent a layout and never drop a section that
still describes the image.

## Steps

1. Collect the facts from the build, not from memory:
   - `metadata/build.json` and `metadata/openwrt-<target>-<profile>.manifest` for each variant
     (kernel, OpenWrt version, `firmware_commit`, `builder_commit`, package versions).
   - Image file names and byte sizes, plus SHA-256 for every image.
   - The successful workflow run ids and artifact tags.
   - `git log --oneline <previous-release-commit>..<commit>` for what actually changed.
2. Copy `templates/release-notes.md` and replace every `{{PLACEHOLDER}}`.
3. Publish with `gh release edit <tag> --repo <owner>/<repo> --notes-file <file>`
   (or `gh release create ... --notes-file <file>` for a new release).
4. Verify the body landed and nothing is left unfilled:
   ```sh
   gh release view <tag> --repo <owner>/<repo> --json body -q .body | grep -c '{{'   # must print 0
   ```

## Content rules

- Fill every value from the build metadata or `gh`/`git` output. Never invent a version, size,
  hash, run id, commit, or date.
- Keep the section order: Build Info, What's New, Included package versions, Firmware Images,
  Installation, Build Provenance, Checksums.
- Add a `### <topic>` subsection under What's New for each real change, written as behaviour the
  user gets, not as commit titles. Keep subsections that still describe the image.
- Keep the 120 MB overlay warning and the `sha256sum --ignore-missing -c SHA256SUMS` snippet in
  every Pro release; they are safety-critical.
- Keep the variant guidance (PassWall 1 vs PassWall 2) and the Xray-core warning unless the
  variant split changes.
- Removing an existing section needs an explicit reason from the maintainer.
- Only the `sysupgrade` images are attached to an AW1000 release. Factory `.ubi` and initramfs
  `.itb` stay on Google Drive; link the Drive files instead of uploading them.
- State plainly when images were not flash-tested.

## Package versions

Read the table from the package database inside each image (the `.manifest` file), not from the
feed or the definition. Use `—` when a variant does not ship a package.

## Rewrite triggers

Rewrite the body when the release assets change: a rebuild, a variant change, a package swap, or a
new commit on the branch. Leave `BUILD-INFO.json` (when present) as the machine-readable record of
the commit and per-asset hashes.
