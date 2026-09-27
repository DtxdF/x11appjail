# Brave Web Browser

The web browser from Brave.
Browse faster by blocking ads and trackers that violate your privacy. and cost you time and money.

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

#### `users.${X11APPJAIL_UID}.perms`

A space-separated list of "permissions" granted to a specific user.

The implemented "permissions" are presented below:

* `webcam`
* `usb`
* `sound`

For a description of any of them, consult `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.<permission>` in the "[User Attributes](#user_attributes)" section.

### User Attributes

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.jail.ephemeral`

If this attribute exists, the jail will be an ephemeral jail.
A jail is always ephemeral if this AppJail runs in portable mode.

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.webcam`

This permission will make webcam-related devices visible.

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.usb`

This permission will make usb-related devices visible.

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.sound`

This permission will make sound-related devices visible.
