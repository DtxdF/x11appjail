#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

. "${BASEDIR}/app.conf"

JAIL="${X11APPJAIL_JAIL:-${APPNAME}}"

DATADIR="${X11APPJAIL_DATADIR:-${HOME}/x11appjail/data/${JAIL}}"
CACHEDIR="${X11APPJAIL_CACHEDIR:-${HOME}/x11appjail/cache/${JAIL}}"
PKG_CACHEDIR="${CACHEDIR}/pkg"
OSVERSION="${X11APPJAIL_OSVERSION}"
VIRTUALNET="${X11APPJAIL_VIRTUALNET}"

mkdir -p -- "${DATADIR}" || exit $?
mkdir -p -- "${PKG_CACHEDIR}" || exit $?

set --
set -- -j "${JAIL}"
set -- "$@" -o x11
set -- "$@" -o copydir="${BASEDIR}/files"
set -- "$@" -o file="/etc/rc.conf.local"
set -- "$@" -o template="${BASEDIR}/template.conf"
set -- "$@" -o ephemeral
if [ -n "${VIRTUALNET}" ]; then
    set -- "$@" -o virtualnet="${VIRTUALNET}:<random> default"
    set -- "$@" -o nat
else
    set -- "$@" -o alias
    set -- "$@" -o ip4_inherit
    set -- "$@" -o ip6_inherit
fi
set -- "$@" -o fstab="${DATADIR} data <volumefs>"
set -- "$@" -o fstab="${PKG_CACHEDIR} /var/cache/pkg"
if [ -n "${OSVERSION}" ]; then
    set -- "$@" -o osversion="${OSVERSION}"
fi
if [ -n "${X11APPJAIL_LABEL0}" ]; then
    labels=`mktemp -d -t appscript` || exit $?
    index=0

    env | grep -Ee '^X11APPJAIL_LABEL[0-9]+=.*$' | while IFS= read -r env; do
        value=`printf "%s" "${env}" | cut -d= -f2-`

        printf "%s\n" "${value}" > "${labels}/${index}"

        index=$((index+1))
    done

    for label_file in "${labels}"/*; do
        label=`head -1 -- "${label_file}"` || exit $?

        set -- "$@" -o label="${label}"
    done

    rm -rf -- "${labels}"
    unset labels index label_file label
fi
if [ -f "${BASEDIR}/arguments.sh" ]; then
    . "${BASEDIR}/arguments.sh"
else
    set -- "$@" --
fi
set -- "$@" --puid "`id -u`"
set -- "$@" --pgid "`id -g`"

exec appjail makejail "$@"
