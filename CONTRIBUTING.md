# Contributing firmware changes

Firmware source definitions live under firmware/devices/<device>/variants/<variant>/.
Start with arcadyan-aw1000/variants/passwall2. Edit files/ for filesystem defaults,
packages.json for package selection, kconfig for configuration and firmware.json
for pinned sources/feeds. Device hooks are reviewed executable code, not arbitrary
workflow inputs. Do not duplicate feed-owned packages in the builder repository.

1. Fork this repository and create a focused branch.
2. Explain the device/variant, expected behavior and rollback in your PR.
3. Preserve executable modes, licensing notices and upstream attribution.
4. Run the local validation command in docs/build-dispatch.md. JSON must be valid;
   paths must stay within the repository; no private keys, stock private tables,
   credentials, generated images or personal network settings may be committed.
5. Submit a PR targeting main. Hosted validation does not execute hooks or flash
   hardware. Maintainers review and merge before scheduling a trusted build.

Official builds are started from Actions → Build Firmware on main. Contributors
must not receive access to the persistent runner or build dispatch credentials.
A successful compile is not a router flash test: describe actual hardware testing
separately, including factory/sysupgrade image type and recovery method.

To add another router, create a new device definition with its own target,
subtarget, profile, compatible package set and overlays. To add another variant,
create a separate variant definition; do not copy a build workflow or change the
generic engine. PassWall1 is not yet migrated; its branch differs in more than
package names and requires a deliberate comparison.

License terms are unchanged by this migration. Do not remove or relicense
third-party code; discuss project licensing with the maintainer where needed.
