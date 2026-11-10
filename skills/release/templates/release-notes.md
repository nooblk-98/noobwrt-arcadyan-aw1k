<!--
NoobWRT release-notes template.
Fill every {{PLACEHOLDER}} from build metadata, never delete a section, table row, or bullet.
Publish with: gh release edit <TAG> --repo <owner>/<repo> --notes-file <file>
-->

## Build Info

| | |
|---|---|
| **Build date** | {{BUILD_DATE}} |
| **Target** | {{TARGET}} |
| **Profile** | {{PROFILE}} |
| **OpenWrt** | {{OPENWRT_VERSION}} |
| **Kernel** | {{KERNEL_VERSION}} |
| **Package manager** | {{PACKAGE_MANAGER}} |
| **Firmware commit** | [`{{COMMIT_SHORT}}`]({{COMMIT_URL}}) |

## What's New

{{WHATS_NEW_INTRO}}

<!-- One "### <topic>" subsection per meaningful change, written as behaviour.
     Keep subsections that still describe the image. -->

{{WHATS_NEW_SECTIONS}}

### Package updates

{{PACKAGE_UPDATES}}

### Commits in this build

{{COMMIT_LIST}}

## Included package versions

Read from the package databases inside the firmware images:

| Package | {{VARIANT_1_LABEL}} | {{VARIANT_2_LABEL}} |
|---|---|---|
{{PACKAGE_TABLE}}

## Firmware Images

For an existing installation, use the matching **sysupgrade** image.

| Image | Variant | Size |
|---|---|---|
{{IMAGE_TABLE}}

{{VARIANT_GUIDANCE}}

{{DRIVE_NOTE}}

### Installation

The Pro firmware requires an **overlay partition of at least 120 MB**. Less than 120 MB can boot
loop — resize or repartition before flashing. Back up settings first
(**System → Backup / Flash Firmware**), upload the matching image via LuCI, and refresh or clear the
browser cache after upgrading. To verify a download:

```sh
sha256sum --ignore-missing -c SHA256SUMS
```

## Build Provenance

| Variant | Successful build | Builder commit | Artifact tag |
|---|---|---|---|
{{PROVENANCE_TABLE}}

{{PROVENANCE_NOTE}}

## Checksums

{{CHECKSUMS_SCOPE}}

```
{{CHECKSUMS}}
```

---

{{RELEASE_FOOTER}}
