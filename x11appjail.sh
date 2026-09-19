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

set -o pipefail

# x11appjail version.
VERSION="%%VERSION%%"

BUILDDIR=
CACHEDIR=
DATADIR="/var/x11appjail"
APPSDIR="${DATADIR}/apps"
KEYSDIR="${DATADIR}/keys"
USERSDIR="${DATADIR}/users"
UNIXEXEC_TMPDIR=

main()
{
    local root_only=false
    local cmd="$1"

    case "${cmd}" in
        clipboard|run-cmd|destroy-jail|login|init|list|run|trusted|service|print-display|verify|prefix) ;;
        version) version; exit 0 ;;
        build) ;&
        trust) ;&
        untrust) ;&
        remove) root_only=true ;;
        *) usage; exit ${EX_USAGE} ;;
    esac

    load_common

    atexit_init

    if ${root_only} && ! iam_root; then
        err "You need to be root to run this command."
        exit ${EX_NOPERM}
    fi

    shift

    ${cmd} "$@"
}

prefix()
{
    local _s
    _s=`which x11appjail` || exit ${EX_SOFTWARE}
    _s=`dirname -- "${_s}"` || exit ${EX_SOFTWARE}
    _s="${_s}/../"
    _s=`realpath -- "${_s}"` || exit ${EX_SOFTWARE}

    printf "%s\n" "${_s}"
}

destroy-jail()
{
    local app="$1"

    if [ -z "${app}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    build_libexec

    exec doas "${LIBEXEC}/map-exec" "destroy-jail" "${app}"
}

remove()
{
    local app="$1"

    if [ -z "${app}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    build_libexec

    exec doas "${LIBEXEC}/map-exec" "remove" "${app}"
}

login()
{
    local app="$1"

    if [ -z "${app}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    shift

    build_libexec

    exec doas "${LIBEXEC}/map-exec" "login" "${app}"
}

run-cmd()
{
    local app="$1"

    if [ -z "${app}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    shift

    build_libexec

    exec doas "${LIBEXEC}/map-exec" "run-cmd" "${app}" "$@"
}

verify()
{
    local file="$1"

    if [ -z "${file}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    local vendorid
    vendorid=`appscript-verify -P -- "${file}"` || exit ${EX_SOFTWARE}

    local uniqid
    uniqid=`printf "%s" "${vendorid}" | sha256 -q` || exit 1

    local keyfile="${KEYSDIR}/${uniqid}.pub"

    if [ ! -f "${keyfile}" ]; then
        err "${vendorid}: no public key found."
        exit ${EX_NOINPUT}
    fi

    exec appscript-verify -p "${keyfile}" -- "${file}"
}

trusted()
{
    if [ ! -d "${KEYSDIR}" ]; then
        exit ${EX_OK}
    fi

    local display_column=true
    local pattern="${1:-.}"

    find -- "${KEYSDIR}" -type f -name '*.pub' | while IFS= read -r public_key; do
        COMMENT=`grep -Ee '^untrusted comment:' -- "${public_key}" | grep -Ee "${pattern}"`

        ERRLEVEL=$?

        if [ ${ERRLEVEL} -eq 1 ]; then
            continue
        elif [ ${ERRLEVEL} -gt 1 ]; then
            # error
            exit 1
        fi

        COMMENT=`printf "%s" "${COMMENT}" | sed -Ee 's/^untrusted comment: //'` || exit ${EX_SOFTWARE}
        COMMENT="${COMMENT:--}"

        if ${display_column}; then
            printf "%s\t%s\n" "KEY" "COMMENT"
            display_column=false
        fi
        printf "%s\t%s\n" "${public_key##*/}" "${COMMENT}"
    done | column -t -s$'\t'
}

trust()
{
    local vendorid="$1" public_key="$2"

    if [ -z "${vendorid}" -o -z "${public_key}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    if [ "${public_key}" = "-" ]; then
        public_key="/dev/stdin"
    fi

    create_directory "${KEYSDIR}"

    local uniqid
    uniqid=`printf "%s" "${vendorid}" | sha256 -q` || exit ${EX_SOFTWARE}

    local keyfile="${KEYSDIR}/${uniqid}.pub"

    head -2 "${public_key}" > "${keyfile}~" || exit ${EX_IOERR}

    if ! grep -qEe '^untrusted comment:' -- "${keyfile}~" || [ `cat -- "${keyfile}~" | wc -l` -ne 2 ]; then
        rm -f -- "${keyfile}~"

        err "${public_key}: public key is invalid."
        exit ${EX_DATAERR}
    fi

    mv -- "${keyfile}~" "${keyfile}" || exit ${EX_IOERR}
}

untrust()
{
    local vendorid="$1"

    if [ -z "${vendorid}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    local uniqid
    uniqid=`printf "%s" "${vendorid}" | sha256 -q` || exit ${EX_SOFTWARE}

    local keyfile="${KEYSDIR}/${uniqid}.pub"

    if [ ! -f "${keyfile}" ]; then
        err "${vendorid}: no public key found."
        exit ${EX_NOINPUT}
    fi

    rm -f -- "${keyfile}"
}

atexit_init()
{
	trap '' ${IGNORED_SIGNALS}
    trap clean_exit ${HANDLED_SIGNALS}
    trap "_ERRLEVEL=\$?; _clean_exit; exit \${_ERRLEVEL}" EXIT
}

print-display()
{
    local app="$1"

    if [ -z "${app}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    shift

    build_libexec

    exec doas "${LIBEXEC}/map-exec" "print-display" "${app}"
}

clipboard()
{
    local _o
    local once_flag=
    local selection="CLIPBOARD"

    while getopts ":Os:" _o; do
        case "${_o}" in
            O)
                once_flag="-O"
                ;;
            s)
                selection="${OPTARG}"
                ;;
            *)
                usage
                exit ${EX_USAGE}
                ;;
        esac
    done
    shift $((OPTIND-1))

    selection=`printf "%s" "${selection}" | tr '[[:lower:]]' '[[:upper:]]'`

    case "${selection}" in
        CLIPBOARD|PRIMARY|SECONDARY) ;;
        *) usage; exit ${EX_USAGE} ;;
    esac

    local app1="$1"

    if [ -z "${app1}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    local app1_display
    app1_display=`print-display "${app1}"` || exit ${EX_SOFTWARE}

    local app2="$2"

    if [ -n "${app2}" ]; then
        local app2_display
        app2_display=`print-display "${app2}"` || exit ${EX_SOFTWARE}

        exec xclipsync ${once_flag} -s "${selection}" -a ":${app1_display}" -b ":${app2_display}"
    else
        exec xclipsync ${once_flag} -s "${selection}" -a "${DISPLAY:-:0}" -b ":${app1_display}"
    fi
}

version()
{
    echo "${VERSION}"
}

build()
{
    local _o
    local opt_optimized=false
    local algo="zstd"
    local arch
    arch=`uname -p` || exit ${EX_SOFTWARE}
    local fingerprints_directory="/usr/share/keys/pkg"
    local image=
    local out=
    local sign= vendorid= sign_key=
    local tag="latest"
    local version
    version=`freebsd-version | grep -Eo '^[0-9]+'` || exit ${EX_SOFTWARE}

    while getopts ":OA:a:C:f:i:o:s:t:v:" _o; do
        case "${_o}" in
            O)
                opt_optimized=true
                ;;
            A)
                algo="${OPTARG}"
                ;;
            a)
                arch="${OPTARG}"
                ;;
            C)
                CACHEDIR="${OPTARG}"
                ;;
            f)
                fingerprints_directory="${OPTARG}"
                ;;
            i)
                image="${OPTARG}"
                ;;
            o)
                out="${OPTARG}"
                ;;
            s)
                sign="${OPTARG}"
                ;;
            t)
                tag="${OPTARG}"
                ;;
            v)
                version="${OPTARG}"
                ;;
            *)
                usage
                exit ${EX_USAGE}
                ;;
        esac
    done
    shift $((OPTIND-1))

    local path="$1"

    if [ -z "${path}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    if ! ${opt_optimized}; then
        if ! pkg -N 2> /dev/null; then
            err "pkg(8) is not present on the host. Cannot continue."
            exit ${EX_UNAVAILABLE}
        fi
    fi

    if [ ! -f "${path}/.x11appjail" ]; then
        err "'${path}' is not a directory managed by x11appjail."
        exit ${EX_NOPERM}
    fi

    if [ ! -d "${path}" ]; then
        err "${path}: No such directory."
        exit ${EX_NOINPUT}
    fi

    if [ -n "${sign}" ]; then
        vendorid=`printf "%s" "${sign}" | cut -s -d: -f1` || exit ${EX_SOFTWARE}
        sign_key=`printf "%s" "${sign}" | cut -s -d: -f2-` || exit ${EX_SOFTWARE}

        if ! printf "%s" "${vendorid}" | grep -q .; then
            usage
            exit ${EX_USAGE}
        fi

        if [ -z "${sign_key}" ]; then
            usage
            exit ${EX_USAGE}
        fi
    fi

    path=`realpath -- "${path}"` || exit ${EX_SOFTWARE}

    local appname
    appname=`basename -- "${path}"` || exit ${EX_SOFTWARE}

    if [ -z "${image}" ]; then
        image="${appname}"
    fi

    local image_file
    image_file=`appjail image realpath -a "${arch}" -t "${tag}" -- "${image}"` || exit ${EX_SOFTWARE}

    if [ -z "${out}" ]; then
        out="${appname}.AppJail"
    fi

    debug "Building ${out}"

    BUILDDIR=`mktemp -d -t x11appjail` || exit ${EX_IOERR}

    build_sharedir

    if ! ${opt_optimized}; then
        export PKG_CACHEDIR="${BUILDDIR}/var/cache/pkg"

        local abi
        abi="FreeBSD:${version}:${arch}"

        if [ "${fingerprints_directory}" != "none" ]; then
            info "Copying pkg(8) keys"

            run_cmd mkdir -p -- "${BUILDDIR}/usr/share/keys"
            run_cmd cp -a -- "${fingerprints_directory}" "${BUILDDIR}/usr/share/keys"
        fi

        if [ -n "${CACHEDIR}" ]; then
            info "pkg(8) cache is enabled, mounting ..."
            run_cmd mkdir -p -- "${PKG_CACHEDIR}"
            run_cmd mount_nullfs -- "${CACHEDIR}" "${PKG_CACHEDIR}"
        fi

        info "Installing packages (ABI:${abi})"
        env IGNORE_OSVERSION=yes ABI="${abi}" ASSUME_ALWAYS_YES=yes pkg --rootdir "${BUILDDIR}" install -- \
            ${PACKAGES}

        if [ -n "${CACHEDIR}" ]; then
            info "Unmounting cache directory"
            umount_cachedir
        else
            info "Removing cached files"
            run_cmd env IGNORE_OSVERSION=yes ABI="${abi}" ASSUME_ALWAYS_YES=yes pkg --rootdir "${BUILDDIR}" clean -a
            run_cmd rm -rf "${PKG_CACHEDIR}"/*
        fi

        info "Removing package database files"
        run_cmd rm -rf "${BUILDDIR}/var/db/pkg/repos"/*
    fi

    info "Installing AppJail"
    run_cmd git clone --depth 1 https://github.com/DtxdF/AppJail.git "${BUILDDIR}/AppJail"
    (
        cd -- "${BUILDDIR}/AppJail" || exit ${EX_SOFTWARE}
        run_cmd make DESTDIR="${BUILDDIR}" APPJAIL_VERSION=`make -V APPJAIL_VERSION`+`git rev-parse HEAD`
    ) || exit ${EX_SOFTWARE}
    info "Creating appjail.conf(5)"
    run_cmd mkdir -p -- "${BUILDDIR}/usr/local/etc/appjail"
    cat << "EOF" > "${BUILDDIR}/usr/local/etc/appjail/appjail.conf" || exit ${EX_IOERR}
JAILSDIR="/var/x11appjail/jails"
ENABLE_DEBUG=0
TAR_XZ_ARGS="--xz --options xz:threads=0"
TAR_ZSTD_ARGS="--zstd --options zstd:threads=0"
EOF

    info "Copying APPSCRIPT"
    run_cmd cp -a "${SHAREDIR}/appscript/APPSCRIPT" "${BUILDDIR}"
    run_cmd sed -i '' -Ee "s/#VERSION#/${VERSION}/" "${BUILDDIR}/APPSCRIPT"
    run_cmd chmod +x "${BUILDDIR}/APPSCRIPT"

    info "Copying ${path}/"
    run_cmd mkdir -p -- "${BUILDDIR}/x11appjail"
    run_cmd cp -a -- "${path}/" "${BUILDDIR}/x11appjail"
    info "Copying AppJail image"
    run_cmd cp -a -- "${image_file}" "${BUILDDIR}/x11appjail/image"

    info "Creating AppScript"
    set --
    if [ -n "${vendorid}" -a -n "${sign_key}" ]; then
        set -- -I "${vendorid}" -i "${sign_key}"
    fi
    # signify(1) may prompt for a passphrase.
    info "appscript" "-MM" "$@" "-a" "${arch}" "-c" "${algo}" "-o" "${out}" "--" "${BUILDDIR}"
    appscript -MM "$@" -a "${arch}" -c "${algo}" -o "${out}" -- "${BUILDDIR}" || exit ${EX_SOFTWARE}

    info "Done."

    remove_builddir
}

umount_cachedir()
{
    if [ -z "${BUILDDIR}" ] || [ -z "${PKG_CACHEDIR}" ] || \
            [ -z "${CACHEDIR}" ] || [ ! -d "${PKG_CACHEDIR}" ]; then
        return 0
    fi

    run_cmd umount -- "${PKG_CACHEDIR}" > /dev/null

    CACHEDIR=
}

remove_builddir()
{
    if [ -z "${BUILDDIR}" ] || [ ! -d "${BUILDDIR}" ]; then
        return 0
    fi

    run_cmd chflags -R noschg "${BUILDDIR}"
    run_cmd rm -rf -- "${BUILDDIR}"

    BUILDDIR=
}

init()
{
    local name
    local path="$1"

    name=`basename -- "${path}"` || exit ${EX_SOFTWARE}

    if [ -z "${name}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    if [ -d "${path}" ]; then
        err "Path '${path}' already exists."
        exit ${EX_NOPERM}
    fi

    debug "Scaffolding ${path} ..."

    build_sharedir

    run_cmd cp -a "${SHAREDIR}/scaffold" "${path}"

    local file
    for file in `ls "${SHAREDIR}/scaffold"`; do
        run_cmd chmod +w "${path}/${file}"
    done
}

list()
{
    if [ ! -d "${APPSDIR}" ]; then
        exit ${EX_OK}
    fi

    build_libexec

    local display_column=true

    find -- "${APPSDIR}" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r directory; do
        # Only display completed apps.
        if [ ! -f "${directory}/.done" ]; then
            continue
        fi

        NAME="${directory##*/}"
        PROFILE=`printf "%s" "${NAME}" | cut -s -d. -f2` || exit ${EX_SOFTWARE}
        NAME=`printf "%s" "${NAME}" | cut -s -d. -f1` || exit ${EX_SOFTWARE}
        if iam_root; then
            SIZE=`du -sh -- "${directory}" | cut -d$'\t' -f1` || exit ${EX_SOFTWARE}
        else
            SIZE=`doas "${LIBEXEC}/map-exec" "appsiz" "${NAME}:${PROFILE}"` || exit ${EX_SOFTWARE}
        fi

        if ${display_column}; then
            printf "%s\t%s\t%s\n" "NAME" "PROFILE" "SIZE"
            display_column=false
        fi
        printf "%s\t%s\t%s\n" "${NAME}" "${PROFILE}" "${SIZE:--}"
    done | column -t -s$'\t'
}

run()
{
    local app="$1"

    if [ -z "${app}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    shift

    build_libexec

    if ! printf "%s" "${app}" | grep -q '/'; then
        # installed
        exec doas "${LIBEXEC}/map-exec" "exec" "${DISPLAY:-:0}" "${app}" "$@"
    else
        # portable
        exec doas "${LIBEXEC}/map-exec" "veriexec" "${DISPLAY:-:0}" "${app}" "$@"
    fi
}

service()
{
    local service="$1"

    if [ -z "${service}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    shift

    if ! check_humanname "${service}"; then
        err "Invalid service name: ${service}"
        exit ${EX_DATAERR}
    fi

    local app="$1"

    if [ -z "${app}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    shift

    build_libexec
    build_etcdir

    local servicedir=
    local servicedir1="${LIBEXEC}/service.d/${service}"
    local servicedir2=

    if [ -n "${ETCDIR}" ]; then
        servicedir2="${ETCDIR}/service.d/${service}"

        if [ -d "${servicedir2}" ]; then
            servicedir="${servicedir2}"
        fi
    fi

    servicedir="${servicedir:-${servicedir1}}"

    if [ ! -d "${servicedir}" ]; then
        err "${service}: service not found."
        exit ${EX_NOINPUT}
    fi

    local uid
    uid=`id -u` || exit ${EX_SOFTWARE}

    local gid
    gid=`id -g` || exit ${EX_SOFTWARE}

    local userdir="${USERSDIR}/${uid}/${app}"

    if [ ! -d "${userdir}" ]; then
        err "${userdir}: not such directory."
        exit ${EX_NOINPUT}
    fi

    local owner
    owner=`stat -f "%u" -- "${userdir}"` || exit ${EX_SOFTWARE}

    if [ "${owner}" != "${uid}" ]; then
        err "${userdir}: UID of the calling process (${uid}) differs from the owner of the user directory (${owner})."
        exit ${EX_NOPERM}
    fi

    local agent="${servicedir}/agent"

    if [ ! -x "${agent}" ]; then
        err "${agent}: agent not found."
        exit ${EX_OSFILE}
    fi

    local exec="${servicedir}/exec"

    if [ ! -x "${exec}" ]; then
        err "${exec}: execution script not found."
        exit ${EX_OSFILE}
    fi

    local x11appjail_services="${userdir}/.x11appjail-services"
    local x11appjail_servicedir="${x11appjail_services}/${service}"

    cat << EOF | doas "${LIBEXEC}/map-exec" "run-cmd" "${app}" /bin/sh -s || exit ${EX_SOFTWARE}
set -e

install -d -m 770 "\${HOME}/.x11appjail-services/${service}"
EOF

    local setup="${servicedir}/setup"

    # This is simply an optimization for when everything is fine, but
    # we should not consider the result of this check to be definitive,
    # as you will see.
    if [ ! -d "${x11appjail_servicedir}" ] && [ -L "${x11appjail_servicedir}" ]; then
        err "${x11appjail_servicedir}: isn't a directory or doesn't exist."
        exit ${EX_NOPERM}
    fi

    UNIXEXEC_TMPDIR=`mktemp -d -t x11appjail` || exit ${EX_IOERR}

    # It's supposed that this file is controlled by the sysadmin,
    # but normally a symlink should not happen.
    cp -L -- "${agent}" "${UNIXEXEC_TMPDIR}" || exit ${EX_IOERR}

    if [ -d "${x11appjail_servicedir}" ]; then
        rm -rf -- "${x11appjail_servicedir}"
    fi

    mv -h -- "${UNIXEXEC_TMPDIR}" "${x11appjail_servicedir}" || exit ${EX_IOERR}

    UNIXEXEC_TMPDIR=

    if [ -x "${setup}" ]; then
        cat -- "${setup}" | doas "${LIBEXEC}/map-exec" "run-cmd" "${app}" /bin/sh -s || exit ${EX_SOFTWARE}
    fi

    while :; do
        run_cmd unixexec -D "${x11appjail_servicedir}" "sock" "${exec}" "${app}" "$@"
    done
}

clean_unixexec()
{
    if [ -n "${UNIXEXEC_TMPDIR}" ] && [ -d "${UNIXEXEC_TMPDIR}" ]; then
        rm -rf -- "${UNIXEXEC_TMPDIR}"
    fi
}

clean_exit()
{
    ignore_signals
    _clean_exit
	trap - ${IGNORED_SIGNALS} ${HANDLED_SIGNALS}

    exit ${EX_SOFTWARE}
}

ignore_signals()
{
    trap '' ${HANDLED_SIGNALS}
}

_clean_exit()
{
    if [ -n "${LAST_PID}" ] && check_proc "${LAST_PID}"; then
        kill_wait "${LAST_PID}"
        LAST_PID=
    fi

    umount_cachedir
    remove_builddir
    clean_unixexec
}

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
    cat << EOF
usage: x11appjail build [-O] [-A <algo>] [-a <arch>] [-C <directory>] [-f <directory>]
               [-i <image>] [-o <filename>] [-s <vendorid>:<public_key>] [-t <tag>]
               [-v <version>] <directory>
       x11appjail clipboard [-O] [-s <selection>] <appspec1> [<appspec2>]
       x11appjail destroy-jail <appspec>
       x11appjail init <pathname>
       x11appjail list
       x11appjail login <appspec>
       x11appjail prefix
       x11appjail print-display <appspec>
       x11appjail remove <appspec>
       x11appjail run <appspec> [<args> ...]
       x11appjail run-cmd <appspec> [<args> ...]
       x11appjail service <service> <appspec> [<args> ...]
       x11appjail trust <vendorid> <public_key>
       x11appjail trusted
       x11appjail untrust <vendorid>
       x11appjail verify <filename>
       x11appjail version
EOF
}

main "$@"
