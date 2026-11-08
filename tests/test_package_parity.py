import json
from pathlib import Path
import re
import unittest

BASE = Path(__file__).resolve().parents[1] / 'firmware/devices/arcadyan-aw1000/variants/passwall2'


class MigrationParityTests(unittest.TestCase):
    def test_legacy_package_selection_preserved(self):
        text = (BASE / 'src/packages.conf').read_text()
        def names(name):
            body = re.search(r'^' + name + r'=[(](.*?)^[)]', text, re.S | re.M).group(1)
            return [line.split('#', 1)[0].strip() for line in body.splitlines() if line.split('#', 1)[0].strip()]
        packages = json.loads((BASE / 'packages.json').read_text())
        self.assertEqual(set(packages['add']), set(names('ADD_PKGS')) | {'luci-app-fxs'})
        self.assertEqual(set(packages['remove']), set(names('REMOVE_PKGS')))
        self.assertEqual(len(packages['add']), len(set(packages['add'])))


if __name__ == '__main__':
    unittest.main()
