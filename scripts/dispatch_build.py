#!/usr/bin/env python3
"""Dispatch and collect one exact builder run; never latest-build URLs."""
import argparse
import datetime
import hashlib
import re
import json
import os
from pathlib import Path
import time
import urllib.request
import urllib.error
from urllib.parse import quote
from dispatch_protocol import BUILDER_REPO, FIRMWARE_REPO, WORKFLOW, validate_request


def api(path, token, payload=None, raw=False):
    data = None if payload is None else json.dumps(payload).encode()
    req = urllib.request.Request("https://api.github.com/" + path, data=data, headers={"Authorization": "Bearer " + token, "Accept": "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28", "User-Agent": "NoobWRT-build-request"})
    class Redirect(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            result = super().redirect_request(req, fp, code, msg, headers, newurl)
            if result is not None:
                result.remove_header("Authorization")
            return result
    with urllib.request.build_opener(Redirect).open(req, timeout=60) as response:
        body = response.read()
    return body if raw else json.loads(body) if body else None


def find_run(runs, request, created):
    matches = [r for r in runs if r.get("display_title") == "external-" + request["request_id"] and r.get("event") == "workflow_dispatch" and r.get("head_sha") == request["builder_sha"] and r.get("created_at", "") >= created]
    if len(matches) > 1:
        raise ValueError("ambiguous builder runs")
    return matches[0] if matches else None


def wait_run(request, created, timeout, token, clock=time.monotonic, sleep=time.sleep, fetch=api):
    deadline = clock() + timeout
    while clock() < deadline:
        response = fetch("repos/" + BUILDER_REPO + "/actions/workflows/" + WORKFLOW + "/runs?event=workflow_dispatch&per_page=100", token)
        run = find_run(response["workflow_runs"], request, created)
        if run:
            if run["status"] == "completed":
                if run.get("conclusion") != "success":
                    raise RuntimeError("Builder failed: " + run["html_url"])
                return run
            print("Builder running: " + run["html_url"], flush=True)
        sleep(30)
    raise TimeoutError("Timed out awaiting exact builder run; inspect Actions before retrying")


def collect_receipt(run, request, token, fetch=api):
    """Actions job names are authenticated, run/attempt-bound API metadata.

    No Drive credential in caller; no artifact or log scraping. This is a builder
    readback attestation, NOT an independent caller download or signature.
    """
    attempt = run.get('run_attempt')
    if type(attempt) is not int or attempt <= 0 or type(run.get('id')) is not int:
        raise ValueError('invalid run/attempt identity')
    jobs = []
    for page in range(1, 11):
        response = fetch('repos/' + BUILDER_REPO + '/actions/runs/' + str(run['id']) +
                         '/attempts/' + str(attempt) + '/jobs?per_page=100&page=' + str(page), token)
        jobs.extend(response['jobs'])
        if len(jobs) >= response['total_count']:
            break
    else:
        raise ValueError('job list exceeds supported bounds')
    matches = [j for j in jobs if j.get('name', '').startswith('drive-v1:')]
    if len(matches) != 1:
        raise ValueError('missing or ambiguous Drive completion attestation')
    job = matches[0]
    if job.get('run_id') != run['id'] or job.get('run_attempt', attempt) != attempt or job.get('head_sha') != request['builder_sha'] or job.get('status') != 'completed' or job.get('conclusion') != 'success':
        raise ValueError('Drive receipt job identity/status mismatch')
    match = re.fullmatch(r'drive-v1:([0-9a-f]{64}):([0-9a-f]{64}):([0-9a-f]{64}):([A-Za-z0-9_-]{10,128})', job['name'])
    expected_hash = hashlib.sha256(json.dumps(request, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    if not match or match[1] != expected_hash:
        raise ValueError('Drive completion request checksum mismatch')
    return dict(folder_id=match[4], checksums_sha256=match[2], completion_sha256=match[3])


def request_from_env(builder_sha):
    def flag(key):
        value = os.environ[key]
        if value not in ("true", "false"):
            raise ValueError("invalid boolean " + key)
        return value == "true"
    return validate_request({"schema_version": 2, "build_tag": os.environ["BUILD_TAG"], "drive_root_id": os.environ["DRIVE_ROOT_FOLDER_ID"], "firmware_repository": FIRMWARE_REPO, "firmware_sha": os.environ["GITHUB_SHA"], "builder_sha": builder_sha, "request_id": "fw-" + os.environ["GITHUB_RUN_ID"] + "-" + os.environ["GITHUB_RUN_ATTEMPT"], "device": os.environ["DEVICE"], "variant": os.environ["VARIANT"], "validate_only": flag("VALIDATE_ONLY"), "clean": flag("CLEAN"), "verbose": flag("VERBOSE")})


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--timeout", type=int, default=18000)
    args = p.parse_args()
    if not 60 <= args.timeout <= 18600:
        raise ValueError("timeout outside supported bounds")
    if os.environ.get("GITHUB_REPOSITORY") != FIRMWARE_REPO or os.environ.get("GITHUB_REF") != "refs/heads/main":
        raise ValueError("official requests run only from firmware main")
    token = os.environ.get("BUILDER_TOKEN", "")
    if not token:
        raise ValueError("TOKEN secret missing: needs Actions write/read on builder")
    repo = api("repos/" + BUILDER_REPO, token)
    ref = repo["default_branch"]
    builder_sha = api("repos/" + BUILDER_REPO + "/commits/" + quote(ref, safe=""), token)["sha"]
    request = request_from_env(builder_sha)
    Path("request.json").write_text(json.dumps(request, indent=2))
    # If branch advances before dispatch, wrong head_sha is never accepted.
    created = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    api("repos/" + BUILDER_REPO + "/actions/workflows/" + WORKFLOW + "/dispatches", token, {"ref": ref, "inputs": {"request": json.dumps(request, separators=(",", ":")), "request_id": request["request_id"]}})
    run = wait_run(request, created, args.timeout, token)
    receipt = collect_receipt(run, request, token)
    with open(os.environ["GITHUB_OUTPUT"], "a") as f:
        print("request_id=" + request["request_id"], file=f)
        print("builder_run_id=" + str(run["id"]), file=f)
        print("builder_url=" + run["html_url"], file=f)
        print("drive_folder_id=" + receipt["folder_id"], file=f)
    with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as f:
        print("### Private Google Drive delivery" + chr(10) + "Builder readback attestation accepted from [exact run](" + run["html_url"] + ")." + chr(10) + "[Private folder](https://drive.google.com/drive/folders/" + receipt["folder_id"] + ")" + chr(10) + "Path: " + request["variant"] + "/" + request["build_tag"] + chr(10) + "Firmware commit: " + request["firmware_sha"] + chr(10) + "SHA256SUMS SHA-256: " + receipt["checksums_sha256"] + chr(10) + "COMPLETE.json SHA-256: " + receipt["completion_sha256"] + chr(10) + "Caller authenticated the builder attestation; it did not independently download Drive bytes.", file=f)


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as error:
        if error.code in (401, 403, 404):
            raise SystemExit("Builder API authentication/access failed (HTTP " + str(error.code) + "). Check repository secret TOKEN: valid builder-scoped token with Actions read/write and Contents read; org approval/SSO may also be required.") from None
        raise
