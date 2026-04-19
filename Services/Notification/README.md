# Notification

This service receives the app name, summary, body (base64-encoded), icon path, and urgency of a notification created from a jail via standard input (stdin). The message body may contain special characters, such as newlines, tabs, etc., but the rendering of these characters depends entirely on your system's notification daemon, which typically supports a limited number of HTML tags. The icon path is completely ignored, and AppJail's icon is used instead. After receiving the first input, the app name, this service will wait for the remaining inputs, but with a timeout set to 1 second to prevent a malicious behaviour by the jail.

Once all parameters have been received and the body has been successfully decoded, `notify-send(1)` is used to create a notification.

**Note**: [sysutils/dunst](https://freshports.org/sysutils/dunst) is installed in x11appjail applications that use notifications, but it is only configured when this service is running; therefore, if you already have the application running, you may need to rerun the AppScript, since the application inside the jail might run `dunst(1)` without the configuration that calls the installed agent. If you see notifications within the X server created by `Xephyr(1)` instead of by your host, this means you need to restart the AppScript: simply close the application and rerun the AppScript from your menu launcher.

**Example**:

Unlike other services, such as [OpenURL](../OpenURL/README.md), which require the wrapper of a web browser, in this case you should use the same wrapper as the x11appjail application with which you want to provide this service, so it should be very easy to use.

```sh
exec env X11APPJAIL_SERVICE=Notification X11APPJAIL_SERVICE_FROM=thunderbird \
    ~/x11appjail/apps/x11appjail-thunderbird-15000_default/START
```
