# RustDesk

Yet another remote desktop solution, written in Rust. Works out of the box with no configuration required. You have full control of your data, with no concerns about security.

## Environment

* `X11APPJAIL_ENABLE_3D` (optional): Unhide 3D devices.
* `X11APPJAIL_ENABLE_WEBCAM` (optional): Unhide devices used to enable webcam support. This may require `X11APPJAIL_ENABLE_USB`.
* `X11APPJAIL_ENABLE_USB` (optional): Unhide usb devices.
* `X11APPJAIL_ENABLE_SOUND` (optional): Unhide devices to get sound working.
* `X11APPJAIL_SUDOPASS` (optional): If set, a password will be set for `noroot` user. By default, there is no password set, so just press ENTER when RustDesk requires it. This is required by RustDesk in configuration settings.

## Notes

* This jail isn't ephemeral.
* This is a LinuxJail.
