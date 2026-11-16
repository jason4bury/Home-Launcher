# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), with versions numbered
`<major>.<minor>` and a two-digit minor (v1.00, v1.01 ... v1.10) to match the release names.

## [Unreleased]

## [1.03] - 2026-11-16

### Changed
- **Better-looking OK and Cancel buttons** in the Unlock, Set a password and Change
  password boxes: rounded, a little bigger, OK in the launcher's blue and Cancel as a quiet
  white button, with hover, pressed and focus states like the rest of the launcher. Enter
  is OK and Esc is Cancel, as before.
- Built on Launcher Engine v1.04, which has the new dialog buttons. The launcher says so
  if it finds an older engine.

## [1.02] - 2026-11-16

### Changed
- **No exe any more.** Antivirus (ESET among others) kept flagging the PS2EXE exes as
  trojans by mistake, so the Home Launcher now ships as its script, like Homelab. The
  release is a `Home Launcher v1.02` folder (and `Home-Launcher-v1.02.zip`) holding
  `Home-Launcher.ps1`, the Launcher Engine, `profile.home.json` and the icons.
  **Home Launcher.cmd** makes a **Home Launcher** shortcut there and in the Start menu,
  which starts it without a console window and with its own taskbar icon
  (`jason4bury.Home-Launcher`).
- Built on Launcher Engine v1.03, so tiles start the other Home tools' script releases
  through their `Builds\<App Name>.lnk` as each tool moves off its exe. The launcher says
  so if it finds an older engine.
- `Build.cmd` replaces `Build-Exe.cmd`: it copies the release files, zips them, makes
  `Builds\Home Launcher.lnk` and scans the result with ESET's command-line scanner.
- The project folder is worked out from the script's place (`Builds\<release>\` or
  `Source\src\`), and images load from `assets\` beside the script.

### Fixed
- Started from a host that isn't single-threaded (some PowerShell 7 windows), the
  launcher restarted itself with a console window showing. It now restarts hidden.

### Removed
- `Build-Exe.cmd` and the code that only the exe used (bundled engine, profile and images).

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
