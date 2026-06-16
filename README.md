# Quickshell UI

A personal [Quickshell](https://quickshell.outfoxxed.me/) configuration for a Hyprland-based desktop.

This setup is currently developed on CachyOS, so it should be a reasonable fit for Arch-based systems. The project is still evolving, and the roadmap below tracks the rough order of planned work.

## Configuration

### Environment Variables

| Variable | Required | Description |
| --- | --- | --- |
| `QUICKSHELL_HOME` | No | Overrides the home directory used for external user config paths. Falls back to `HOME` when unset. |

Example:

```sh
export QUICKSHELL_HOME="$HOME"
```

### Helper Scripts

Quickshell-owned helper scripts live in `scripts/`:

- `scripts/set-wallpaper` updates Hyprpaper for every Hyprland monitor.
- `scripts/set-rofi-theme` updates the `@theme` entry in the Rofi config.
- `scripts/set-kitty-theme` updates Kitty's Quickshell-managed theme include.

## Project Status

### Completed

- [x] Theme manager singleton
- [x] Functional volume popup
- [x] Functional connection manager popup
- [x] Dotfile backup via GitHub repo
- [x] Improved timer styling

### In Progress / Planned

- [ ] ~~Application launcher popup~~ (accomplished this by styling Rofi)
- [ ] Current application display in the task bar
- [ ] System stats display
- [ ] Power button
- [ ] Calendar popup
- [ ] Shortcuts cheat sheet popup
- [ ] Theme changer popup improvements
- [ ] Transition effects and visual polish
- [ ] Notification manager
- [ ] Loading video while shell components initialize
- [ ] Audio player

## Roadmap Notes

### Application Launcher

The launcher may be handled by customizing Rofi instead of building a full native popup.

Potential native implementation:

- `applicationManager.qml`
  - Builds a list of applications
  - Tracks display name, icon, and optional launch command
- `applicationConfig.qml`
  - Displays available applications
  - Launches apps from icon clicks
  - Supports fuzzy filtering from a top search bar

### Current Application

This will probably use `hyprctl clients` to determine the active application.

### Shortcuts

The shortcuts popup could become dynamic by reading Hyprland configuration files.

### Theme Changer

Theme changes now update Quickshell, wallpaper, Rofi, and Kitty. Theme colors live in `config/themes.json`; Rofi and Kitty active theme files are generated under the user's config directory when a theme is applied. Helper scripts live under `scripts`.

### Visual Polish

Reference:

- <https://youtu.be/UBgjcSc9QOw?t=8068>
