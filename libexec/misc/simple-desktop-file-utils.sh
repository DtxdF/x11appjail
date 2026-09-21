#!/bin/sh
#
# Copyright (c) 2026, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e -o pipefail

UID=`id -u`
GID=`id -g`

load_common()
{
    local _s
    _s=`which x11appjail` || exit ${EX_SOFTWARE}
    _s=`dirname -- "${_s}"` || exit ${EX_SOFTWARE}
    _s="${_s}/../lib/x11appjail"

    LIBDIR="${_s}"

    . "${LIBDIR}/common"
}

usage()
{
    err "usage: simple-desktop-file-utils.sh <appname> [I|U]"
}

load_common

APPNAME="$1"
PHASE="$2"

if [ -z "${APPNAME}" -o -z "${PHASE}" ]; then
    usage
    exit 1
fi

case "${PHASE}" in
    I|U) ;;
    *) usage; exit 1 ;;
esac

set -u

if ! check_humanname "${APPNAME}"; then
    err "Invalid application name: ${APPNAME}"
    exit 1
fi

ICON="${X11APPJAIL_WORKDIR}/${APPNAME}.png"
DESKTOPFILE="${X11APPJAIL_WORKDIR}/${APPNAME}.desktop"
APPSDIR="${X11APPJAIL_PREFIX}/share/applications"
USER_ICON="${X11APPJAIL_PREFIX}/share/pixmaps/x11appjail-${X11APPJAIL_PROFILE}-${APPNAME}.png"
USER_DESKTOPFILE="${APPSDIR}/x11appjail-${X11APPJAIL_PROFILE}-${APPNAME}.desktop"

if [ "${PHASE}" = "I" ]; then
    if [ ${UID} -eq 0 ]; then
        EXEC="x11appjail run ${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}"
    else
        EXEC="x11appjail run ${X11APPJAIL_HOMEDIR}/.x11appjail/apps/${X11APPJAIL_APPNAME}.AppJail"
    fi

    install -o "${UID}" -g "${GID}" -m 644 -- "${ICON}" \
        "${USER_ICON}"
    install -o "${UID}" -g "${GID}" -m 644 -- "${DESKTOPFILE}" \
        "${USER_DESKTOPFILE}"

    # Escape
    _X11APPJAIL_PROFILE=`printf "%s" "${X11APPJAIL_PROFILE}" | sed -Ee 's/#/\\\#/g'`
    _USER_ICON=`printf "%s" "${USER_ICON}" | sed -Ee 's/#/\\\#/g'`
    _EXEC=`printf "%s" "${EXEC}" | sed -Ee 's/#/\\\#/g'`

    sed -i '' -E \
        -e "s#%%PROFILE%%#${_X11APPJAIL_PROFILE}#g" \
        -e "s#%%ICON%%#${_USER_ICON}#g" \
        -e "s#%%EXEC%%#${_EXEC}#g" \
        -- "${USER_DESKTOPFILE}"
else
    rm -f -- "${USER_ICON}"
    rm -f -- "${USER_DESKTOPFILE}"
fi

CACHE_FILE="${APPSDIR}/mimeinfo.cache"

(
    lockf -s -t 0 9 || exit 0

    if [ -f "${CACHE_FILE}" ]; then
        rm -f -- "${CACHE_FILE}"
    fi

    if [ -d "${APPSDIR}" ]; then
        if check_emptydir "${APPSDIR}"; then
            rm -rf -- "${APPSDIR}"
        fi
    fi

    if [ -d "${APPSDIR}" ]; then
        update-desktop-database -q -- "${APPSDIR}"
    fi
) 9>> "${CACHE_FILE}"
exec 9>&-
