#!/bin/sh

mkdir -p -- "${HOME}/.local/share/applications" || exit $?
mkdir -p -- "${HOME}/.local/share/icons/hicolor/scalable/apps" || exit $?

appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/applications/com.agateau.nanonote.desktop "${HOME}/.local/share/applications" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/applications/com.agateau.nanonote.desktop" || exit $?
sed -i '' -Ee "s|^Exec=.+|Exec=${APPDIR}/START|" "${HOME}/.local/share/applications/com.agateau.nanonote.desktop" || exit $?
sed -i '' -Ee 's|^Name=(.+)|Name=\1 (AppJail)|' "${HOME}/.local/share/applications/com.agateau.nanonote.desktop" || exit $?
sed -i '' -Ee "s|^Icon=.+|Icon=${HOME}/.local/share/icons/hicolor/scalable/apps/nanonote.svg|" "${HOME}/.local/share/applications/com.agateau.nanonote.desktop" || exit $?
appjail cmd local "${X11APPJAIL_JAIL}" cp -a usr/local/share/icons/hicolor/scalable/apps/nanonote.svg "${HOME}/.local/share/icons/hicolor/scalable/apps" || exit $?
appjail cmd jaildir chown "${UID}:${GID}" "${HOME}/.local/share/icons/hicolor/scalable/apps/nanonote.svg" || exit $?
