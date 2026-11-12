# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), with versions numbered
`<major>.<minor>` and a two-digit minor (v1.00, v1.01 ... v1.10) to match the exe file names.

## [Unreleased]

## [1.01] - 2026-11-12

### Added
- **Exit** button in the header, next to **About**, to close the launcher. Private tools
  and the vault are still locked on the way out.

### Changed
- Built on Launcher Engine v1.02; `Build-Exe.cmd` now needs v1.02 or later.

## [1.00] - 2026-11-11
First release.

### Added
- One window that lists every Home tool as a tile, grouped by category (Films and TV,
  Music, Windows), with a search box.
- Each tile shows the tool's icon, name, version and last-updated date (read from its
  CHANGELOG) and the tagline from its README, with buttons for **Open**, **Run as admin**,
  **Folder**, **Help** (the help guide in `docs\`, or the README) and **GitHub** (read
  from the repo's git settings; nothing is looked up online).
- Finds the tools itself: every folder in `Home\` with a `Builds\` or `Source\` folder.
  It starts the newest `<App Name> v<version>.exe` in `Builds\`, or the main script in
  `Source\src\` if there is no build yet. Winget Update Manager shows **Open as admin**.
- The Docker web apps (MP3 Library, MP3 Playlist Editor, Music Video Cataloguer) open
  their page in the browser (`localhost` ports 3000, 3002 and 3001).
- **Private tools**: everything in `Home\Private\` stays hidden, with no hint it exists,
  until Ctrl+Shift+U and the launcher password (chosen the first time). **Lock**, the same
  keys, 10 minutes without use or closing the launcher hides them again, and
  **Password...** changes the password. Only a salted hash is saved.
- **Vault support**: once `Home\_vault\Private.vhdx` exists, unlocking also attaches and
  unlocks it with the same password (UAC prompt), and locking or closing locks it again.
- **Tools folder...** to point the launcher at another folder, and **Refresh** (F5).
  Settings are in `%APPDATA%\Home Launcher\settings.json`.
- Keyboard: Ctrl+F search, Enter starts the only match, Esc clears, double-click a tile
  to start it.
- `profile.home.json` holds the name, colours, logo, categories, web-app addresses and
  the folders to scan. Private tools are found by folder, never named in it.
- `Build-Exe.cmd` bundles the wrapper, the shared Launcher Engine (v1.01 or later), the
  profile and the icon into one self-contained `Home Launcher v<version>.exe`.
- Home Launcher icon (a house holding a grid of tiles).
