#!/usr/bin/env bash
set -euo pipefail

VERSION="${SOCAT_VERSION:-1.8.1.1}"
ROOT="$(pwd)"
ARCHIVE="socat-${VERSION}.tar.gz"
SOURCE_DIR="socat-${VERSION}"
DIST_ROOT="${ROOT}/dist"
PACKAGE_NAME="socat-${VERSION}-cygwin-x86_64"
PACKAGE_DIR="${DIST_ROOT}/${PACKAGE_NAME}"

rm -rf "${SOURCE_DIR}" "${DIST_ROOT}" "${ROOT}/socat-version.txt"

tar -xzf "${ARCHIVE}"
cd "${SOURCE_DIR}"

chmod +x configure install-sh ./*.sh 2>/dev/null || true

./configure --enable-default-ipv=4
make -j"$(nproc)"

SOCAT_BIN="./socat.exe"
if [[ ! -f "${SOCAT_BIN}" && -f "./socat" ]]; then
  SOCAT_BIN="./socat"
fi

"${SOCAT_BIN}" -V | tee "${ROOT}/socat-version.txt"

mkdir -p "${PACKAGE_DIR}"
install -m 0755 "${SOCAT_BIN}" "${PACKAGE_DIR}/socat.exe"

for tool in filan procan; do
  if [[ -f "./${tool}.exe" ]]; then
    install -m 0755 "./${tool}.exe" "${PACKAGE_DIR}/${tool}.exe"
  elif [[ -f "./${tool}" ]]; then
    install -m 0755 "./${tool}" "${PACKAGE_DIR}/${tool}.exe"
  fi
done

while IFS= read -r dll; do
  dll="${dll#"${dll%%[![:space:]]*}"}"
  [[ "${dll}" == *.dll ]] || continue

  unix_path="$(cygpath -u "${dll}" 2>/dev/null || true)"
  base="$(basename "${unix_path}")"
  if [[ -f "${unix_path}" && "${base}" == cyg*.dll ]]; then
    cp -n "${unix_path}" "${PACKAGE_DIR}/"
  fi
done < <(cygcheck "${SOCAT_BIN}")

cp -f COPYING COPYING.OpenSSL README CHANGES EXAMPLES FAQ "${PACKAGE_DIR}/" 2>/dev/null || true
cp -rf doc "${PACKAGE_DIR}/doc"

cat > "${PACKAGE_DIR}/README-WINDOWS.txt" <<EOF
socat ${VERSION} for Windows (Cygwin x86_64)

Run from Command Prompt or PowerShell:
  .\\socat.exe -V

Keep the included cyg*.dll files next to socat.exe.
Built by GitHub Actions from socat-${VERSION}.tar.gz.
EOF

cd "${DIST_ROOT}"
zip -9 -r "${PACKAGE_NAME}.zip" "${PACKAGE_NAME}"
