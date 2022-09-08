#!/bin/bash

set -u

USAGE="protonrun [ -v <protonversion> ] [ -p <proton binary> ] <prefix> <cmd> <windows binary>"

HELP="${USAGE}

# Create a new prefix

 1. Create prefix directory:
    \$ mkdir ~/gamepfx

 2. Initialize prefix:
    \$ protonrun -p ~/.steam/steam/steamapps/common/Proton\\ 6.3/proton \\
       ~/gamepfx run notepad

 3. Install the game:
    \$ protonrun ~/gamepfx run ~/Downloads/game_installer.exe

 4. Launch the game:
    \$ protonrun ~/gamepfx run C:/game/gamelauncher.exe
"


STEAM_ROOT=~/.steam
PROTON_VERSION=""
PROTON_BIN=""


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

	  -p)
		PROTON_BIN="${1:-}"
		shift
		;;

	  -h|--help)
		echo "${HELP}"
		exit 0
		;;

	esac
done

[ $# -ge 3 ] || {
	die "${USAGE}"
}

PROTON_PREFIX="$( realpath -e -- "${1}" )" || die
shift

if [ -z "${PROTON_BIN}" ]; then

	if [ -z "${PROTON_VERSION}" ]; then
		PROTON_VERSION="$(cat "${PROTON_PREFIX}/version")"
	fi

	# find correct proton binary
	for p in "${STEAM_ROOT}/steam/steamapps/common/Proton "*/proton; do
		if grep -q "CURRENT_PREFIX_VERSION=\"${PROTON_VERSION}\"" "$p"; then
			PROTON_BIN="$p"
			break
		fi
	done

fi

[ -n "${PROTON_BIN}" -a -x "${PROTON_BIN}" ] || {
	die "Proton Version '${PROTON_VERSION}' not found"
}


export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAM_ROOT}"
export STEAM_COMPAT_DATA_PATH="${PROTON_PREFIX}"

exec "${PROTON_BIN}" "$@"
