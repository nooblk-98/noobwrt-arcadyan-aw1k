import hashlib
import json
from pathlib import Path
import stat
import sys
import tempfile
import unittest
import zipfile

SCRIPTS = Path(__file__).resolve().parents[1] / 'scripts'
sys.path.insert(0, str(SCRIPTS))
import dispatch_protocol as protocol
try:
    import dispatch_build as client
except ImportError:
    client = None


def request(**kwargs):
    value = dict(schema_version=1, firmware_repository=protocol.FIRMWARE_REPO,
                 firmware_sha='a' * 40, builder_sha='b' * 40, request_id='fw-123-1',
                 device='arcadyan-aw1000', variant='passwall2',
                 validate_only=True, clean=False, verbose=False)
    value.update(kwargs)
    return value


class ProtocolTests(unittest.TestCase):
    def test_valid_request(self):
        self.assertEqual(protocol.validate_request(request()), request())

    def test_reject_request_injection(self):
        for field, value in [('device', '../bad'), ('variant', 'x;id'),
                             ('request_id', 'x' + chr(10) + 'injected=true'),
                             ('builder_sha', 'main'), ('firmware_repository', 'attacker/repo'),
                             ('clean', 'false'), ('schema_version', True)]:
            with self.subTest(field=field), self.assertRaises(ValueError):
                protocol.validate_request(request(**{field: value}))
        with self.assertRaises(ValueError):
            protocol.validate_request(request(extra='anything'))

    def test_validation_artifact_roundtrip(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'request.json').write_text(json.dumps(request()))
            protocol.package_result(root / 'request.json', root / 'result', root, 123)
            self.assertEqual(protocol.verify_result(root / 'result', request())['status'], 'validated')

    def test_wrong_commit_and_tampering_fail(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'request.json').write_text(json.dumps(request()))
            protocol.package_result(root / 'request.json', root / 'result', root, 123)
            with self.assertRaises(ValueError):
                protocol.verify_result(root / 'result', request(firmware_sha='c' * 40))
            (root / 'result' / 'unlisted').write_text('unexpected')
            with self.assertRaises(ValueError):
                protocol.verify_result(root / 'result', request())

    def test_no_images_full_build_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'request.json').write_text(json.dumps(request(validate_only=False)))
            with self.assertRaises(ValueError):
                protocol.package_result(root / 'request.json', root / 'result', root / 'output', 123)

    def test_zip_traversal_and_symlink_fail(self):
        for name in ['../outside', '/absolute', 'a/../../outside', 'a\\b', 'a//b']:
            with self.subTest(name=name), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                with zipfile.ZipFile(root / 'bad.zip', 'w') as z:
                    z.writestr(name, 'bad')
                with self.assertRaises(ValueError):
                    protocol.safe_extract(root / 'bad.zip', root / 'out')
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            with zipfile.ZipFile(root / 'bad.zip', 'w') as z:
                info = zipfile.ZipInfo('link')
                info.external_attr = (stat.S_IFLNK | 0o777) << 16
                z.writestr(info, '/etc/passwd')
            with self.assertRaises(ValueError):
                protocol.safe_extract(root / 'bad.zip', root / 'out')

    def test_full_build_checks_engine_provenance(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            output = root / "output"
            output.mkdir()
            r = request(validate_only=False)
            (root / "request.json").write_text(json.dumps(r))
            (output / "router.bin").write_bytes(b"firmware")
            metadata = dict(firmware_commit=r["firmware_sha"], builder_commit=r["builder_sha"], device=r["device"], variant=r["variant"], images=[dict(name="router.bin", sha256=hashlib.sha256(b"firmware").hexdigest())])
            (output / "build.json").write_text(json.dumps(metadata))
            protocol.package_result(root / "request.json", root / "result", output, 123)
            self.assertEqual(protocol.verify_result(root / "result", r)["status"], "built")
            metadata["firmware_commit"] = "c" * 40
            (output / "build.json").write_text(json.dumps(metadata))
            with self.assertRaises(ValueError):
                protocol.package_result(root / "request.json", root / "bad-result", output, 123)

    def test_zip_roundtrip(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            with zipfile.ZipFile(root / 'good.zip', 'w') as z:
                z.writestr('metadata/build.json', '{}')
            protocol.safe_extract(root / 'good.zip', root / 'out')
            self.assertEqual((root / 'out/metadata/build.json').read_text(), '{}')

    @unittest.skipIf(client is None, 'caller-only tests')
    def test_exact_run_selection(self):
        r = dict(display_title='external-fw-123-1', event='workflow_dispatch', head_sha='b' * 40, created_at='2026-11-08T03:00:00Z')
        self.assertEqual(client.find_run([r], request(), '2026-11-08T02:00:00Z'), r)
        for field, value in [('head_sha', 'c' * 40), ('display_title', 'external-fw-999-1'), ('event', 'pull_request')]:
            self.assertIsNone(client.find_run([dict(r, **{field: value})], request(), '2026-11-08T02:00:00Z'))
        with self.assertRaises(ValueError):
            client.find_run([r, r], request(), '2026-11-08T02:00:00Z')

    @unittest.skipIf(client is None, 'caller-only tests')
    def test_poll_timeout(self):
        tick = [0]
        def clock():
            return tick[0]
        def sleep(seconds):
            tick[0] += seconds
        with self.assertRaises(TimeoutError):
            client.wait_run(request(), '2026-11-08T02:00:00Z', 60, '', clock=clock, sleep=sleep, fetch=lambda *a: {'workflow_runs': []})
        self.assertEqual(tick[0], 60)


if __name__ == '__main__':
    unittest.main()
