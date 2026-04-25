#!/bin/sh

if [ -n "${X11APPJAIL_DEBUG}" ]; then
    set -x
fi

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

# Need to define to empty value because a user or another process can
# define it as environment variable.
LINUX_VERSION=

. "${BASEDIR}/app.conf"
. "${BASEDIR}/default.conf"

DEPENDENCIES="appjail su-exec xauth xdotool Xephyr xseticon git xev"

if [ -n "${LINUX_VERSION}" ]; then
    DEPENDENCIES="${DEPENDENCIES} debootstrap"
fi

MISSING=

for dependency in ${DEPENDENCIES}; do
    if ! which -s "${dependency}"; then
        # Package name is different than binary name.
        if [ "${dependency}" = "Xephyr" ]; then
            dependency="xephyr"
        elif [ "${dependency}" = "git" ]; then
            dependency="git-tiny"
        fi

        MISSING="${MISSING} ${dependency}"
    fi
done

if [ -n "${MISSING}" ]; then
    "${X11APPJAIL_EXEC_TOOL}" pkg install -y ${MISSING} || exit $?
fi

if [ -n "${LINUX_VERSION}" -a -n "${X11APPJAIL_OCI_FROM}" ]; then
    echo "${0##*/}: cannot use an OCI image with this AppScript" >&2
    exit 1
fi

CHECKSUM=`sha256 -q -- "${APPSCRIPT_SCRIPT:-/dev/null}"` || exit $?

while :; do
    appjail status -q "${X11APPJAIL_JAIL}" > /dev/null 2>&1

    ERRLEVEL=$?

    if [ ${ERRLEVEL} -gt 1 ]; then
        if [ -n "${LINUX_VERSION}" ]; then
            appjail fetch debootstrap "${LINUX_VERSION}" || exit $?
            export X11APPJAIL_OSVERSION="${LINUX_VERSION}"
        else
            if [ -z "${X11APPJAIL_OCI_FROM}" ]; then
                if [ `uname -K` -lt 1500000 ]; then
                    if [ -z "${X11APPJAIL_OSVERSION}" ]; then
                        X11APPJAIL_OSVERSION=`freebsd-version | grep -Eo '[0-9]+\.[0-9]+-[a-zA-Z0-9]+'` || exit $?
                        export X11APPJAIL_OSVERSION
                    fi

                    appjail fetch www -v "${X11APPJAIL_OSVERSION}" || exit $?
                else
                    if [ -z "${X11APPJAIL_OSVERSION}" ]; then
                        freebsd_version=`freebsd-version -k` || exit $?
                        X11APPJAIL_OSVERSION=`printf "%s" "${freebsd_version}" | grep -Eo '^[0-9]+'` || exit $?
                        export X11APPJAIL_OSVERSION
                    fi

                    appjail fetch pkgbase -v "${X11APPJAIL_OSVERSION}" || exit $?
                fi

                env PAGER=cat appjail update release -v "${X11APPJAIL_OSVERSION}" || exit $?
            else
                unset X11APPJAIL_OSVERSION
            fi
        fi

        ./create.sh || exit $?

        if [ -n "${X11APPJAIL_ALLOW_HOST}" ]; then
            X11_DISPLAY=`appjail x11 "${X11APPJAIL_JAIL}" assign_only` || exit $?

            xauth add localhost:${X11_DISPLAY} MIT-MAGIC-COOKIE-1 $(openssl rand -hex 16) || exit $?
        fi

        appjail label add "${X11APPJAIL_JAIL}" "x11appjail.checksum" "${CHECKSUM}" || exit $?

        break
    elif [ ${ERRLEVEL} -eq 1 ]; then
        _CHECKSUM=`appjail label get -l "x11appjail.checksum" "${X11APPJAIL_JAIL}" value 2> /dev/null`

        if [ -z "${_CHECKSUM}" ] || [ "${CHECKSUM}" != "${_CHECKSUM}" ]; then
            appjail jail destroy -Rf "${X11APPJAIL_JAIL}" > /dev/null 2>&1
            continue
        fi

        appjail start "${X11APPJAIL_JAIL}" || exit $?

        # If jail is ephemeral, it could be destroyed at this point.
        appjail status -q "${X11APPJAIL_JAIL}" > /dev/null 2>&1

        if [ $? -gt 1 ]; then
            # Assuming the jail has been destroyed.
            continue
        fi

        break
    else
        _CHECKSUM=`appjail label get -l "x11appjail.checksum" "${X11APPJAIL_JAIL}" value 2> /dev/null`

        if [ -z "${_CHECKSUM}" ] || [ "${CHECKSUM}" != "${_CHECKSUM}" ]; then
            appjail stop "${X11APPJAIL_JAIL}"
            appjail jail destroy -Rf "${X11APPJAIL_JAIL}" > /dev/null 2>&1
            continue
        fi
    fi

    break
done

if [ -z "${X11APPJAIL_INSTALL}" ]; then
    XEPHYR_PID=`appjail jail list -HI -j "${X11APPJAIL_JAIL}" xephyr_pid` || exit $?

    if [ -z "${XEPHYR_PID}" ]; then
        ./start-server.sh &
        sleep 1

        while :; do
            XEPHYR_PID=`appjail jail list -HI -j "${X11APPJAIL_JAIL}" xephyr_pid` || exit $?

            if [ -n "${XEPHYR_PID}" ]; then
                break
            fi

            sleep 1 || exit $?
        done
    fi
fi
