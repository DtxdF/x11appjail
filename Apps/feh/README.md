# Feh

feh is a versatile and fast image viewer using imlib2, the premier image file handling library. feh has many features, from simple single file viewing, to multiple file modes using a slideshow or multiple windows. feh supports the creation of montages as index prints with many user-configurable options.

## Notes

* The wrapper only accepts a single argument as a file. If it detects that the argument is a file (it can also detect this when the argument is prefixed with `file://`), the file's contents are transferred via stdin to the `feh(1)` process running within the jail. If it is not a file, the argument is passed as is, which is useless for directories but useful for remote images.
