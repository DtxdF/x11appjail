# nanonote

Nanonote is a minimalist note taking application.
It automatically saves anything you type. Being minimalist means it has no
synchronisation, does not support multiple documents, images or any advanced
formatting (the only formatting is highlighting URLs and Markdown-like
headings).

## Prerequisites

### Privileges

This script needs elevated privileges to install any missing dependencies or to run AppJail. The configuration tool that AppJail uses to elevate privileges is separate from this script, but for consistency, we will use [security/doas](https://freshports.org/security/doas).

To configure [security/doas](https://freshports.org/security/doas), first install it, then open `vidoas(8)` and add the following rules:

```
permit nopass :appjail cmd pkg
permit nopass keepenv :appjail cmd appjail
```

All users added to the `appjail` group can deploy jail and install applications.

If you haven't created this group yet:

```
pw groupadd -n appjail
pw groupmod -n appjail -m <your-user>
```

### AppJail configuration

This script is designed so that users don't have to do much to get started, but at the very least, before running it, you should have preconfigured the parameters related to ZFS (if you use it) and, as a recommendation, `EXT_IF`. See `appjail.conf(5)` and the AppJail Handbook for more details.

## How to use this AppScript

As mentioned, this AppScript is designed so that users do not need to spend a lot of time running an application inside a jail. Simply clone this repository, navigate to this directory and then run `./APPSCRIPT`.

```sh
git clone https://github.com/DtxdF/x11appjail.git
cd ./x11appjail/nanonote/
./APPSCRIPT
```

This is also designed to be packaged into an executable created by the [appscript](https://github.com/DtxdF/appscript) project, so if you want to create a more portable way to run this application, run something like this:

```sh
git clone https://github.com/DtxdF/x11appjail.git
cd ./x11appjail
mkdir -p ~/AppScripts
appscript -t -o ~/AppScripts/nanonote.appscript nanonote
~/AppScripts/nanonote.appscript
```

## Environment

* `X11APPJAIL_JAIL` (default: `nanonote`): Environment variable used by the `create.sh` and `run.sh` scripts. This variable is always set by `APPSCRIPT` and cannot be modified. The syntax used by `APPSCRIPT` is `x11appjail-<APPNAME>-<UID>_${X11APPJAIL_PROFILE}`, where `<APPNAME>` is a hardcoded name set by this script and `<UID>` is determined based on `id -u`.
* `X11APPJAIL_PROFILE` (default: `default`): This AppScript will attempt to reuse the jail, and the jail name is based on this parameter. This parameter is used to create multiple instances of the same application. The cache and data are not shared with other instances. This is useful for isolating tasks within each jail.
* `X11APPJAIL_EXEC_TOOL` (optional): A tool for elevating privileges in order to install dependencies. If not configured, this AppScript will check whether `doas(8)`, `sudo(8)`, or mdo(1) are installed on your system. If they are not available, the command requiring privileges will likely fail.
* `X11APPJAIL_OSVERSION` (optional): Configure the `osversion` parameter of `appjail-quick(1)`. By default, this value is calculated based on the kernel version. Note that this AppScript will create the release directory using distfiles if your host has a kernel version lower than `1500000`; otherwise, `pkgbase(8)` will be used. This parameter affects the release created by `appjail-fetch(1)`.
* `X11APPJAIL_DATADIR` (default: `${HOME}/x11appjail/data/${X11APPJAIL_JAIL}`): The data that must persist. The owner and group of each file will match those of the user running this AppScript.
* `X11APPJAIL_CACHEDIR` (default: `${HOME}/x11appjail/cache/${X11APPJAIL_JAIL}`): Another directory that the jail uses to cache data, so that recreation is faster.
* `X11APPJAIL_VIRTUALNET` (optional): When enabled, instead of inheriting the host's network stack, a virtual network specified by this environment variable is used.
