import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'firmware/devices/arcadyan-aw1000/variants/passwall1'
sys.path.insert(0, str(ROOT / 'scripts'))
from validate_firmware import load_definition


class PassWall1Tests(unittest.TestCase):
    def test_definition_and_variant_isolation(self):
        definition, packages = load_definition(ROOT, 'arcadyan-aw1000', 'passwall1')
        self.assertIn('luci-app-passwall', packages['add'])
        self.assertNotIn('luci-app-passwall2', packages['add'])
        self.assertIn('luci-app-fxs', packages['add'])
        for path in [definition['packages'], definition['kconfig'], *definition['overlays'], *definition['hooks'].values()]:
            self.assertIn('/variants/passwall1/', path)

    def test_complete_legacy_package_selection(self):
        text = (BASE / 'src/packages.conf').read_text()
        def names(name):
            body = re.search('^' + name + r'=[(](.*?)^[)]', text, re.S | re.M).group(1)
            return [line.split('#', 1)[0].strip() for line in body.splitlines() if line.split('#', 1)[0].strip()]
        packages = json.loads((BASE / 'packages.json').read_text())
        self.assertEqual(set(packages['add']), set(names('ADD_PKGS')) | {'luci-app-fxs'})
        self.assertEqual(set(packages['remove']), set(names('REMOVE_PKGS')))
        self.assertEqual(len(packages['add']), 143)
        self.assertEqual(len(packages['add']), len(set(packages['add'])))

    def test_overlay_bytes_and_git_modes(self):
        baseline = json.loads((BASE / 'overlay-baseline.json').read_text())
        self.assertEqual(baseline['source_commit'], '5316950f953eb7a3ee46b46efd059e30403585ff')
        actual = {}
        for path in (BASE / 'files').rglob('*'):
            if path.is_file():
                actual[path.relative_to(BASE / 'files').as_posix()] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=0o755 if path.stat().st_mode & 0o111 else 0o644)
        self.assertEqual(actual, baseline['files'])
        self.assertEqual(len(actual), 49)
        self.assertIn('etc/uci-defaults/84-luci-passwall', actual)
        self.assertIn('etc/uci-defaults/84a-passwall-fragment-fix', actual)
        self.assertNotIn('etc/uci-defaults/84-luci-passwall2', actual)

    def test_xray_pin_is_enforced_even_with_matching_version(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'feeds/packages/net/xray-core/Makefile'
            path.parent.mkdir(parents=True)
            path.write_text('PKG_VERSION:=25.12.8' + chr(10) + 'PKG_HASH:=wrong' + chr(10))
            subprocess.run(['bash', str(BASE / 'hooks/pins.sh')], env=dict(os.environ, BUILD_DIR=tmp), check=True, capture_output=True, text=True)
            text = path.read_text()
            self.assertIn('PKG_VERSION:=25.12.8', text)
            self.assertIn('PKG_HASH:=d4519b2d9bb1871f4d7612aa7a8db1c451573b5a44ac824219bb44d63f404e61', text)

    def test_passwall1_immutable_release_without_v2_overrides(self):
        prepare = (BASE / 'hooks/prepare.sh').read_text()
        self.assertIn('0d24d8fc24d9eb508a4df599a0a4d673c8a35cc7', prepare)
        self.assertIn('https://github.com/Openwrt-Passwall/openwrt-passwall.git', prepare)
        self.assertNotIn('openwrt-passwall2.git', prepare)
        self.assertNotIn('GOLANG_FEED_COMMIT', prepare)
        self.assertNotIn('TAILSCALE_VERSION', prepare)

    def test_missing_private_input_fails_before_fetch(self):
        with tempfile.TemporaryDirectory() as tmp:
            result = subprocess.run(['bash', str(BASE / 'hooks/prepare.sh')], env=dict(os.environ, BUILD_DIR=tmp, RJ11_PRIVATE_DIR=tmp), capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('FXS requires private', result.stderr)


if __name__ == '__main__':
    unittest.main()
