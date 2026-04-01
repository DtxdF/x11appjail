# Tor Browser

Tor Browser (TB) is a customized version of Firefox Extended Service Release built specifically for internet browsing over the Tor anonymity network.

TB's configuration aims to mitigate attacks on a client's anonymity, including determining the client's actual IP address and browser fingerprinting.  Other aspects of Firefox have also been patched to plug privacy leaks in ways not possible any other way.

You are recommended to read about TB and privacy from tor-project documentation.

Remember that there are no perfect privacy or anonymity solutions, and this includes TB.  As always you must pay attention and in many cases modify your behavior to ensure your privacy online.

## Environment

* `X11APPJAIL_ENABLE_3D` (optional): Unhide 3D devices.
* `X11APPJAIL_ENABLE_WEBCAM` (optional): Unhide devices used to enable webcam support. This may require `X11APPJAIL_ENABLE_USB`.
* `X11APPJAIL_ENABLE_USB` (optional): Unhide usb devices.
* `X11APPJAIL_ENABLE_SOUND` (optional): Unhide devices to get sound working.
