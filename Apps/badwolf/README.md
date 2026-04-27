# Badwolf

BadWolf is a minimalist and privacy-oriented WebKitGTK+ browser.

Features:

* Privacy-oriented: No browser-level tracking, multiple ephemeral
  isolated sessions per new unrelated tabs, JavaScript off by default.
* Minimalist: Small codebase (~1 500 LoC), reuses existing components
  when available or makes them available.
* Customizable: WebKitGTK native extensions, Interface customizable
  through CSS.
* Powerful & Usable: Stable User-Interface; The common shortcuts are
  available, no vi-modal edition or single-key shortcuts are used.
* No annoyances: Dialogs are only used when required (save file,
  print, ...), javascript popups open in a background tab.

## Environment

* `X11APPJAIL_ENABLE_3D` (optional): Unhide 3D devices.
* `X11APPJAIL_ENABLE_WEBCAM` (optional): Unhide devices used to enable webcam support. This may require `X11APPJAIL_ENABLE_USB`.
* `X11APPJAIL_ENABLE_USB` (optional): Unhide usb devices.
* `X11APPJAIL_ENABLE_SOUND` (optional): Unhide devices to get sound working.
