NAME
     x11appjail - Tool for creating, verifying, installing, and running
     AppJails

SYNOPSIS
     x11appjail build [-O] [-A algo] [-a arch] [-C directory] [-f directory]
		[-i image] [-o filename] [-s vendorid:public_key] [-t tag]
		[-v version] directory
     x11appjail clipboard [-O] [-s selection] appspec1 [appspec2]
     x11appjail destroy-jail appspec
     x11appjail init pathname
     x11appjail list
     x11appjail login appspec
     x11appjail prefix
     x11appjail print-display appspec
     x11appjail remove appspec
     x11appjail run appspec [args ...]
     x11appjail run-cmd appspec [args ...]
     x11appjail service service appspec [args ...]
     x11appjail trust vendorid public_key
     x11appjail trusted
     x11appjail untrust vendorid
     x11appjail verify filename
     x11appjail version

DESCRIPTION
     x11appjail is a specialized tool for creating, verifying, installing, and
     running AppJails. An AppJail is a CLI, TUI or X11 application that runs
     inside a FreeBSD jail but is perceived by the end user as identical (or
     at least very similar) to an application running directly on the host
     system.

     This tool makes extensive use of appjail(1) as its engine; however,
     unlike the latter, the primary user in x11appjail is neither root nor a
     privileged user, but rather an unprivileged user.	The fundamental goal
     of this project is to grant the user limited access to the jail,
     restricted solely to the execution of a CLI, TUI or X11 application. See
     also SECURITY CONSIDERATIONS.

     The options are as follows:

     build [-O] [-A algo] [-a arch] [-C directory] [-f directory] [-i image]
	  [-o filename] [-s vendorid:public_key] [-t tag] [-v version]
	  directory
	  Create an AppJail.

	  This command creates an executable using appscript(1) that contains
	  an existing appjail-image(1). It's recommended to use reproduce(1)
	  to create appjail-image(1)s.

	  -O  Optimized mode.

	      In the self-contained being created, pkg(8) is used to install
	      the packages; consequently, the resulting AppJail already
	      includes them, so the target system does not need to install
	      them (including appjail(1)). However, these dependencies
	      increase the size of the resulting AppJail and may result in
	      longer decompression times on the target system.	This option is
	      particularly useful for CLI or TUI applications, or for small
	      applications, although it can also be used if the target system
	      installs all the required dependencies.

	  -A algo
	      Compression algorithm to be used to compress directory.

	  -a arch
	      Specifies an architecture different from that of the host.

	      This affects the tools used, such as appscript(1),
	      appjail-image(1), and pkg(8).

	  -C directory
	      A directory used to store the packages that pkg(8) will
	      download. This could speed up subsequent builds if the -O flag
	      isn't set.

	  -f directory
	      Path containing known signatures for the repository, which
	      defaults to /usr/share/keys/pkg.

	      This directory will be copied to /usr/share/keys inside the
	      self-contained environment, so your pkg.conf(5) should reflect
	      this in the FINGERPRINTS parameter.

	      If this parameter is set to none, the fingerprint directory will
	      not be copied.

	  -i image
	      appjail-image(1) to be copied, or the directory name if this
	      parameter is not specified.

	  -o filename
	      Name of the resulting AppJail.

	      If this parameter is not specified, the directory name with the
	      .AppJail suffix is used. Only .AppJail or .appjail should be
	      used as extensions, as this suffix is removed when constructing
	      the application name during an AppJail execution. Refer to
	      IMPLEMENTATION NOTES for further details.

	  -s vendorid:public_key
	      Sign the resulting AppJail. This is primarily used when planning
	      to run AppJails in portable mode.

	      It is important that the vendorid matches the public key
	      installed on the target system.

	  -t tag
	      appjail-image(1) tag, which defaults to latest.

	  -v version
	      A number indicating the major version of the FreeBSD ABI to be
	      used.

	      pkg(8) uses this when installing packages in the self-contained
	      environment, or, in other words, when the -O flag is not
	      specified.

	  directory
	      The directory containing the files to be included in the
	      AppJail. It is important that the directory contains a file
	      (which can be empty) named .x11appjail; otherwise, this command
	      will not execute. If you previously used init, this directory
	      should already contain that dummy file.

     clipboard [-O] [-s selection] appspec1 [appspec2]
	  Synchronizes the clipboard between two X servers.

	  In essence, it is a wrapper for xclipsync(1), but x11appjail
	  retrieves the DISPLAY for each jail, so only the appspec needs to be
	  specified.

	  If only appspec1 is specified, the DISPLAY environment variable is
	  used. In other words, this serves to synchronize the clipboard in
	  appspec1 with the host's X server.

	  If the -O parameter is specified, the clipboard is synchronized only
	  once. See xclipsync(1) for details and implications.

     destroy-jail appspec
	  Destroy a jail.

	  The user can only destroy jails they own. See IMPLEMENTATION NOTES
	  for further details.

     init pathname
	  Create a new directory containing all the files needed to create an
	  AppJail. Refer to x11appjail-spec(5) for details, although the
	  created files contain comments.

	  This command refuses to create the directory if it already exists.

     list
	  List all installed AppJails.

     login appspec
	  Log into the jail.

	  This command will not work unless the jail has the
	  meta.x11appjail.exec.user parameter set to the user under which
	  login(1) will run.

     prefix
	  Displays the system prefix, commonly /usr/local.

     print-display appspec
	  Displays the DISPLAY assigned by the jail.

     remove appspec
	  Uninstalls appspec.

	  Before removing the appspec, the uninstallation script is executed
	  if it was included in the AppJail.

     run appspec [args ...]
	  Executes the program defined by the AppJail inside the jail.

	  If the jail does not exist, it is created. If the checksum has
	  changed, the jail is recreated. And if the AppJail requires an X
	  server, it will be created using appjail-x11(1) before the
	  application starts.

	  If appspec contains a slash, it runs in portable mode. See PORTABLE
	  MODE for details.

     run-cmd appspec [args ...]
	  Executes an arbitrary program inside the jail. If no argument is
	  specified, the jail user's shell (or /bin/sh if none is defined)
	  will be used.

	  This command will not work unless the jail has the
	  meta.x11appjail.exec.user parameter set to the user under which the
	  process will run.

     service service appspec [args ...]
	  Configure a service in appspec. Refer to SERVICES for more details.

     trust vendorid public_key
	  Trust a vendor by installing its public key. This will allow
	  AppJails to run in portable mode. Refer to the PORTABLE MODE section
	  for further details.

	  If public_key is - the content is read from /dev/stdin.

     trusted [pattern]
	  List all trusted providers.

	  If you define a pattern (see grep(1)), you can shorten the list by
	  searching by comment.

     untrust vendorid
	  Removes an installed public key.

     verify filename
	  Verify an AppJail.

	  The vendor's public key embedded in the AppJail must be pre-
	  installed; otherwise, verification will fail.

     version
	  Show the version and exit.

     See PROFILES for an explanation of the meaning of appspec.

UNPRIVILEGED USERS
     As previously mentioned, the main goal of this project is to allow
     unprivileged users to run applications inside a jail.  x11appjail uses
     appjail(1), a tool that requires privileges; however, to prevent users
     from running it directly while still allowing them to create jails in a
     restricted manner, relies on doas(1). You only need to add a single line
     to your doas.conf(5) file:

	   permit nopass USER cmd /usr/local/libexec/x11appjail/map-exec

     Replace USER with the user you want to allow to run AppJails. You can
     also use a group for this, so that you do not have to edit your
     doas.conf(5) file every time.

     VERY IMPORTANT:

     1.   Do not set keepenv. Environment variables can affect the execution
	  of the mentioned utility or the utilities it depends on. You do not
	  need it, and you should not configure it.
     2.   In doas.conf(5), the last rules take precedence; therefore, add the
	  previous rule on the last line.

	  You can run the following command and confirm that the environment
	  is not inherited:

		 doas /usr/local/libexec/x11appjail/map-exec env

PORTABLE MODE
     Portable mode does not necessarily mean your AppJail is completely free
     of dependencies. Depending on how you build your AppJail, it may have
     minimal dependencies on doas(1) and the utilities located in
     /usr/local/libexec/x11appjail. Consult the BUGS section for the
     implications of running an AppJail with minimal dependencies.

     "Portable" means the AppJail does not necessarily require a system-level
     installation (see INSTALLED APPJAILS for the counterpart to this mode).
     In this mode, the AppJail can be run like any other elf(5) executable. As
     a minimum requirement, it is assumed that you have correctly configured
     doas.conf(5) before running an AppJail.

     However, before creating the jail, starting the X server (if necessary),
     running the application, and performing tasks, the AppJail must be signed
     by a trusted vendor. A trusted vendor is one whose public key has been
     installed using the trust command.

     Note that this entails certain performance implications that might not
     provide the best user experience for certain applications. Remember that
     an AppJail is an executable created by appscript(1) that self-extracts to
     a temporary, deterministic location and is removed once the last process
     terminates. This means that when running `./<filename>.AppJail' as an
     unprivileged user, the payload is extracted only once, and the only task
     the user process must perform is invoking an internal utility called
     veriexec (which is unrelated to NetBSD's veriexec).

     The internal utility, veriexec, handles verifying the executable using
     appscript-verify(1), which in turn employs signify(1) but the steps
     preceding the program's execution are far more numerous:

     1.   Retrieves the vendor ID embedded in the executable itself.
     2.   The vendor ID is hashed using SHA-256, and the public key is
	  expected to be /var/x11appjail/keys/sha256(<vendorid>).pub.
     3.   To avoid a TOCTOU race, the executable's SHA-256 checksum is
	  calculated, and the file is then copied to a deterministic temporary
	  location:
	  /tmp/.x11appjail-apps/sha256(<pathname>.AppJail)/<filename>.AppJail.

	  The filename is safe to preserve, as not all characters are
	  permitted. See the IMPLEMENTATION NOTES for further details.
     4.   The executable is verified and, if the verification is successful,
	  it is executed.

     Note that there is a difference between executing an AppJail via
     `./<filename>.AppJail' and executing it with `x11appjail run
     ./<filename>.AppJail'. The first option takes longer and results in
     higher disk activity and CPU usage, as the payload must be extracted
     twice: first by the unprivileged user and subsequently by the root user
     once verification has successfully completed. The only task a user
     process needs to perform when executing `./<filename>.AppJail' is to
     invoke veriexec, and that is precisely what `x11appjail run
     ./<filename>.AppJail' does.

     To improve performance in subsequent executions, refer to the CACHING
     section for details on the techniques employed.

     An AppJail running in portable mode can only use the default profile.
     Additionally, the X11APPJAIL_EPHEMERAL environment variable is set,
     allowing scripts included in the AppJail to use the ephemeral option of
     appjail-quick(1).

CACHING
     To improve subsequent executions of the same AppJail, especially when
     running it in portable mode (see PORTABLE MODE) the following techniques
     are employed to enhance performance without compromising security:

     1.   Once the checksum is calculated, it is stored in
	  /tmp/.x11appjail-apps/sha256(<timestamp>)/. This directory is also
	  used to save the vendor identifier, so that subsequent executions do
	  not need to retrieve it by extracting it from the executable.

	  <timestamp> is a combination of the executable's absolute path,
	  ctime, mtime, and size in bytes.
     2.   Following successful verification, a dummy file is stored in
	  /tmp/.x11appjail-apps/sha256(<pathname>)/ to serve as an indicator
	  for future processes, making it unnecessary to call
	  appscript-verify(1) again.

     Using the aforementioned techniques will save a considerable amount of
     disk activity and CPU time.

     The directories used in that shared location belong to user and group
     0:0, and a check is performed when they exist. This prevents unprivileged
     users from tampering with the cache results.

     Another technique used when running an AppJail involves executing it in
     the background with the --cache option enabled, which simply runs
     sleep(1) for a specified duration. The underlying idea is that, because a
     process is using the extracted directory, the directory is not removed.
     Each time the AppJail runs, a timestamp is updated and the process
     continues to execute. The default duration for this process is 30m,
     though this can be modified by configuring x11appjail_cache_ttl in the
     rc.conf(5) file.

     All of this happens implicitly, and the user does not need to do
     anything.

INSTALLED APPJAILS
     This is the recommended way to run an AppJail: simply by installing it
     and then running it.

     When an AppJail is installed, for example, by running
     `./<filename>.AppJail --install' as root, the appdir is installed at
     /var/x11appjail/apps/<app>.<profile>. This means that when running
     `x11appjail run <appspec>', there is no need to extract the payload, and
     performance improves significantly.

     This also means that there is no need to use the caching techniques
     described in CACHING, and the user experience will be better.

     An installed AppJail also enables another useful feature: profiles,
     described in better in PROFILES.

PROFILES
     appspec consists of appname[:profile]. appname depends on the filename
     and not all characters are allowed. A profile is another instance of the
     same application; this entails using a separate user directory for
     persistent data storage and a different jail. Profiles are useful for
     using the same application across different use cases while keeping them
     isolated from one another.

SERVICES
     Services allow the jail to execute a specific task on the host in a
     limited manner.

     The following are the available services:

     OpenURL appspec [-a patterns]
	  Allow the jail to open a URL.

	  Before opening a URL with xdg-open(1), the user is prompted to allow
	  or deny opening the URL.

	  If the URL matches a list of regular expressions grep(1) (with
	  extended regular expressions). defined by the -a option, no
	  confirmation dialog is displayed and the URL is opened directly.
	  If it does not match or if this list of regular expressions is not
	  defined, a confirmation dialog box is displayed, and the URL is
	  shown in percent-encoded format for non-ASCII (7-bit) characters and
	  the  character, so that even invisible Unicode characters can be
	  parsed in this way. The  character is percent-encoded because this
	  character is already used in the dialog box where the URL is
	  displayed. However, even though the URL is shown in percent-encoded
	  for non-ASCII (7-bit) characters and the  character, the URL is
	  passed as-is.

     Notification appspec
	  Allow the jail to notify the host using notify-send(1).

	  Note that sysutils/dunst must be installed in the jail for this to
	  work.

	  This service receives the app name, summary, body (base64-encoded),
	  icon path, and urgency of a notification created from a jail via
	  stdin.
	  The message body may contain special characters, such as newlines,
	  tabs, etc., but the rendering of these characters depends entirely
	  on your system's notification daemon, which typically supports a
	  limited number of HTML tags. The icon path is completely ignored,
	  and AppJail's icon is used instead.
	  After receiving the first input, the app name, this service will
	  wait for the remaining inputs, but with a timeout set to 1 second to
	  prevent a malicious behaviour by the jail.
	  Once all parameters have been received and the body has been
	  successfully decoded, notify-send(1) is used to create a
	  notification.

     System services are stored in
     /usr/local/libexec/x11appjail/service.d/<service>/, while user services
     are stored in /usr/local/etc/x11appjail/service.d/<service>/. User
     services take precedence over system services. Regardless of whether a
     service is a system or user service, it always runs with the privileges
     of the invoking process and never as root; this is because services must
     inherit the user's environment.

     It is strongly recommended to limit the scope of services to a single
     task and to assume that any input from the jail is untrusted. See
     sprog(7) for relevant recommendations.

IMPLEMENTATION NOTES
     The AppJail filename serves as the application name used to construct
     other strings, such as the name of the jail where the application will
     run and the data directory used for data persistence, among other things.

     The profile, the filename, and, by extension, the application name must
     conform to the following pattern: "^[a-zA-Z0-9][a-zA-Z0-9_-]*$".

     The jail name is constructed by concatenating the prefix x11appjail-, the
     application name, the UID of the calling process, and the suffix _
     profile. For example, if a user with UID 15000 executes ./htop.AppJail, a
     jail named x11appjail-htop-15000_default will be created. Since the user
     is running this AppJail in portable mode, only the default profile can be
     used.

ENVIRONMENT
     DISPLAY
	 The X server to which Xephyr(1) will connect. See appjail-x11(1) for
	 more information.

	 Note that this environment variable must match the following pattern
	 to be considered valid: "^(unix|localhost|127.0.0.1|+(.[0-9]+)?$"

FILES
     The following directories are created when the process invoking an
     AppJail is root:

     /var/x11appjail/apps
	 Location of installed AppJails.

     /var/x11appjail/keys
	 Location of the vendors' public keys.

     /var/x11appjail/users
	 Location of data directories used by users.

	 x11appjail will not create this directory or its subdirectories. It
	 is the responsibility of the AppJails to create this directory and
	 conventionally map the unprivileged user's UID and GID so that the
	 user can access those files from the host.

     /var/run/x11appjail-cache
	 Location of the directory used by the background process when AppJail
	 is invoked with the --cache parameter. See the CACHING section for
	 more details.

     /tmp/.x11appjail-locks
	 Location of the file locks used by the AppJail.

     /tmp/.x11appjail-apps
	 Location of the cache system when running an AppJail in portable
	 mode.	See the CACHING section for details.

     The following directories are created when the process invoking an
     AppJail is an unprivileged user:

     ~/.x11appjail/apps
	 Equivalent to /var/x11appjail/apps, but unlike that directory, when
	 an AppJail is installed by an unprivileged user, the binary is copied
	 instead of the application directory. This means that, even when
	 installing an AppJail as an unprivileged user, it always runs in
	 portable mode.

     ~/.x11appjail/run
	 Equivalent to /var/run/x11appjail-cache but for unprivileged users.

EXIT STATUS
     The x11appjail utility exits 0 on success, and >0 if an error occurs.

SEE ALSO
     appjail(1) appjail-image(1) appjail-x11(1) appscript(1)
     appscript-verify(1) doas(1) reproduce(1) signify(1) xclipsync(1)
     sysexits(3) x11appjail-spec(5)

AUTHORS
     Jesus Daniel Colmenares Oviedo <DtxdF@disroot.org>

BUGS
     Technically speaking, an AppJail can run with minimal dependencies. For
     instance, an AppJail will detect whether the host has appjail(1)
     installed and will prefer using that version over the one bundled within
     the executable itself. The reason lies in Virtual Networks: virtual
     networks require calculating the next IPv4 address from a shared address
     pool, making it illogical to perform this operation from within a private
     directory; hence, using the appjail(1) installed on the host is
     preferable. Likewise, certain x11appjail commands, such as print-display,
     destroy-jail or clipboard will not work, as they rely on appjail(1)
     installed on the host.

     Since virtual networks need to share the same address pool, an AppJail
     with minimal dependencies can either inherit the host's network stack or
     disable the jail's own network stack entirely, thereby limiting available
     networking options. While other network configurations are possible, they
     depend entirely on how the AppJail was created.

     It is possible to create an AppJail with minimal dependencies (meaning it
     requires only doas(1) and x11appjail) by omitting the -O option from the
     build command. When this option is omitted, all dependencies are bundled
     into the binary, making it fully self-contained and eliminating the need
     for the host to have them installed. However, this increases the size of
     the AppJail; if the host already possesses the necessary dependencies,
     such bundling is entirely unnecessary.

SECURITY CONSIDERATIONS
     Physical access constitutes a privilege in itself.

     The primary goal of this project is to run applications within jails
     without needing to become root or allowing unprivileged users to use
     appjail(1) directly; however, this does not mean you should allow just
     any user to run AppJails, for the following reasons:

     1.   Considerable effort is devoted to validating that user-provided
	  files do not interfere with the execution of utilities running with
	  root privileges; however, the size of these files is not verified.
	  This is because it is assumed that if a user has permission to run
	  AppJails and is not subject to quotas limiting the size of stored
	  files, the size of those files should not pose a problem for the
	  system as a whole.
     2.   The temporary directory is extensively used by both x11appjail and
	  appscript(1). Although significant effort goes into employing
	  caching techniques to reduce disk activity and CPU time, the user
	  could potentially invalidate the cache, forcing x11appjail and its
	  associated components to revalidate the entire process.
     3.   An AppJail's filename is used when creating a jail, as it serves as
	  the jail's name. This means a user can create multiple copies of the
	  same AppJail using different filenames, resulting in the creation of
	  distinct jails. Although each jail is isolated, this implies that
	  the system will eventually contain numerous jails.

     In the context of x11appjail, a trusted user is one who does not present
     the issues mentioned above.  Generally, a user with physical access is
     considered trusted. If you have full control over your system, you are a
     trusted user.

     Even if you have root privileges or are the system's sole user, you can
     use AppJails to protect your host machine. The proper approach is not to
     trust the jails and to assume they are already compromised; this implies
     that clipboard usage and file sharing can pose a risk.

     Finally, remember that when installing an AppJail as root, it runs
     without invoking x11appjail's veriexec, unlike when it runs as an
     unprivileged user. This is because the binary has already been executed,
     so verifying the executable serves no purpose.  x11appjail's veriexec is
     implemented solely to protect the host when an unprivileged user runs an
     AppJail; the reverse scenario makes no sense. If you wish to verify an
     executable before running it as root, you can use the verify command
     prior to execution.
