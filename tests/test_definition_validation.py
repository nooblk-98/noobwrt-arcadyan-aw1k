import copy
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
from validate_firmware import load_definition


class PublicValidationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        shutil.copytree(ROOT / 'firmware', self.root / 'firmware')
        self.manifest = self.root / 'firmware/devices/arcadyan-aw1000/variants/passwall2/firmware.json'
        self.data = json.loads(self.manifest.read_text())

    def tearDown(self):
        self.tmp.cleanup()

    def validate(self):
        return load_definition(self.root, 'arcadyan-aw1000', 'passwall2')

    def test_definition(self):
        definition, packages = self.validate()
        self.assertIn('luci-app-passwall2', packages['add'])
        self.assertIn('dnsmasq-full', packages['add'])
        self.assertIn('wpad-mbedtls', packages['add'])
        self.assertIn('luci-app-fxs', packages['add'])

    def test_escaping_paths(self):
        for value in ('../outside', '/etc/passwd'):
            with self.subTest(value=value):
                changed = copy.deepcopy(self.data)
                changed['packages'] = value
                self.manifest.write_text(json.dumps(changed))
                with self.assertRaises(ValueError):
                    self.validate()

    def test_symlink_overlay(self):
        (self.root / self.data['overlays'][0] / 'escape').symlink_to('/etc/passwd')
        with self.assertRaises(ValueError):
            self.validate()

    def test_unpinned_source(self):
        self.data['source']['commit'] = 'main'
        self.manifest.write_text(json.dumps(self.data))
        with self.assertRaises(ValueError):
            self.validate()

    def test_validation_never_executes_hooks(self):
        hook = self.root / self.data['hooks']['prepare']
        hook.write_text('exit 99')
        self.validate()


if __name__ == '__main__':
    unittest.main()
