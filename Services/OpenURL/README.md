# OpenURL

This service receives data via its standard input (stdin) in the form of a URL. If the URL matches a list of regular expressions defined by `X11APPJAIL_SRV_OPENURL_ALLOW`, no confirmation dialog is displayed and the URL is opened directly. If it does not match or if this list of regular expressions is not defined, a confirmation dialog box is displayed, and the URL is shown in percent-encoded format for non-ASCII (7-bit) characters and the `"` character, so that even invisible Unicode characters can be parsed in this way. The `"` character is percent-encoded because this character is already used in the dialog box where the URL is displayed. However, even though the URL is shown in percent-encoded for non-ASCII (7-bit) characters and the `"` character, the URL is passed as-is. 

For this service to work, the wrapper must accept `--` (double dash) to signal the end of argument processing and use the first (and only) positional argument as the URL to be opened. The reason it has been implemented this way is that an jail could send a malformed URL (or even something that doesn’t resemble a URL at all) that the wrapper might accept as a parameter rather than as a simple URL, which could lead to unintended behavior.

**Example**:

This example runs the OpenURL service, which will be provided to the jail where telegram-desktop is located; and, since we haven't specified a profile, the default one (`default`) will be used. When a process opens a URL in the jail where the service is provided, a dialog box appears to confirm the action, and clicking `Yes` to open the URL will execute `~/x11appjail/apps/x11appjail-chromium-15000_default/START` with only two arguments: `--` and `<URL>`.

```sh
env X11APPJAIL_SERVICE=OpenURL X11APPJAIL_SERVICE_FROM=telegram-desktop \
    ~/x11appjail/apps/x11appjail-chromium-15000_default/START
```
