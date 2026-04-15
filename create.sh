#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

# See startup.sh.
LINUX_VERSION=
NO_EPHEMERAL=

. "${BASEDIR}/app.conf"
. "${BASEDIR}/default.conf"

NO_EPHEMERAL="${NO_EPHEMERAL:-${X11APPJAIL_NO_EPHEMERAL}}"

mkdir -p -- "${X11APPJAIL_DATADIR}" || exit $?

set --
set -- -j "${X11APPJAIL_JAIL}"
set -- "$@" -o x11
set -- "$@" -o template="${BASEDIR}/template.conf"
if [ -z "${NO_EPHEMERAL}" ]; then
    set -- "$@" -o ephemeral
fi
if [ -z "${LINUX_VERSION}" ] && [ -n "${X11APPJAIL_VIRTUALNET}" ]; then
    set -- "$@" -o virtualnet="${X11APPJAIL_VIRTUALNET}:<random> default"
    set -- "$@" -o nat
else
    set -- "$@" -o alias
    set -- "$@" -o ip4_inherit
    set -- "$@" -o ip6_inherit
fi
set -- "$@" -o fstab="${X11APPJAIL_DATADIR} data <volumefs>"
if [ -n "${LINUX_VERSION}" ]; then
    ARCHIVES_CACHEDIR="${X11APPJAIL_CACHEDIR}/archives"
    LISTS_CACHEDIR="${X11APPJAIL_CACHEDIR}/lists"

    mkdir -p -- "${ARCHIVES_CACHEDIR}" || exit $?
    mkdir -p -- "${LISTS_CACHEDIR}" || exit $?

    set -- "$@" -o fstab="${ARCHIVES_CACHEDIR} /var/cache/apt/archives"
    set -- "$@" -o fstab="${LISTS_CACHEDIR} /var/lib/apt/lists"
    set -- "$@" -o type="linux+debootstrap"
else
    PKG_CACHEDIR="${X11APPJAIL_CACHEDIR}/pkg"

    mkdir -p -- "${PKG_CACHEDIR}" || exit $?

    set -- "$@" -o fstab="${PKG_CACHEDIR} /var/cache/pkg"
    set -- "$@" -o copydir="${BASEDIR}/files"
    set -- "$@" -o file="/etc/rc.conf.local"
fi
if [ -n "${X11APPJAIL_OSVERSION}" ]; then
    set -- "$@" -o osversion="${X11APPJAIL_OSVERSION}"
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
if [ -z "${LINUX_VERSION}" ] && [ -n "${X11APPJAIL_PKG_CONF}" ]; then
    set -- "$@" --pkg_conf "${X11APPJAIL_PKG_CONF}"
fi

exec appjail makejail "$@"
