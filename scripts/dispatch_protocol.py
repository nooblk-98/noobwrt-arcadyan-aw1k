#!/usr/bin/env python3
"""Fail-closed request and result protocol. Standard library only."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import zipfile

FIRMWARE_REPO = "nooblk-98/noobwrt-arcadyan-aw1k"
BUILDER_REPO = "NoobWRT/arcadyan-aw1000-builder"
WORKFLOW = "external-build.yml"
SHA = re.compile(r"^[0-9a-f]{40}$")
ID = re.compile(r"^[a-z0-9][a-z0-9-]{0,63}$")
REQUEST = re.compile(r"^[a-z0-9][a-z0-9-]{0,95}$")
KEYS = {"schema_version", "firmware_repository", "firmware_sha", "builder_sha", "request_id", "device", "variant", "validate_only", "clean", "verbose"}


def validate_request(value):
    if not isinstance(value, dict) or set(value) != KEYS:
        raise ValueError("request has missing or unknown fields")
    if value["schema_version"] != 1 or type(value["schema_version"]) is not int:
        raise ValueError("unsupported request schema")
    if value["firmware_repository"] != FIRMWARE_REPO:
        raise ValueError("unapproved firmware repository")
    for key in ("firmware_sha", "builder_sha"):
        if not isinstance(value[key], str) or not SHA.fullmatch(value[key]):
            raise ValueError("invalid " + key)
    for key in ("device", "variant"):
        if not isinstance(value[key], str) or not ID.fullmatch(value[key]):
            raise ValueError("invalid " + key)
    if not isinstance(value["request_id"], str) or not REQUEST.fullmatch(value["request_id"]):
        raise ValueError("invalid request ID")
    for key in ("validate_only", "clean", "verbose"):
        if type(value[key]) is not bool:
            raise ValueError("expected boolean " + key)
    return value


def read_request(path):
    return validate_request(json.loads(Path(path).read_text()))


def safe_relative(name):
    p = PurePosixPath(name)
    if not name or "\\" in name or p.is_absolute() or any(x in ("..", ".") for x in p.parts):
        raise ValueError("unsafe artifact path")
    if str(p) != name or any(ord(x) < 32 for x in name):
        raise ValueError("non-canonical artifact path")
    return p


def safe_extract(archive, destination):
    destination = Path(destination)
    destination.mkdir(parents=True, exist_ok=False)
    with zipfile.ZipFile(archive) as z:
        seen = set()
        total = 0
        for info in z.infolist():
            name = info.filename.rstrip("/")
            p = safe_relative(name)
            mode = info.external_attr >> 16
            if stat.S_ISLNK(mode) or name in seen or info.flag_bits & 1:
                raise ValueError("unsupported or duplicate artifact member")
            seen.add(name)
            total += info.file_size
            if total > 4 * 1024**3 or len(seen) > 4096:
                raise ValueError("artifact exceeds limits")
            target = destination.joinpath(*p.parts)
            if info.is_dir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                with z.open(info) as source, target.open("xb") as out:
                    shutil.copyfileobj(source, out)


def checksum_files(root):
    result = {}
    for p in sorted(root.rglob("*")):
        if p.is_symlink():
            raise ValueError("symlink in result")
        if p.is_file() and p.relative_to(root).as_posix() != "SHA256SUMS":
            result[p.relative_to(root).as_posix()] = hashlib.sha256(p.read_bytes()).hexdigest()
    return result


def verify_result(root, expected):
    root = Path(root)
    manifest = json.loads((root / "result.json").read_text())
    if manifest.get("schema_version") != 1 or manifest.get("request") != expected:
        raise ValueError("result provenance does not match request")
    if manifest.get("status") != ("validated" if expected["validate_only"] else "built"):
        raise ValueError("unexpected result mode/status")
    if not isinstance(manifest.get("builder_run_id"), int) or manifest["builder_run_id"] <= 0:
        raise ValueError("invalid builder run ID")
    actual = checksum_files(root)
    declared = {}
    for line in (root / "SHA256SUMS").read_text().splitlines():
        digest, sep, name = line.partition("  ")
        safe_relative(name)
        if not sep or not re.fullmatch(r"[0-9a-f]{64}", digest) or name in declared or name == "SHA256SUMS":
            raise ValueError("invalid checksum manifest")
        declared[name] = digest
    if not actual or declared != actual:
        raise ValueError("artifact checksum set/content mismatch")
    images = [p for p in (root / "images").glob("*") if p.is_file()] if (root / "images").is_dir() else []
    if not expected["validate_only"]:
        if not images:
            raise ValueError("full build has no images")
        build = json.loads((root / "metadata" / "build.json").read_text())
        for key, expected_value in {"firmware_commit": expected["firmware_sha"], "builder_commit": expected["builder_sha"], "device": expected["device"], "variant": expected["variant"]}.items():
            if build.get(key) != expected_value:
                raise ValueError("engine provenance mismatch: " + key)
        engine_images = {item["name"]: item["sha256"] for item in build["images"]}
        if engine_images != {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in images}:
            raise ValueError("engine image manifest mismatch")
    return manifest


def git(*args, cwd):
    return subprocess.check_output(["git", *args], cwd=cwd, text=True).strip()


def verify_checkout(path, sha, branch):
    if git("rev-parse", "HEAD", cwd=path) != sha:
        raise ValueError("checked out commit mismatch")
    subprocess.run(["git", "merge-base", "--is-ancestor", sha, "origin/" + branch], cwd=path, check=True)


def package_result(request_path, destination, output, builder_run_id):
    request = read_request(request_path)
    root = Path(destination)
    root.mkdir(parents=True, exist_ok=False)
    images = root / "images"
    if not request["validate_only"]:
        images.mkdir()
        if any(p.is_symlink() for p in Path(output).rglob("*")):
            raise ValueError("symlink in build output")
        manifests = list(Path(output).rglob("build.json"))
        if len(manifests) != 1:
            raise ValueError("missing or ambiguous engine build metadata")
        engine = json.loads(manifests[0].read_text())
        declared_images = engine.get("images", [])
        if not declared_images:
            raise ValueError("build completed without firmware images")
        for item in declared_images:
            name = item.get("name", "")
            safe_relative(name)
            if PurePosixPath(name).name != name:
                raise ValueError("engine image must have a plain filename")
            p = manifests[0].parent / name
            if not p.is_file() or p.is_symlink() or (images / name).exists():
                raise ValueError("missing, symlinked or duplicate engine image")
            shutil.copyfile(p, images / name)
        metadata = root / "metadata"
        metadata.mkdir()
        for p in sorted(Path(output).rglob("*")):
            if p.is_file() and (p.name in {"build.json", "release.md", "config", "sources.lock.json", "profiles.json", "config.buildinfo", "feeds.buildinfo", "version.buildinfo"} or p.suffix == ".manifest"):
                if (metadata / p.name).exists():
                    raise ValueError("ambiguous build metadata")
                shutil.copyfile(p, metadata / p.name)
    result = {"schema_version": 1, "request": request, "builder_run_id": int(builder_run_id), "status": "validated" if request["validate_only"] else "built"}
    (root / "result.json").write_text(json.dumps(result, indent=2) + chr(10))
    checksums = checksum_files(root)
    (root / "SHA256SUMS").write_text("".join(d + "  " + n + chr(10) for n, d in checksums.items()))
    verify_result(root, request)


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="command", required=True)
    a = sub.add_parser("validate")
    a.add_argument("request")
    a.add_argument("--firmware-dir", required=True)
    a.add_argument("--builder-dir", required=True)
    a = sub.add_parser("package")
    a.add_argument("request")
    a.add_argument("destination")
    a.add_argument("--output", default="output")
    a.add_argument("--run-id", required=True)
    a = sub.add_parser("extract")
    a.add_argument("archive")
    a.add_argument("destination")
    a.add_argument("request")
    a.add_argument("--run-id", required=True, type=int)
    args = p.parse_args()
    if args.command == "validate":
        r = read_request(args.request)
        verify_checkout(args.firmware_dir, r["firmware_sha"], "main")
        verify_checkout(args.builder_dir, r["builder_sha"], "passwall2+stable")
    elif args.command == "package":
        package_result(args.request, args.destination, args.output, args.run_id)
    else:
        safe_extract(args.archive, args.destination)
        result = verify_result(args.destination, read_request(args.request))
        if result["builder_run_id"] != args.run_id:
            raise ValueError("wrong builder run")


if __name__ == "__main__":
    main()
