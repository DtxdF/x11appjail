set -- "$@" --

if [ -n "${X11APPJAIL_ENABLE_3D}" ]; then
    set -- "$@" --enable_3d 1
fi

if [ -n "${X11APPJAIL_ENABLE_WEBCAM}" ]; then
    set -- "$@" --enable_webcamd 1
fi

if [ -n "${X11APPJAIL_ENABLE_USB}" ]; then
    set -- "$@" --enable_usb 1
fi

if [ -n "${X11APPJAIL_ENABLE_SOUND}" ]; then
    set -- "$@" --enable_audio 1
fi

