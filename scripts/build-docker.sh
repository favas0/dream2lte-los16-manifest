#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPPORT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="${1:-$(cd "${SUPPORT_ROOT}/.." && pwd)}"
JOBS="${JOBS:-20}"
TARGET="${TARGET:-lineage_dream2lte-userdebug}"
OUT_DIR_REL="${OUT_DIR_REL:-out-docker}"
IMAGE="${IMAGE:-lineage16-buildenv:latest}"

if [[ ! -f "${WORKSPACE_ROOT}/build/envsetup.sh" ]]; then
  echo "Expected Android source tree at: ${WORKSPACE_ROOT}" >&2
  exit 1
fi

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/tmp \
  -e OUT_DIR="/src/${OUT_DIR_REL}" \
  -v "${WORKSPACE_ROOT}:/src" \
  -w /src \
  "${IMAGE}" \
  bash -lc "source build/envsetup.sh >/dev/null && lunch ${TARGET} >/dev/null && m bacon -j${JOBS}"
