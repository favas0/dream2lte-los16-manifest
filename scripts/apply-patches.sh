#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUPPORT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="${1:-$(cd "${SUPPORT_ROOT}/.." && pwd)}"

am_patch() {
  local project_path="$1"
  local patch_path="$2"
  echo "Applying am patch to ${project_path}: ${patch_path}"
  git -C "${WORKSPACE_ROOT}/${project_path}" am -3 "${SUPPORT_ROOT}/${patch_path}"
}

apply_diff() {
  local project_path="$1"
  local patch_path="$2"
  echo "Applying diff to ${project_path}: ${patch_path}"
  git -C "${WORKSPACE_ROOT}/${project_path}" apply --3way "${SUPPORT_ROOT}/${patch_path}"
}

if [[ ! -d "${WORKSPACE_ROOT}/.repo" ]]; then
  echo "Expected an Android repo workspace at: ${WORKSPACE_ROOT}" >&2
  exit 1
fi

am_patch "frameworks/av" "patches/frameworks/av/0001-clearkey-build-fix.patch"
am_patch "frameworks/opt/telephony" "patches/frameworks/opt/telephony/0001-sec-radio-callback-bridge.patch"
apply_diff "build/make" "patches/build/make/0001-python-compat.diff"
apply_diff "external/clang" "patches/external/clang/0001-python-compat.diff"
apply_diff "vendor/samsung/universal8895-common" \
  "patches/vendor/samsung/universal8895-common/0001-keep-stock-ril-packaging.diff"
apply_diff "device/samsung/universal8895-common" \
  "patches/device/samsung/universal8895-common/0001-rilc-log-level.diff"
am_patch "kernel/samsung/universal8895" \
  "patches/kernel/samsung/universal8895/0001-arm64-configs-enable-core-Halium-LXC-support.patch"

echo "All local patches applied."
