# NoobWRT {{VERSION}}

| | |
|---|---|
| **Build date** | {{BUILD_DATE}} |
| **Target** | {{TARGET}} / {{SUBTARGET}} |
| **Profile** | {{PROFILE}} |
| **Kernel** | {{KERNEL}} |
| **OpenWrt** | {{OPENWRT_BRANCH}} (@{{OPENWRT_COMMIT}}) |

## ⚠️ Warning

Flashing the **Pro firmware** requires an **overlay partition of at least 120 MB**.

If your router has **less than 120 MB available**, **do not flash this build**.
Using it on a smaller overlay partition will likely cause the router to enter a **boot loop**.

## Requirement

- Minimum overlay partition size: **120 MB**

## Important

Please verify your available overlay size before upgrading.
If the requirement is not met, stay on NoobWRT Lite firmware or resize/repartition first.

## Firmware Images

| Firmware | Version | Type | Format | Features |
|---|---|---|---|---|
{{IMAGE_TABLE}}

## Changelog

{{CHANGELOG}}

## Included LuCI Packages

{{LUCI_PACKAGES}}

---

**Images:** {{IMAGE_COUNT}} firmware file(s)
