# Evince

Evince is a document viewer for multiple document formats including PDF and Postscript.
The goal of evince is to replace document viewers such as ggv and gpdf with a single, simple application.

## Attributes

### System Attributes

#### `mount.system-fonts`

Read-only mounts the fonts system inside the jail, configure Fontconfig, and rebuild the font cache.

### User Attributes

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.jail.ephemeral`

If this attribute exists, the jail will be an ephemeral jail.
A jail is always ephemeral if this AppJail runs in portable mode.

## Notes

1. Use `--help` to see a list of all available options.
