#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?

ICONDIR="${SHAREDIR}/icons"

mkdir -p -- "${ICONDIR}" || exit $?

appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/applications/com.agateau.nanonote.desktop "${HOME}/.local/share/applications" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/applications/com.agateau.nanonote.desktop" || exit $?
sed -i '' -Ee "s|^Exec=.+|Exec=${APPDIR}/START|" "${HOME}/.local/share/applications/com.agateau.nanonote.desktop" || exit $?
sed -i '' -Ee 's|^Name=(.+)|Name=\1 (AppJail)|' "${HOME}/.local/share/applications/com.agateau.nanonote.desktop" || exit $?
sed -i '' -Ee "s|^Icon=.+|Icon=${ICONDIR}/nanonote.svg|" "${HOME}/.local/share/applications/com.agateau.nanonote.desktop" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/icons/hicolor/scalable/apps/nanonote.svg "${ICONDIR}/nanonote.svg" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${ICONDIR}/nanonote.svg" || exit $?
