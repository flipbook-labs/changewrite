#!/usr/bin/env bash

# Put the changewrite binary on disk and export CHANGEWRITE_BIN for later steps.
# Shared by the composite actions (root and publish-lock) so the bootstrap lives
# in one place. Locates changewrite.toml relative to itself, not via
# $GITHUB_ACTION_PATH, so it works from any action's subdirectory.
set -euo pipefail

# A caller can pre-set CHANGEWRITE_BIN to run their own binary rather than a
# release download. Changewrite's own CI uses this to dogfood the branch build.
# Consumers leave it unset and get the release below.
if [[ -n "${CHANGEWRITE_BIN:-}" ]]; then
	echo "Using preset changewrite binary: $CHANGEWRITE_BIN"
	exit 0
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
version="$(sed -n 's/^current = "\(.*\)"/\1/p' "$script_dir/../changewrite.toml")"
if [[ -z "$version" ]]; then
	echo "Failed to parse version from changewrite.toml"
	exit 1
fi

case "${RUNNER_OS}/${RUNNER_ARCH}" in
	Linux/X64)
		zip="changewrite-linux-x86_64.zip"
		bin="changewrite"
		;;
	macOS/ARM64)
		zip="changewrite-macos-arm64.zip"
		bin="changewrite"
		;;
	Windows/X64)
		zip="changewrite-windows-x86_64.zip"
		bin="changewrite.exe"
		;;
	*)
		echo "Unsupported platform: ${RUNNER_OS}/${RUNNER_ARCH}"
		exit 1
		;;
esac

tmp="$(mktemp -d)"
if ! gh release download "v${version}" \
	--repo flipbook-labs/changewrite \
	--pattern "$zip" \
	--dir "$tmp"; then
	echo "::warning::Could not download the binary for v${version}; falling back to the latest release. This is expected on the publish PR, which bumps the version before its release exists. Otherwise, check that the version in changewrite.toml has a published release."
	gh release download \
		--repo flipbook-labs/changewrite \
		--pattern "$zip" \
		--dir "$tmp"
fi

unzip -q "$tmp/$zip" "$bin" -d "$tmp"
[[ "$RUNNER_OS" != "Windows" ]] && chmod +x "$tmp/$bin"

echo "CHANGEWRITE_BIN=$tmp/$bin" >> "$GITHUB_ENV"
