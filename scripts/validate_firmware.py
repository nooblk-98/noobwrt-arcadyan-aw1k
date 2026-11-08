#!/usr/bin/env python3
"""Validate public firmware definitions without builder access or executing hooks.

Schema version 1; keep validation rules aligned with the builder.
"""
import argparse
import json
from pathlib import Path
import re

ID = re.compile(r"^[a-z0-9][a-z0-9_-]{0,79}$")
SHA = re.compile(r"^[0-9a-f]{40}$")
PACKAGE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9+_.-]*$")


def safe_path(root, value, directory=False):
    if not isinstance(value, str) or not value or Path(value).is_absolute() or '..' in Path(value).parts:
        raise ValueError(f"invalid relative definition path: {value!r}")
    path = root / value
    if not path.resolve().is_relative_to(root.resolve()) or not path.exists():
        raise ValueError(f"missing or escaping definition path: {value}")
    for part in [path, *path.parents]:
        if part == root:
            break
        if part.is_symlink():
            raise ValueError(f"symlink in definition path: {value}")
    if directory:
        if not path.is_dir():
            raise ValueError(f"not a directory: {value}")
        if any(p.is_symlink() for p in path.rglob('*')):
            raise ValueError(f"symlink in overlay: {value}")
    elif not path.is_file():
        raise ValueError(f"not a file: {value}")
    return path


def load_definition(root, device, variant):
    if not ID.fullmatch(device) or not ID.fullmatch(variant):
        raise ValueError('invalid device or variant ID')
    descriptor = safe_path(root, f'firmware/devices/{device}/variants/{variant}/firmware.json')
    d = json.loads(descriptor.read_text())
    required = {'schema_version', 'device', 'variant', 'target', 'subtarget', 'profile', 'source', 'feeds', 'packages', 'kconfig', 'overlays', 'hooks', 'version', 'allowed_missing_packages'}
    if not isinstance(d, dict) or set(d) != required or type(d['schema_version']) is not int or d['schema_version'] != 1:
        raise ValueError('unsupported manifest schema or fields')
    if d['device'] != device or d['variant'] != variant:
        raise ValueError('manifest identity mismatch')
    for k in ['target', 'subtarget', 'profile']:
        if not isinstance(d[k], str) or not ID.fullmatch(d[k]):
            raise ValueError(f'invalid {k}')
    if not isinstance(d['version'], str) or not re.fullmatch(r'[A-Za-z0-9.+_-]+', d['version']):
        raise ValueError('invalid version')
    def source(s):
        if not isinstance(s, dict) or set(s) != {'url', 'commit'} or not isinstance(s['url'], str) or not isinstance(s['commit'], str) or not re.fullmatch(r'https://[A-Za-z0-9./_-]+', s['url']) or not SHA.fullmatch(s['commit']):
            raise ValueError('source must be HTTPS and pinned to a full commit SHA')
    source(d['source'])
    if not isinstance(d['feeds'], dict) or not d['feeds']:
        raise ValueError('feeds must be nonempty object')
    for name, s in d['feeds'].items():
        if not ID.fullmatch(name):
            raise ValueError('invalid feed name')
        source(s)
    p = json.loads(safe_path(root, d['packages']).read_text())
    if not isinstance(p, dict) or set(p) != {'add', 'remove'} or any(not isinstance(p[k], list) for k in p) or not isinstance(d['allowed_missing_packages'], list):
        raise ValueError('invalid package lists')
    for name in p['add'] + p['remove'] + d['allowed_missing_packages']:
        if not isinstance(name, str) or not PACKAGE.fullmatch(name):
            raise ValueError('invalid package name')
    if set(p['add']) & set(p['remove']):
        raise ValueError('package both added and removed')
    kconfig = safe_path(root, d['kconfig'])
    if any(not re.fullmatch(r'(CONFIG_[A-Za-z0-9_+-]+=(?:y|m|n|[0-9]+|"[^"\n]*")|#.*)?', line) for line in kconfig.read_text().splitlines()):
        raise ValueError('invalid Kconfig line')
    if not isinstance(d['overlays'], list) or not d['overlays']:
        raise ValueError('overlays must be nonempty list')
    for overlay in d['overlays']:
        safe_path(root, overlay, directory=True)
    if not isinstance(d['hooks'], dict) or set(d['hooks']) - {'prepare', 'configure', 'overlay', 'release'}:
        raise ValueError('invalid hook phases')
    for value in d['hooks'].values():
        safe_path(root, value)
    return d, p



def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path, nargs="?", default=Path("."))
    args = parser.parse_args()
    root = args.root.resolve()
    manifests = sorted((root / "firmware/devices").glob("*/variants/*/firmware.json"))
    if not manifests:
        raise ValueError("no firmware definitions")
    for manifest in manifests:
        device, variant = manifest.parts[-4], manifest.parts[-2]
        load_definition(root, device, variant)
        print("Valid: " + device + " / " + variant)


if __name__ == "__main__":
    main()
