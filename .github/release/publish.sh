#!/usr/bin/env bash
set -euo pipefail
if [[ ! "${RELEASE_TAG:-}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo 'Expected a stable release tag' >&2
  exit 1
fi
shopt -s nullglob
files=(dist/*)
packages=()
for file in "${files[@]}"; do
  if [[ "${file##*/}" != SHA256SUMS.txt ]]; then packages+=("$file"); fi
done
(( ${#packages[@]} == 6 )) && test -s dist/SHA256SUMS.txt
(cd dist && sha256sum --check SHA256SUMS.txt)
make_latest=true
if latest=$(gh release view --json tagName --jq '.tagName' 2>/dev/null); then
  highest=$(printf '%s\n%s\n' "$latest" "$RELEASE_TAG" | sort -V | tail -n 1)
  if [[ "$highest" != "$RELEASE_TAG" || "$latest" == "$RELEASE_TAG" ]]; then make_latest=false; fi
fi
published=$(mktemp -d)
trap 'rm -rf "$published"' EXIT
if ! gh release view "$RELEASE_TAG" --json assets,isDraft > "$published/release.json"; then
  gh release create "$RELEASE_TAG" "${files[@]}" --verify-tag --generate-notes --latest="$make_latest"
  exit 0
fi
existing=$(jq -r '.assets[].name' "$published/release.json")
draft=$(jq -r '.isDraft' "$published/release.json")
upload=()
# Preserve every existing installer byte-for-byte, even if a rebuild differs.
for file in "${packages[@]}"; do
  name=${file##*/}
  if grep -Fxq -- "$name" <<< "$existing"; then
    gh release download "$RELEASE_TAG" --pattern "$name" --dir "$published"
    cp "$published/$name" "$file"
  else
    upload+=("$file")
  fi
done
if grep -Fxq SHA256SUMS.txt <<< "$existing"; then
  gh release download "$RELEASE_TAG" --pattern SHA256SUMS.txt --dir "$published"
  # An existing checksum contract is immutable too. A mismatched rebuild must
  # fail, rather than replace a missing package with bytes that violate it.
  printf '%s\n' "${packages[@]##*/}" | sort > "$published/expected-names"
  awk '{print $2}' "$published/SHA256SUMS.txt" | sort > "$published/checksum-names"
  diff -u "$published/expected-names" "$published/checksum-names"
  (cd dist && sha256sum --check "$published/SHA256SUMS.txt")
else
  # Resume an empty/partial release. Hash original published files together with
  # new missing packages, then publish the first complete checksum manifest.
  (cd dist && sha256sum "${packages[@]##*/}") > dist/SHA256SUMS.txt
  upload+=(dist/SHA256SUMS.txt)
fi
if (( ${#upload[@]} )); then gh release upload "$RELEASE_TAG" "${upload[@]}"; fi
if [[ "$draft" == true ]]; then
  gh release edit "$RELEASE_TAG" --draft=false --latest="$make_latest"
fi
