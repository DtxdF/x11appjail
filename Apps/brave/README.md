# Brave Web Browser

The web browser from Brave.
Browse faster by blocking ads and trackers that violate your privacy and cost you time and money.

## Environment

* `X11APPJAIL_ENABLE_3D` (optional): Unhide 3D devices.
* `X11APPJAIL_ENABLE_WEBCAM` (optional): Unhide devices used to enable webcam support. This may require `X11APPJAIL_ENABLE_USB`.
* `X11APPJAIL_ENABLE_USB` (optional): Unhide usb devices.
* `X11APPJAIL_ENABLE_SOUND` (optional): Unhide devices to get sound working.

## Notes

* `--no-sandbox --test-type --v=0 --ignore-gpu-blocklist` are set by default.
* **WARNING**: Don't open chrome://gpu, or Brave will crash. If you open it by mistake, just press CTRL+w.
* Jail stops after you close Brave. This is a workaround to prevent Brave from freezing when you reopen the window in the same session. Some operations (like installing DRM stuff) require restarting the browser. Do not do this. Instead, simply close Brave and let the AppScript stop the jail.
* This jail isn't ephemeral.
* This is a LinuxJail.
