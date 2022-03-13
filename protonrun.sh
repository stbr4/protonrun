#!/bin/bash

set -u

USAGE="protonrun [ -v <protonversion> ] <prefix> <cmd> <windows binary>"

STEAM_ROOT=~/.steam
PROTON_VERSION=""


die() {
	echo "$*" >&2
	exit 1
}

while [ -n "${1:-}" ] && [ x"${1:0:1}" = "x-" ]; do

	opt="${1}"
	shift

	case "${opt}" in

	  -v)
		PROTON_VERSION="${1:-}"
		shift
		;;

	esac
done

[ $# -ge 3 ] || {
	die "${USAGE}"
}

PROTON_PREFIX="${1}"
shift

if [ -z "${PROTON_VERSION}" ]; then
	PROTON_VERSION="$(cat "${PROTON_PREFIX}/version")"
fi

PROTON_BIN=""

# find correct proton binary
for p in "${STEAM_ROOT}/steam/steamapps/common/Proton "*/proton; do
	if grep -q "CURRENT_PREFIX_VERSION=\"${PROTON_VERSION}\"" "$p"; then
		PROTON_BIN="$p"
		break
	fi
done

[ -n "${PROTON_BIN}" -a -x "${PROTON_BIN}" ] || {
	die "Proton Version '${PROTON_VERSION}' not found"
}


export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAM_ROOT}"
export STEAM_COMPAT_DATA_PATH="${PROTON_PREFIX}"

exec "${PROTON_BIN}" "$@"
