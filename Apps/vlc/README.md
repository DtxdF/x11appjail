# vlc

VLC media player is a highly portable multimedia player for various audio and video formats (MPEG-1, MPEG-2, MPEG-4, DivX, mp3, ogg, and more) as well as DVD's, VCD's, and various streaming protocols. It can also be used as a server to stream in unicast or multicast in IPv4 or IPv6 on a high-bandwidth network. VLC also has the ability to transcode media on-the-fly for streaming or saving to disk.

## Environment

* `X11APPJAIL_ENABLE_3D` (optional): Unhide 3D devices.
* `X11APPJAIL_ENABLE_WEBCAM` (optional): Unhide devices used to enable webcam support. This may require `X11APPJAIL_ENABLE_USB`.
* `X11APPJAIL_ENABLE_USB` (optional): Unhide usb devices.
* `X11APPJAIL_ENABLE_SOUND` (optional): Unhide devices to get sound working.

## Notes

* The wrapper only accepts a single argument as a file. If it detects that the argument is a file (it can also detect this when the argument is prefixed with `file://`), the file's contents are transferred via stdin to the `vlc(1)` process running within the jail. If it is not a file, the argument is passed as is, which is useless for directories but useful for remote images.
