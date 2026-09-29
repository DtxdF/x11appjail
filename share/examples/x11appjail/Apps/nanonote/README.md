# Nanonote

Nanonote is a minimalist note taking application.
It automatically saves anything you type. Being minimalist means it has no synchronisation, does not support multiple documents, images or any advanced formatting (the only formatting is highlighting URLs and Markdown-like headings).

## Attributes

### System Attributes

#### `mount.system-fonts`

Read-only mounts the fonts system inside the jail, configure Fontconfig, and rebuild the font cache.

### User Attributes

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.jail.ephemeral`

If this attribute exists, the jail will be an ephemeral jail.
A jail is always ephemeral if this AppJail runs in portable mode.
