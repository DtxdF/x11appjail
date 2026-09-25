# Firefox Web Browser

Mozilla Firefox is a free and open source web browser descended from the Mozilla Application Suite. It is small, fast and easy to use, and offers many advanced features:

* Popup Blocking
* Tabbed Browsing
* Live Bookmarks (ie. RSS)
* Extensions
* Themes
* FastFind
* Improved Security

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

* `enable_3d`
* `webcam`
* `usb`
* `sound`

For a description of any of them, consult `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.<permission>` in the "[User Attributes](#user_attributes)" section.

### User Attributes

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.virtualgl.display`

If the user has the `enable_3d` permission, this specifies the display or EGL device to be used for 3D rendering. Since using EGL is the only logical choice for this project, the default value is `egl`. In multi-GPU environments, it is possible to specify a particular device.

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.jail.ephemeral`

If this attribute exists, the jail will be an ephemeral jail.
A jail is always ephemeral if this AppJail runs in portable mode.

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.enable_3d`

This permission will execute the application using VirtualGL and make hardware acceleration-related devices visible.

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.webcam`

This permission will make webcam-related devices visible.

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.usb`

This permission will make usb-related devices visible.

#### `${X11APPJAIL_APPNAME}:${X11APPJAIL_PROFILE}.allow.sound`

This permission will make sound-related devices visible.

## Notes

1. It may be necessary to set `widget.dmabuf-webgl.enabled` to `false` in `about:config`, otherwise Firefox will fall back to software rendering.
