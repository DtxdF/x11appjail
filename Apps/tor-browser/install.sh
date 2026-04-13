#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?

ICONDIR="${SHAREDIR}/icons"

mkdir -p -- "${ICONDIR}" || exit $?

DESKTOPFILE="tor-browser.desktop"

rm -f -- "${HOME}/.local/share/applications/${DESKTOPFILE}"
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/applications/${DESKTOPFILE} "${HOME}/.local/share/applications" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Exec=/usr/local/lib/tor-browser/tor-browser|Exec=${APPDIR}/START|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee 's|^Name=(.+)|Name=\1 (AppJail)|' "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
sed -i '' -Ee "s|^Icon=.+|Icon=${ICONDIR}/tor-browser.png|" "${HOME}/.local/share/applications/${DESKTOPFILE}" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/lib/tor-browser/browser/chrome/icons/default/default128.png "${ICONDIR}/tor-browser.png" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${ICONDIR}/tor-browser.png" || exit $?
