#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPPORT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="${1:-$(cd "${SUPPORT_ROOT}/.." && pwd)}"
MANIFEST_GZ_B64="${SUPPORT_ROOT}/manifests/pinned-default.xml.gz.base64"
TARGET_MANIFEST="${WORKSPACE_ROOT}/.repo/manifests/default.xml"

if [[ ! -d "${WORKSPACE_ROOT}/.repo" ]]; then
  echo "Expected an initialized repo workspace at: ${WORKSPACE_ROOT}" >&2
  exit 1
fi

if [[ ! -f "${MANIFEST_GZ_B64}" ]]; then
  echo "Missing pinned manifest archive: ${MANIFEST_GZ_B64}" >&2
  exit 1
fi

base64 -d "${MANIFEST_GZ_B64}" | gzip -dc > "${TARGET_MANIFEST}"
echo "Pinned manifest installed to ${TARGET_MANIFEST}"
echo "Run: repo sync -c --no-clone-bundle --no-tags -j\$(nproc)"
