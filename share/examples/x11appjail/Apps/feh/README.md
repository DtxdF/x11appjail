# Feh

feh is a versatile and fast image viewer using imlib2, the premier image file handling library. feh has many features, from simple single file viewing, to multiple file modes using a slideshow or multiple windows. feh supports the creation of montages as index prints with many user-configurable options.

## Attributes

### System Attributes

#### `network.mode`

Network mode. Default is `none`.

There are three modes:

1. `virtualnet`: This option is recommended, as it provides isolation and allows a more fine-grained control. It's necessary to install and configure AppJail on the host, as specified in the "[Getting Started](https://appjail.readthedocs.io/en/latest/getting-started/)" guide.
2. `inherit`: This mode does not provide network isolation. From a networking perspective, it is exactly the same as running the application on the host.
3. `none`: Completely disable the network stack.

#### `network.virtualnet`

Specify the virtual network to be used when `network.mode` is set to `virtualnet`. If not specified, no virtual network is defined, so the default one is used.

#### `network.security-group.tables`

If `network.mode` is set to `virtualnet`, this attribute specifies a space-separated list of `pf(4)` tables to which the jail will be added using Security Group hooks.

If you are going to add additional labels related to Security Groups, do not include `security-group:1`, as this attribute already include it.

See also: https://github.com/DtxdF/AppJail/wiki/filter

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.labels`

A space-separated list of label names.

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.labels.<label>`

The value of the label.

#### `mount.system-fonts`

Read-only mounts the fonts system inside the jail, configure Fontconfig, and rebuild the font cache.

### User Attributes

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.jail.ephemeral`

If this attribute exists, the jail will be an ephemeral jail.
A jail is always ephemeral if this AppJail runs in portable mode.

## Notes

1. The last argument is the file, always. `--start-at` will not work due to this.
2. If the file is an existing file on the file system and the unprivileged user has read permission, the image is transferred from the host to the jail via stdin.
3. This AppJail only works with regular files and URLs.
