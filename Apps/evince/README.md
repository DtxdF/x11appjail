# Evince

Evince is a document viewer for multiple document formats including PDF and Postscript. The goal of evince is to replace document viewers such as ggv and gpdf with a single, simple application.

## Environment

* `X11APPJAIL_WITH_PUCK` (optional): Use [puck](https://github.com/AppJail-makejails/puck) to convert a potentially untrusted PDF into a trusted one.
* `X11APPJAIL_PUCK_RESOLUTION` (default: `300`).
* `X11APPJAIL_PUCK_BATCH` (default: `50`).
* `X11APPJAIL_WITH_CACHE` (default: `0`): Don't copy the PDF to the jail if it already exists.

## Notes

* For a description of `X11APPJAIL_PUCK_RESOLUTION` and `X11APPJAIL_PUCK_BATCH`, see [gh+AppJail-makejails/puck](https://github.com/AppJail-makejails/puck).
* The wrapper only accepts one argument. If the argument is a file (it can also detect this when the argument is prefixed with `file://`), you can optionally use Puck to convert a potentially untrusted PDF into a trusted one. Regardless of whether you use Puck, the PDF will be copied into the jail using its SHA256 hash (from the original PDF if using Puck) as the filename. If the argument is not a file, it is passed as is. A special argument is `--new-window`, used by the .desktop file.
