
set -- "$@" -o mount_devfs
set -- "$@" -o device='include $devfsrules_hide_all'
set -- "$@" -o device='include $devfsrules_unhide_basic'
set -- "$@" -o device='include $devfsrules_unhide_login'

if [ -n "${X11APPJAIL_ENABLE_3D}" ]; then
    set -- "$@" -o device="path 'dri' unhide"
    set -- "$@" -o device="path 'dri/*' unhide"
    set -- "$@" -o device="path 'drm' unhide"
    set -- "$@" -o device="path 'drm/*' unhide"
    set -- "$@" -o device="path 'pci' unhide"
    set -- "$@" -o device="path 'nvidia*' unhide"
fi

if [ -n "${X11APPJAIL_ENABLE_WEBCAM}" ]; then
    set -- "$@" -o device="path 'cuse*' unhide"
    set -- "$@" -o device="path 'video*' unhide"
fi

if [ -n "${X11APPJAIL_ENABLE_USB}" ]; then
    set -- "$@" -o device="path usb unhide"
    set -- "$@" -o device="path 'usb/*' unhide"
fi

if [ -n "${X11APPJAIL_ENABLE_SOUND}" ]; then
    set -- "$@" -o device="path sndstat unhide"
    set -- "$@" -o device="path mixer unhide"
    set -- "$@" -o device="path 'mixer*' unhide"
    set -- "$@" -o device="path dsp unhide"
    set -- "$@" -o device="path 'dsp*' unhide"
    set -- "$@" -o device="path speaker unhide"
    set -- "$@" -o device="path 'speaker*' unhide"
fi

set -- "$@" --
