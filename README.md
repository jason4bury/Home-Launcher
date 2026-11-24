<p align="center">
  <img src="assets/Home-Launcher.png" alt="Home Launcher icon" width="128">
</p>

# Home Launcher

One window that lists every Home tool, shows its version and opens it, its folder, its help guide or its GitHub repo.

![Version](https://img.shields.io/badge/version-v1.12-blue) ![Platform](https://img.shields.io/badge/platform-Windows-0078D6) ![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207-5391FE) ![Licence](https://img.shields.io/badge/licence-MIT-green) ![Last commit](https://img.shields.io/github/last-commit/jason4bury/Home-Launcher)

## ✨ Features

A PowerShell/WPF window built on the shared Launcher Engine. It looks in the Home folder, and in `Home\Private\` only once unlocked.

- **Finds the tools itself.** Every folder next to `Home-Launcher\` with a `Builds\` or `Source\` folder is a tool. A new tool appears on the next start (or F5) with nothing to register.
- **Sections**: Media, Docker, Utilities, and Private (once unlocked). Each section is a tab along the top, with its tool count; the launcher remembers the last tab. Each tool's section is the `Category` in its own `launcher.json`.
- **Tiles or a list.** **View** switches between tiles and a compact list with one row per tool. Each tile shows the tool's icon, name, version, last-updated date and one-line description, all read from the tool's own `build.json`, `CHANGELOG.md` and `README.md`.
- **Starts the right thing**: the tool's script release through `Builds\<App Name>.lnk` (made by its `Build.cmd`), else the newest `<App Name> v<version>.exe` in its `Builds\`, or the main script in `Source\src\` if there's no build yet. Tools that need admin rights, such as Winget Update Manager, say **Open as admin**; any other tool can be started with **Run as admin**.
- **Docker web apps** (MP3 Library, MP3 Playlist Editor, Music Video Cataloguer) open their page in the browser.
- **Quick links** on every tile: **Folder** (opens the project folder), **Help** (the help guide in `docs\`, or the README) and **GitHub** (the repo, taken from the tool's git settings).
- **Search** by name, description or section. While you search, matches from every section show, and each tab gives its number of matches. Enter starts the only match, Esc clears.
- **Private tools stay hidden.** Nothing in `Home\Private\` is shown until you press **Unlock** (or Ctrl+Shift+U) and type the launcher password. They hide again when you press **Lock** (the same button) or Ctrl+Shift+U, after 10 minutes without using the launcher, or when it closes.
- **Opens the vault.** Once `Home\_vault\Private.vhdx` exists, the same password also attaches and unlocks that BitLocker container, and locking or closing the launcher locks it again.
- No internet lookups, nothing installed, settings in `%APPDATA%`. No exe: the release is the script itself, with the engine and profile beside it.

## 🖼️ Screenshots

![Home Launcher main window](docs/screenshots/main-window.png)

## 📋 Requirements

- Windows 10 or 11 with Windows PowerShell 5.1 (or PowerShell 7).
- The Home tools in the house-style layout: `Home\<Tool>\Builds\` and `Home\<Tool>\Source\`, with private tools in `Home\Private\<Tool>\`.
- For the vault: Windows Pro or higher (BitLocker), and an administrator account to accept the UAC prompt.
- To run from the repo or build a release: the Launcher Engine (v1.04 or later) at `E:\Created\_shared\Launcher-Engine\Source\`. It is a private repo; each release carries a copy of it.

## 📦 Installation

1. Download `Home-Launcher-v1.12.zip` from the [latest release](../../releases/latest).
2. Right-click the zip, choose **Properties**, tick **Unblock** and click OK, *before* extracting it. Files from the internet carry Windows' Mark of the Web, which makes Windows warn about or block scripts.
3. Extract it into `Home\Home-Launcher\Builds\`. You get a `Home Launcher v1.12` folder, and from there the launcher finds the tools in `Home\` with no setup. Anywhere else, use **Tools folder...** once to point it at the Home folder.
4. Double-click **Home Launcher.cmd** in that folder. It makes a **Home Launcher** shortcut in the folder and in the Start menu, then starts the launcher.

From then on, start it from the shortcut or the Start menu, and pin it to the taskbar if you like: it starts without a console window and shows its own icon. For a new version, extract it and run its Home Launcher.cmd once; the Start menu shortcut then points at the new folder. Settings are kept in `%APPDATA%\Home Launcher`, so they carry over.

**From the repo:** clone this repo into `Home\Home-Launcher\Source\` and the Launcher Engine into `E:\Created\_shared\Launcher-Engine\Source\`, then double-click **Start Home Launcher.cmd** (add `debug` to keep a console open and see any errors).

### Why no exe?

Up to v1.01 the Home Launcher shipped as an exe made with [PS2EXE](https://github.com/MScholtes/PS2EXE). Antivirus programs (ESET among them) kept flagging PS2EXE exes as trojans by mistake, because PS2EXE wraps a script the way some malware does. The launcher is a script anyway, so it now ships as the script itself: nothing is compiled or packed, and you can read exactly what runs.

The shortcut runs `conhost.exe --headless powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "...\Home-Launcher.ps1"`. `--headless` stops Windows 11 opening a console window; on older Windows the shortcut runs PowerShell with `-WindowStyle Hidden` instead, so a console may flash for a moment. The execution-policy bypass applies to the launcher's own run only; no Windows settings are changed. The shortcut and the script share a taskbar ID (`jason4bury.Home-Launcher`), so the taskbar groups the launcher under its own icon rather than PowerShell's. A shortcut can only hold a full path, which is why Home Launcher.cmd makes it on your PC instead of it coming in the zip.

### Build a release

Double-click **Build.cmd** in the repo folder. It reads `build.json`, checks every script in `src\` parses and that `$script:AppVersion` matches the newest `CHANGELOG.md` entry, and runs PSScriptAnalyzer if it's installed. Then it makes `..\Builds\Home Launcher v<version>\` with the launcher, `profile.home.json`, the Launcher Engine (copied from `E:\Created\_shared\Launcher-Engine\Source\src\`) and the icons, zips it as `..\Builds\Home-Launcher-v<version>.zip` (both outside the repo), refreshes `..\Builds\Home Launcher.lnk`, and scans the lot with ESET's command-line scanner (`ecls.exe`) if it's installed. Everything it shows is also in `Build.log`. Older release folders stay alongside.

## 🚀 Usage

Start the launcher from its shortcut or the Start menu (or **Home Launcher.cmd**). Double-click a tile or press **Open** to start a tool. The status bar says what was started, and the About box shows the version, the folder being scanned and the shortcuts. **Exit** closes the launcher, locking any private tools first.

| Key | Does |
| --- | --- |
| Ctrl+F | Search |
| Enter | Start the only tool that matches the search |
| Esc | Clear the search |
| F5 | Look for tools again |
| Ctrl+Shift+U | Unlock the private tools, or lock them again |

### Private tools

The first time you press **Unlock** (or Ctrl+Shift+U) the launcher asks you to choose a password. After that it asks for it, the **Private** tab appears, **Unlock** becomes **Lock**, and a **Password...** button shows in the header. Only a salted PBKDF2-SHA256 hash of the password is saved. The password is a privacy curtain: anyone can still start a tool directly, so the real protection is the encrypted vault.

When `Home\_vault\Private.vhdx` exists and is locked, unlocking also shows a UAC prompt and opens the vault with the same password, so set the launcher password to match the vault's BitLocker password. Locking, 10 minutes idle or closing the launcher locks the vault again (another UAC prompt). If a private tool is still running from the vault, the launcher asks first, and an idle lock only hides the tiles.

To set up the vault, follow "Vault setup" in the Launcher & GitHub Standards Proposal.

## ⚙️ Configuration

`src\profile.home.json` sets what the launcher looks like and where it looks. Each release carries a copy beside `Home-Launcher.ps1`: change the one in `src\` and run Build.cmd, or edit the release's copy for a quick test.

| Setting | Does |
| --- | --- |
| `Name`, `Title`, `Subtitle` | Window and header text |
| `Roots` | Folders to scan, relative to the launcher's project folder (`".."` = the Home folder, `"..\\..\\_shared"` = `E:\Created\_shared` for the Standards Checker) |
| `Logo`, `Icon` | Images from `assets\` for the header and the window |
| `Theme` | `Accent`, `AccentText`, `Highlight` and `Background` colours |
| `Categories` | The order the sections (tabs) are shown in |
| `SectionTabs` | `true` shows the sections as tabs |
| `WindowWidth`, `WindowHeight` | Window size: 1400 by 740 |
| `DefaultCategory` | Section for tools that don't have one |
| `Exclude` | Folders to skip: the launcher itself, `Private` (scanned separately once unlocked) and the Launcher Engine (a library, not a tool) |
| `Tools` | Per-tool defaults by folder name, e.g. `"MP3-Library": { "Url": "http://localhost:3000" }` |
| `PrivateLock` | `true` turns on the Unlock/Lock button and Ctrl+Shift+U |
| `PrivateRoots` | Folders whose tools are all private (`..\Private`) |
| `PrivateCategory` | The section for private tools that don't name one |
| `IdleLockMinutes` | Minutes without use before private tools hide again (`0` = only on close) |
| `Vault` | `Image` (`..\_vault\Private.vhdx`) and `MountPath` (`..\Private`) |

Private tools are found by their folder, so their names are never in the profile. To rename a section, change `Category` in the tools' `launcher.json` files and the name in `Categories`. A tool can also carry its own `launcher.json` (in its project folder or `Source\`) to set `Name`, `Category`, `Description`, `Icon`, `Help`, `RequireAdmin`, `Private`, `Hidden`, `Target`, `RunMode` or `Url`. It wins over the profile. Tools with a script release need no `Target`: the launcher finds `Builds\<App Name>.lnk` by itself.

Settings saved on the PC are in `%APPDATA%\Home Launcher\settings.json`: the folder chosen with **Tools folder...**, the look, the view, the last tab and the password hash. Delete the file to go back to the default folder and choose a new password.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md).

## 📄 Licence

MIT, see [LICENSE](LICENSE). Copyright (c) 2026 Jason Rhodes.
