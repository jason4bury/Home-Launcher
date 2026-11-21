# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), with versions numbered
`<major>.<minor>` and a two-digit minor (v1.00, v1.01 ... v1.10) to match the release names.

## [Unreleased]

## [1.10] - 2026-11-21

### Changed
- **New sections.** The tools are grouped as **Media**, **Docker**, **Utilities**
  and **Private** (still hidden until unlocked). Private tools that belong to the other sections show
  there once unlocked. Each tool's section is the `Category` in its own `launcher.json`.
- **Media Share Mapper** is shown again (under Utilities), and the **Standards Checker** from
  `E:\Created\_shared` is listed under Utilities.

### Added
- **Tabs.** Each section has a tab along the top with its tool count; click one to show its tools.
  The launcher remembers the tab.
- **View** switches between the tiles and a compact list, and is remembered.
- While you search, matches from every section show, and each tab gives its number of matches.
- **Wider, shorter window**: 1400 by 740, centred on the screen, so a full section of tiles fits
  without scrolling (set by `WindowWidth` and `WindowHeight` in the profile).
- Built with Launcher Engine 1.10.

## [1.09] - 2026-11-20

### Fixed
- The **Unlock** (and Set or Change password) box now follows the look: in the dark look its body
  and password field are dark, not white. Built with Launcher Engine 1.09.

## [1.08] - 2026-11-20

### Fixed
- **Blank icon.** The icon file held only compressed (PNG) pictures, which Windows' taskbar and
  shortcut showed as blank at small sizes. It now has standard pictures at every small size
  (16 to 64 pixels) and a PNG only at 256, so the house icon shows on the taskbar, the shortcut
  and the Start menu.

## [1.07] - 2026-11-19

### Changed
- **Search box.** A rounded field with a magnifier icon, a blue ring while you type and a small **x**
  to clear it, in the light and dark looks. Built with Launcher Engine 1.08.

## [1.06] - 2026-11-19

### Changed
- **Slim scrollbar.** The tool list scrolls with a thin rounded handle and no arrow buttons, instead
  of Windows' grey scrollbar. It widens a little on hover and follows the light and dark looks.
  Built with Launcher Engine 1.07.

## [1.05] - 2026-11-19

### Added
- **Dark look.** A **Look** button in the header cycles **Light** (as before, and the default),
  **Dark** and **Auto** (the same as Windows); the new look is used the next time the launcher
  starts. The blue header and orange category bars stay; tiles, bars, buttons and the message and
  password boxes go dark, with a dark title bar.
- **Help.** A **Help** button (or F1) explains starting and finding tools, the buttons on each
  tile, the tools folder, the look and the keys.
- About notes what's new in 1.05.
- Built on Launcher Engine v1.06, which has the dark look and Help. The launcher says so if it
  finds an older engine.

## [1.04] - 2026-11-19

### Changed
- **Messages and questions in the launcher's own look.** Warnings, the "still running from
  the vault" question and the About box open in a Home Launcher window (the blue header band
  with a coloured badge, the light page and the rounded launcher buttons) instead of
  Windows' plain grey message box. Their text can be selected and copied.
- Locking while a private tool is still running asks **Lock the vault** or **Leave it
  unlocked** instead of Yes and No.
- About notes what's new in 1.04.
- Built on Launcher Engine v1.05, which has the new message box. The launcher says so if it
  finds an older engine.
- Unchanged: the box shown if the launcher can't start or can't find its engine.

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
