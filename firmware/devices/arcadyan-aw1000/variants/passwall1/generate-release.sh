#!/bin/bash
#=================================================
# Copyright (c) 2026 Lahiru S Liyanage (NoobLK) <liyanagelsofficial@gmail.com>
# GitHub: https://github.com/nooblk-98/wrt-builder-aw1000
# Telegram: @itsme_nooblk
# License: All rights reserved
#=================================================

set -e

usage() {
    echo "Usage: bash generate-release.sh <build.json> [output-dir]"
    echo ""
    echo "Generates release.md from a build.json metadata file."
    echo ""
    echo "Arguments:"
    echo "  build.json   Path to the build metadata JSON file"
    echo "  output-dir   Directory with firmware images (default: same dir as build.json)"
    echo ""
    echo "Example:"
    echo "  bash generate-release.sh output/2026-05-06_17-47/build.json"
    echo "  bash generate-release.sh output/2026-05-06_17-47/build.json output/2026-05-06_17-47"
    exit 1
}

BUILD_JSON="${1:?Missing build.json path}"
RUN_OUTPUT="${2:-$(dirname "$BUILD_JSON")}"
RELEASE_MD="$RUN_OUTPUT/release.md"

if [ ! -f "$BUILD_JSON" ]; then
    echo "ERROR: build.json not found at $BUILD_JSON"
    exit 1
fi

# Collect firmware image filenames and sizes
IMG_DATA=()
while IFS= read -r -d '' f; do
    name=$(basename "$f")
    size=$(stat -c%s "$f" 2>/dev/null || echo 0)
    IMG_DATA+=("{\"name\":\"$name\",\"size\":$size}")
done < <(find "$RUN_OUTPUT" -maxdepth 1 \( -name "*.bin" -o -name "*.itb" -o -name "*.ubi" \) ! -name "*initramfs-uImage*" -print0 2>/dev/null)

IMG_JSON="[]"
if [ ${#IMG_DATA[@]} -gt 0 ]; then
    IMG_JSON=$(printf '%s\n' "${IMG_DATA[@]}" | jq -s .)
fi

# Find sysupgrade image filename for upgrade instructions
SYSIMG=$(find "$RUN_OUTPUT" -maxdepth 1 -name "*sysupgrade*" -print -quit 2>/dev/null || true)
SYSIMG_NAME=$(basename "$SYSIMG" 2>/dev/null || echo "")

# Extract version info
BRANCH_VER=$(jq -r '.openwrt.version // (.openwrt.branch | sub("^openwrt-";""))' "$BUILD_JSON")

jq -r --argjson imgs "$IMG_JSON" --arg bver "$BRANCH_VER" --arg sysimg "$SYSIMG_NAME" '
  (.build_date | sub("_"; " ") | .[:13] + ":" + .[14:]) as $date |
  .target.name as $target | .target.subtarget as $subtarget |
  .target.profile as $profile | .kernel as $kernel |
  .openwrt.branch as $ow_branch | .openwrt.commit as $ow_commit |
  ($imgs | map(
    (.name | split(".")) as $parts |
    ($parts[-1]) as $ext |
    (if .name | index("factory") then "factory"
     elif .name | index("sysupgrade") then "sysupgrade"
     elif .name | index("initramfs") then "initramfs"
     else "firmware" end) as $type |
    (.size | if . >= 1073741824 then (. / 1073741824 | floor | tostring) + " GB"
             elif . >= 1048576 then (. / 1048576 | floor | tostring) + " MB"
             else (. / 1024 | floor | tostring) + " KB" end) as $size |
    "| `\(.name)` | \($bver) | .\($ext) (\($type)) | \($size) | APK | Qmodem |"
  ) | join("\n")) as $img_table |
  (if $sysimg != "" then
    "## Upgrade\n\n" +
    "To flash the sysupgrade image via SSH:\n\n" +
    "```bash\n" +
    "scp \($sysimg) root@192.168.1.1:/tmp/\n" +
    "ssh root@192.168.1.1 sysupgrade -n /tmp/\($sysimg)\n" +
    "```"
   else "" end) as $upgrade_section |
  "| | |\n|---|---|\n" +
  "| **Build date** | \($date) |\n" +
  "| **Target** | \($target) / \($subtarget) |\n" +
  "| **Profile** | \($profile) |\n" +
  "| **Kernel** | \($kernel) |\n" +
  "| **OpenWrt** | \($ow_branch) (@\($ow_commit)) |\n\n" +
  "## ⚠️ Warning\n\n" +
  "Flashing the **Pro firmware** requires an **overlay partition of at least 120 MB**.\n\n" +
  "If your router has **less than 120 MB available**, **do not flash this build**.\n" +
  "Using it on a smaller overlay partition will likely cause the router to enter a **boot loop**.\n\n" +
  "## Requirement\n\n" +
  "* Minimum overlay partition size: **120 MB**\n\n" +
  "## Important\n\n" +
  "Please verify your available overlay size before upgrading.\n" +
  "If the requirement is not met, stay on NoobWRT Lite firmware or resize/repartition first.\n\n" +
  "## Firmware Images\n\n" +
  "**First-time install:** Use the **factory** image (`.ubi`).\n\n" +
  "**Upgrading an existing installation:** Use the **sysupgrade** image (`.bin`).\n\n" +
  "| Firmware | Version | Type | Size | Format | Modem |\n" +
  "|---|---|---|---|---|---|\n" +
  $img_table + "\n\n" +
  ($upgrade_section | if . != "" then . + "\n\n" else "" end) +
  "---\n\n" +
  "## Acknowledgement\n\n" +
  "This firmware is compiled by **Lahiru Sandaruwan ([NoobLK](https://www.linkedin.com/in/lahiru-sandaruwan-liyanage/))**\n\n" +
  "It is provided **free of charge** and is **open source**. You are **not permitted to sell** this firmware or any derivative of it. It was built for the community and must remain free.\n\n" +
  "If you find this project useful, do not forget to [star this project](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k) on GitHub!\n"
' "$BUILD_JSON" > "$RELEASE_MD"

echo "Release notes generated: $RELEASE_MD"
