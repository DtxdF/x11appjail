# x11appjail: x11 applications already sandboxed by AppJail

<p align="center">
    <img src="assets/img/x11appjail.png" />
</p>

OS-level isolation is not as perfect as hardware-level virtualization. Containers run the same kernel as the host, and in most cases, if an application needs a file, a directory, or a device, these resources must be shared; therefore, this trade-off must be accepted. A vulnerability in a device (`/dev`), even if the application is running inside the container as a non-root user, could pose a risk to the host. However, all of this applies in the same way as if an application were running from the host, and even worse, since the application has more privileges. However, when implemented correctly, a containerized application is far superior, in terms of isolation, to one running from the host. You can, for example, limit the scope of devices in `/dev`, restrict the connections an application can establish, set resource limits, isolate the filesystem and processes, and much more; all in a compartmentalized manner. This means that if you want to run a web browser in a container, the fact that one is compromised does not imply that another container running your email client is at the same risk.

In FreeBSD, OS-level isolation is implemented using jails, but most users prefer to use a jail manager. In our case, we use AppJail from this repository because of its flexibility and because it can safely run X11 applications thanks to `appjail-x11(1)`. See [Sandboxed x11 applications on AppJail Handbook](https://appjail.readthedocs.io/en/latest/x11/#sandboxed-x11-applications) for details.

## Prerequisites

### Privileges

AppJail requires privileges to run, but it can be integrated with tools such as [security/doas](https://freshports.org/security/doas) to run it as a user without root privileges. This is recommended when you are the only person using the computer and have privileges, or in cases where there are more than two sysadmins or developers on the same server with root access.

**/usr/local/etc/doas.conf**:

```
permit nopass keepenv :appjail as root cmd appjail
```

This rule also assumes that you have a group named appjail. If you don't, don't worry:

```
pw groupadd -n appjail
```

To add your user to the `appjail` group simply run the following:

```
pw groupmod -n appjail -m "$USER"
```

Where `$USER` is your user. For these changes to take effect, you must log back into the system if you are adding yourself.

To test the changes above, simply run the following as a non-root user:

```
appjail help
```

See also: [Trusted Users on AppJail Handbook](https://appjail.readthedocs.io/en/latest/trusted-users/).

### AppJail configuration

These scripts are designed so that users don't have to do much to get started, but at the very least, before running it, you should have preconfigured the parameters related to ZFS (if you use it) and, as a recommendation, `EXT_IF`. See `appjail.conf(5)` and the [ZFS on AppJail Handbook](https://appjail.readthedocs.io/en/latest/ZFS/) for more details.

## How to use this repository

[AppScript](https://freshports.org/archivers/appscript) is used to package each application into its own executable. You can run these AppScripts in a portable manner or install them. Note that if you choose to run an AppScript without installing it, environment variables are not preserved, which means you must define each environment variable before running the AppScript. If you choose to install an AppScript, only environment variables prefixed with `X11APPJAIL_` and defined before running the AppScript are preserved, and the user can override them simply by defining them before running the AppScript.

You can run an application from this repository by cloning it and executing the `./<APP>/APPSCRIPT` script, which is simply a POSIX shell script. Note that you cannot install an application this way.

```sh
git clone https://github.com/DtxdF/x11appjail.git
cd ./x11appjail/
./<APP>/APPSCRIPT
```

However, the best approach is to create an AppScript. To create an AppScript, this repository contains a Makefile that automates this step.

```
make build APP=<APP>
# or to build everything:
make build-all
```

If you don't feel like building AppScripts or don't want to clone this repository, there are already-to-use AppScripts in [assets/appscripts](assets/appscripts). Regardless of the path you choose, all AppScripts run in the same way: like any other executable file.


### Environment

All AppScripts support the following environment variables:

* `X11APPJAIL_JAIL`: Environment variable used by some scripts. This environment variable is always set by each AppScript and cannot be modified. The syntax used by these AppScripts is `x11appjail-<APPNAME>-<UID>_${X11APPJAIL_PROFILE}`, where `<APPNAME>` is a hardcoded name set by each AppScript in its own `app.conf` and `<UID>` is determined based on `id -u`.
* `X11APPJAIL_PROFILE` (default: `default`): AppScripts will attempt to reuse the jail, and the jail name is based on this parameter. This parameter is used to create multiple instances of the same application. The cache and data are not shared with other instances. This is useful for isolating tasks within each jail.
* `X11APPJAIL_LOCKDIR` (default: `${HOME}/x11appjail/locks/${X11APPJAIL_JAIL}`): Location of locks to prevent race conditions and unwanted effects in some operations.
* `X11APPJAIL_APPDIR` (default: `${HOME}/x11appjail/apps/${X11APPJAIL_JAIL}`): Directory used by installed AppScripts. Two scripts are created: `START` and `APPSCRIPT`. `START` is simply a wrapper for `APPSCRIPT` that preserves the environment variables used during AppScript installation. `APPSCRIPT` is a copy of the executed AppScript. When `START` is executed, this script will honor all environment variables passed to it, even if they are already defined.
* `X11APPJAIL_DATADIR` (default: `${HOME}/x11appjail/data/${JAIL}`): The data that must persist. The owner and group of each file will match those of the user running the AppScript.
* `X11APPJAIL_CACHEDIR` (default: `${HOME}/x11appjail/cache/${JAIL}`): Another directory that the jail uses to cache data, so that recreation is faster.
* `X11APPJAIL_OSVERSION` (optional): Configure the `osversion` parameter of `appjail-quick(1)`. By default, this value is calculated based on the kernel version. Note that this AppScript will create the release directory using distfiles if your host has a kernel version lower than `1500000`; otherwise, `pkgbase(8)` will be used. This parameter affects the release created by `appjail-fetch(1)`.
* `X11APPJAIL_VIRTUALNET` (optional): When set, instead of inheriting the host's network stack, a virtual network specified by this environment variable is used. This requires you to configure a few more things, if you haven't already. See [Packet Filter on AppJail Handbook](https://appjail.readthedocs.io/en/latest/networking/packet-filter/).
* `X11APPJAIL_INSTALL` (optional): If set (to any value such as `1`), the AppScript will only install itself and the .desktop file within `~/.local/share/applications`. The icon is installed separately, but this depends on the specific application. The .desktop file isn't included in the AppScript; instead, it is copied directly from the jail and modified. The `Exec` entry is modified to use the `START` script mentioned earlier, and `Name` is simply suffixed with the string `(AppJail)`.
* `X11APPJAIL_UNINSTALL` (optional): If set, the AppScript will delete any files during the installation phase and stop the jail.
* `X11APPJAIL_LABEL[0-9]+` (optional): Specify `appjail-label(1)` labels to be assigned to the jail. At a minimum, you must start with `X11APPJAIL_LABEL0`.

In addition to the environment variables mentioned, `USER`, `HOME`, and `XAUTHORITY` can affect the execution of each AppScript. And keep in mind that each AppScript may need or use custom environment variables.

### Ephemeral Jails

Each jail created is set with the `ephemeral` option of `appjail-quick(1)`, which means that when it stops, it is simply destroyed. Don't worry, the volumes are mounted on your host, so any data that needs to persist will be there.

### Developing a new AppScript

### App Configuration

This file is used to define the parameters used by each AppScript and is self-explanatory.

* `APPNAME`
* `APPDESCR`
* `APPBIN`

### Scripts

These scripts are designed to be as generic as possible and are copied to the specified application using `make update`, so you shouldn't edit them in every application directory, as they will be overwritten. Instead, update them in the root directory of this repository.

* `APPSCRIPT`
* `create.sh`
* `startup.sh`
* `start-server.sh`

In addition to these scripts, there are scripts that can be defined in each application and that only affect the specified application:

* `install.sh` (mandatory): A script that installs any necessary files when `X11APPJAIL_INSTALL` is set. The files that need to be installed include, at a minimum, the .desktop file, preferably copied from the jail to ensure you have the most up-to-date version.
* `uninstall.sh` (mandatory): Delete any files installed during the installation phase.
* `arguments.sh` (optional): Additional arguments passed to `appjail-makejail(1)`. The `set` command of `sh(1)` is used to replace arguments, so you must define each new parameter using the following syntax: `set -- "$@" <new argument>`. After this file is processed, `--puid` and `--pgid` are passed to the Makejail, so you must end your file with at least `set -- "$@" --`.

## Sandboxed Applications

* [Nanonote](nanonote/README.md): Minimalist note taking application.
* [LibreWolf](librewolf/README.md): Custom version of Firefox, focused on privacy, security and freedom.
