# Simple SDDM theme

A minimal, asset-free SDDM theme built with QML for Qt 6, kept alongside the
Quickshell configuration that it complements.

## Preview

Run the greeter in test mode from this directory:

```sh
sddm-greeter-qt6 --test-mode --theme .
```

On distributions where the executable has no Qt suffix, use:

```sh
sddm-greeter --test-mode --theme .
```

## Install

For live palette updates, link the repository copy into SDDM's system theme
directory:

```sh
sudo ln -s "$PWD/sddm/themes/simple" /usr/share/sddm/themes/simple
```

Run that command from the Quickshell repository root. If a copied `simple`
directory already exists, remove or rename that specific directory before creating
the link.

### Permissions

SDDM runs the greeter as the unprivileged `sddm` account. If this repository is
inside a private home directory, the greeter must be able to traverse the home
directory to follow the theme symlink and reach its wallpaper. Grant only that
account traverse permission with an ACL:

```sh
sudo setfacl -m u:sddm:x "$HOME"
```

This does not let SDDM list or read the contents of the home directory; it only
allows access to paths whose names are already known. The directories below the
home directory must also be traversable, and the QML, configuration, and wallpaper
files themselves must be readable. The repository defaults should satisfy this,
but they can be repaired with:

```sh
chmod 0755 "$HOME/.config/quickshell" \
    "$HOME/.config/quickshell/sddm" \
    "$HOME/.config/quickshell/sddm/themes" \
    "$HOME/.config/quickshell/sddm/themes/simple" \
    "$HOME/.config/quickshell/wallpapers"
chmod 0644 "$HOME/.config/quickshell/sddm/themes/simple/"*.qml \
    "$HOME/.config/quickshell/sddm/themes/simple/metadata.desktop" \
    "$HOME/.config/quickshell/sddm/themes/simple/theme.conf" \
    "$HOME/.config/quickshell/wallpapers/"*
```

`scripts/set-sddm-theme` writes the generated `theme.conf` with mode `0644`.
This is important because `mktemp` creates files with mode `0600` by default,
which works in the user-run preview but prevents the real greeter from reading
theme changes.

Verify the effective setup with:

```sh
namei -l /usr/share/sddm/themes/simple/Login.qml
getfacl "$HOME"
stat -c '%a %n' "$HOME/.config/quickshell/sddm/themes/simple/theme.conf"
```

The final command should report mode `644`.

Then create or edit `/etc/sddm.conf.d/theme.conf`:

```ini
[Theme]
Current=simple
```

Restart SDDM or reboot to apply it. Later palette changes are written immediately,
but an already running greeter reads them on its next start. Keep another terminal
session available when testing display-manager changes so you can revert the
configuration if needed.

## Customize

`ThemeManager` regenerates `theme.conf` whenever the active Quickshell theme
changes. The palette is mapped as follows:

- background → login-screen background and card
- primary → accent and sign-in button
- secondary → muted text
- tertiary → error text
- default text → primary text
- wallpaper → full-screen login background
- font style → all login controls and labels

Eight-digit colors use `#AARRGGBB`; the generated card uses the background color
with a small amount of transparency.
