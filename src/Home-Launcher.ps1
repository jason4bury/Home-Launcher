<#
.SYNOPSIS
    Home Launcher - one window that lists and opens every Home tool.

.DESCRIPTION
    A thin wrapper around the shared Launcher Engine. It loads the engine
    and profile.home.json, works out where the launcher lives, and calls
    Start-Launcher. The engine finds the tools in the Home folder (the
    folder that holds Home-Launcher\) and shows them as tiles.

    Private tools in Home\Private\ stay hidden until Unlock (or Ctrl+Shift+U) and the
    launcher password. If Home\_vault\Private.vhdx exists, the same
    password also unlocks that BitLocker vault (UAC prompt), and locking
    or closing the launcher locks it again.

    No exe: the launcher ships as this script. Build.cmd copies it, the
    engine (Launcher-Engine.ps1), profile.home.json and assets\ into
    Builds\Home Launcher v<version>\, and the "Home Launcher" shortcut
    starts it without a console window. Running from the repo, the engine
    is loaded from E:\Created\_shared\Launcher-Engine\Source\src\ (found
    relative to this script), or from a Launcher-Engine.ps1 placed next
    to this script.

    Project layout (house style):
        <project>\Source\               the git repo (this script is in Source\src\)
        <project>\Source\assets\        icon (.ico) and logo (.png)
        <project>\Builds\               "Home Launcher v<version>\" release folders, their
                                        zips and "Home Launcher.lnk", made by Build.cmd
    Settings: %APPDATA%\Home Launcher\settings.json

.NOTES
    Author:    Jason Rhodes
    Copyright: (c) 2026 Jason Rhodes - MIT licence (see LICENSE)
    Version:   see $script:AppVersion below and CHANGELOG.md
    Works in Windows PowerShell 5.1 and PowerShell 7 (Windows).
#>

#Requires -Version 5.1

# ------------------------------------------------------------------------
#  App identity - set once here. The version matches the newest CHANGELOG
#  entry and the release folder ("Home Launcher v1.03").
# ------------------------------------------------------------------------
$script:AppName      = 'Home Launcher'
$script:AppVersion   = '1.12'
$script:AppDate      = '2026-11-24'
$script:AppCopyright = 'Copyright (c) 2026 Jason Rhodes'
$script:AppId        = 'jason4bury.Home-Launcher'   # taskbar ID; New-HomeLauncherShortcut.ps1 uses the same one
$script:MinEngine    = '1.11'                       # the Unlock/Lock button
$script:AppNote      = "New in 1.12: Container Dashboard Status in the Docker tab, opening http://localhost:3040."

# WPF needs a single-threaded apartment. The shortcut and powershell.exe
# -STA already are; relaunch anything else (e.g. some pwsh hosts), hidden.
if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    $winPs = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    Start-Process -FilePath $winPs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-WindowStyle', 'Hidden', '-File', "`"$PSCommandPath`"")
    exit
}

# One taskbar button with the launcher's own icon (not PowerShell's), and
# pinning it pins the launcher.
try {
    Add-Type -Namespace 'HomeTool' -Name 'Shell' -MemberDefinition '[DllImport("shell32.dll", CharSet = CharSet.Unicode)] public static extern int SetCurrentProcessExplicitAppUserModelID(string appId);'
    [void][HomeTool.Shell]::SetCurrentProcessExplicitAppUserModelID($script:AppId)
} catch { Write-Verbose "No taskbar ID: $($_.Exception.Message)" }

function Show-StartupError {
    <# A message box for problems before the window opens (no console to show them in). #>
    param([string]$Message)
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($Message, $script:AppName, 'OK', 'Error') | Out-Null
}

# ------------------------------------------------------------------------
#  Launcher Engine: LAUNCHER_ENGINE if set, else Launcher-Engine.ps1 next
#  to this script (a release folder), else the shared repo copy.
# ------------------------------------------------------------------------
$script:EngineCandidates = @(
    $env:LAUNCHER_ENGINE,
    (Join-Path $PSScriptRoot 'Launcher-Engine.ps1'),
    # Source\src -> Source -> Home-Launcher -> Home -> Created
    (Join-Path $PSScriptRoot '..\..\..\..\_shared\Launcher-Engine\Source\src\Launcher-Engine.ps1')
) | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) }

if (-not $script:EngineCandidates) {
    Show-StartupError "Can't find Launcher-Engine.ps1.`n`nIt should be next to this script (in a release folder), or at E:\Created\_shared\Launcher-Engine\Source\src\."
    exit 1
}
. (@($script:EngineCandidates)[0])

if ([version]$script:EngineVersion -lt [version]$script:MinEngine) {
    Show-StartupError "$script:AppName needs Launcher Engine v$script:MinEngine or later; this one is v$script:EngineVersion.`n`nUpdate E:\Created\_shared\Launcher-Engine\Source\ and run Build.cmd again."
    exit 1
}

# ------------------------------------------------------------------------
#  Where am I? The launcher's project folder (Home\Home-Launcher\):
#    script in <project>\Builds\Home Launcher v<x.yy>\   -> <project>
#    script in <project>\Source\src\                     -> <project>
#    a release folder unpacked anywhere else             -> that folder
#  The profile's Roots (".." = the Home folder), PrivateRoots and Vault
#  paths are relative to it. Anywhere else, use Tools folder... once.
# ------------------------------------------------------------------------
$parentDir = Split-Path -Parent $PSScriptRoot
$script:LauncherHome = if (@('Builds', 'Source') -contains (Split-Path -Leaf $parentDir)) { Split-Path -Parent $parentDir } else { $PSScriptRoot }

# Images: assets\ beside the script (release), else Source\assets\ (repo).
$script:AssetPath = @((Join-Path $PSScriptRoot 'assets'), (Join-Path $parentDir 'assets')) |
    Where-Object { Test-Path -LiteralPath $_ -PathType Container } | Select-Object -First 1

# ------------------------------------------------------------------------
#  Profile: profile.home.json next to this script.
# ------------------------------------------------------------------------
try {
    $profilePath = Join-Path $PSScriptRoot 'profile.home.json'
    $script:LauncherProfile = Get-Content -LiteralPath $profilePath -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    Show-StartupError "Couldn't read profile.home.json:`n$($_.Exception.Message)"
    exit 1
}

try {
    Start-Launcher -LauncherProfile $script:LauncherProfile -LauncherHome $script:LauncherHome `
        -AppName $script:AppName -AppVersion $script:AppVersion -AppDate $script:AppDate `
        -AppCopyright $script:AppCopyright -AppNote $script:AppNote -AssetPath $script:AssetPath
} catch {
    Show-StartupError "$script:AppName stopped with an error:`n`n$($_.Exception.Message)"
    exit 1
}
