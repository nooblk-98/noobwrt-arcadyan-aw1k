#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
bash "$HERE/generate-release.sh" "$BUILD_JSON" "$RUN_OUTPUT"
