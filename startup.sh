#!/bin/sh

DEPENDENCIES="appjail su-exec xauth xdotool Xephyr xseticon git xev"
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

EXEC_TOOL="${X11APPJAIL_EXEC_TOOL:-doas}"

if [ -n "${MISSING}" ]; then
    "${EXEC_TOOL}" pkg install -y ${MISSING} || exit $?
fi

if ! appjail status -q "${X11APPJAIL_JAIL}" > /dev/null 2>&1; then
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

    ./create.sh || exit $?

    if [ -n "${X11APPJAIL_ALLOW_HOST}" ]; then
        X11_DISPLAY=`appjail x11 "${X11APPJAIL_JAIL}" assign_only` || exit $?

        xauth add localhost:${X11_DISPLAY} MIT-MAGIC-COOKIE-1 $(openssl rand -hex 16) || exit $?
    fi
fi

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
