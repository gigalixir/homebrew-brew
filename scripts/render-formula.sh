#!/usr/bin/env bash
#
# render-formula.sh -- render Formula/gigalixir.rb from the live distribution
# surface: https://get.gigalixir.com/cli/VERSION names the promoted version,
# and cli/v<X.Y.Z>/checksums.txt carries a sha256 per platform. Both are
# public and unauthenticated, so this script needs no credential.
#
# Run by .github/workflows/update-formula.yml on workflow_dispatch; safe to
# run locally too (it only reads the network and writes
# Formula/gigalixir.rb -- it does not commit).
#
# TARGET_VERSION (required, bare X.Y.Z): the version to render. The script
# waits for cli/VERSION to serve exactly that version and renders it, and
# never renders any other. There is no "render whatever is served" mode: a
# read of cli/VERSION can be stale, and nothing on this side can tell, so
# every caller names the version it wants.

set -euo pipefail

BASE_URL="${GIGALIXIR_DOWNLOADS_BASE:-https://get.gigalixir.com}"

# The CDN in front of cli/VERSION keeps a copy for 60s per edge and may serve
# one more stale copy while it revalidates; a quiet edge can serve that stale
# copy long after the 60s, and a cache-busting query string or Cache-Control
# request header does not get around it. So a read can return an old version,
# which is why the version is always named and waited for, never taken from
# whatever is served. 300s covers the usual revalidation with margin for a
# slow edge, and still fails well inside the job's own timeout when the
# version never arrives. The overrides exist so a test need not wait minutes.
TARGET_VERSION="${TARGET_VERSION:-}"
VERSION_WAIT_SECONDS="${VERSION_WAIT_SECONDS:-300}"
VERSION_POLL_SECONDS="${VERSION_POLL_SECONDS:-10}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="${ROOT_DIR}/Formula/gigalixir.rb.template"
OUT="${ROOT_DIR}/Formula/gigalixir.rb"

# Platforms this formula installs a binary for. Homebrew does not run on
# Windows, so windows-amd64/windows-arm64 are expected in checksums.txt but
# deliberately absent here.
FORMULA_PLATFORMS=(darwin-amd64 darwin-arm64 linux-amd64 linux-arm64)

# Every platform this CLI's release process can produce today. If that
# build matrix ever changes, checksums.txt gains or drops an entry outside
# this list and the "unrecognised platform" check below fails the run
# loudly, instead of quietly shipping a formula that never picked up the
# new platform.
KNOWN_PLATFORMS=(darwin-amd64 darwin-arm64 linux-amd64 linux-arm64 windows-amd64 windows-arm64)

log() { printf '==> %s\n' "$*" >&2; }
err() { printf 'error: %s\n' "$*" >&2; exit 1; }

is_known() {
    local needle="$1" p
    for p in "${KNOWN_PLATFORMS[@]}"; do
        [[ "$p" == "$needle" ]] && return 0
    done
    return 1
}

[[ -n "$TARGET_VERSION" ]] || err "TARGET_VERSION is not set; name the version to render, as a bare X.Y.Z"
[[ "$TARGET_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
    || err "version '${TARGET_VERSION}' is not a bare X.Y.Z (no leading v)"

# The version is fixed before the loop and never reassigned from what is
# served, so nothing the CDN returns can change which version is rendered.
version="$TARGET_VERSION"
deadline=$((SECONDS + VERSION_WAIT_SECONDS))
last="nothing (no fetch has succeeded yet)"
while :; do
    if served="$(curl -fsSL --max-time 20 "${BASE_URL}/cli/VERSION")"; then
        last="'${served:0:40}'"
        [[ "$served" == "$version" ]] && break
    else
        last="a failed fetch"
    fi
    (( SECONDS < deadline )) \
        || err "waited ${VERSION_WAIT_SECONDS}s for ${BASE_URL}/cli/VERSION to serve '${version}'; last saw ${last}"
    log "cli/VERSION read gave ${last}; waiting for '${version}'"
    sleep "$VERSION_POLL_SECONDS"
done

log "current version is ${version}"

checksums="$(curl -fsSL "${BASE_URL}/cli/v${version}/checksums.txt")"
[[ -n "$checksums" ]] || err "checksums.txt for v${version} came back empty"

declare -A sha256_for
while read -r sha name; do
    [[ -n "$name" ]] || continue
    platform="${name#gigalixir-}"
    platform="${platform%.exe}"
    if ! is_known "$platform"; then
        err "checksums.txt names an unrecognised platform '${platform}' (from '${name}')" \
            "-- the upstream build matrix changed; update KNOWN_PLATFORMS and," \
            "if Homebrew should serve it, FORMULA_PLATFORMS and" \
            "Formula/gigalixir.rb.template in the same change."
    fi
    sha256_for["$platform"]="$sha"
done <<<"$checksums"

for platform in "${FORMULA_PLATFORMS[@]}"; do
    [[ -n "${sha256_for[$platform]:-}" ]] || err "checksums.txt is missing ${platform}, which the formula needs"
done

log "rendering ${OUT}"
sed \
    -e "s/@@VERSION@@/${version}/g" \
    -e "s/@@SHA_DARWIN_ARM64@@/${sha256_for[darwin-arm64]}/g" \
    -e "s/@@SHA_DARWIN_AMD64@@/${sha256_for[darwin-amd64]}/g" \
    -e "s/@@SHA_LINUX_ARM64@@/${sha256_for[linux-arm64]}/g" \
    -e "s/@@SHA_LINUX_AMD64@@/${sha256_for[linux-amd64]}/g" \
    "$TEMPLATE" >"$OUT"

# For the workflow to name the version in its commit message without
# re-parsing the rendered formula.
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    printf 'version=%s\n' "$version" >>"$GITHUB_OUTPUT"
fi

log "done"
