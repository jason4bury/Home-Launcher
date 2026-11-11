<#
.SYNOPSIS
    Home Launcher - one window that lists and opens every Home tool.

.DESCRIPTION
    A thin wrapper around the shared Launcher Engine. It loads the engine
    and profile.home.json, works out where the launcher lives, and calls
    Start-Launcher. The engine finds the tools in the Home folder (the
    folder that holds Home-Launcher\) and shows them as tiles.

    Private tools in Home\Private\ stay hidden until Ctrl+Shift+U and the
    launcher password. If Home\_vault\Private.vhdx exists, the same
    password also unlocks that BitLocker vault (UAC prompt), and locking
    or closing the launcher locks it again.

    Running from source, the engine is loaded from
    E:\Created\_shared\Launcher-Engine\Source\src\Launcher-Engine.ps1
    (found relative to this script), or from a Launcher-Engine.ps1 placed
    next to this script. Build-Exe.cmd pastes the engine, the profile and
    the images into one script before compiling, so the exe needs nothing
    else.

.NOTES
    Author:    Jason Rhodes
    Copyright: (c) 2026 Jason Rhodes - MIT licence (see LICENSE)
    Version:   see $script:AppVersion below and CHANGELOG.md
    Works in Windows PowerShell 5.1 and PowerShell 7 (Windows).
#>

#Requires -Version 5.1

# ------------------------------------------------------------------------
#  App identity - set once here. The version matches the newest CHANGELOG
#  entry and the exe name ("Home Launcher v1.00.exe").
# ------------------------------------------------------------------------
$script:AppName      = 'Home Launcher'
$script:AppVersion   = '1.00'
$script:AppDate      = '2026-11-11'
$script:AppCopyright = 'Copyright (c) 2026 Jason Rhodes'

# Running as the compiled exe (ps2exe) rather than as a .ps1?
$script:IsExe = ([System.Diagnostics.Process]::GetCurrentProcess().ProcessName -notmatch '^(powershell|pwsh|powershell_ise)$')

# WPF needs a single-threaded apartment. powershell.exe and the exe (built
# with -STA) already are; relaunch anything else (e.g. some pwsh hosts).
if (-not $script:IsExe -and [System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    $winPs = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
    Start-Process -FilePath $winPs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-File', "`"$PSCommandPath`"")
    exit
}

#region BUNDLE-PROFILE (Build-Exe.cmd replaces this region with the profile and images)
$script:EmbeddedProfileJson = $null
$script:EmbeddedAssets      = @{}
#endregion BUNDLE-PROFILE

#region BUNDLE-ENGINE (Build-Exe.cmd replaces this region with Launcher-Engine.ps1 itself)
$script:EngineCandidates = @(
    $env:LAUNCHER_ENGINE,
    (Join-Path $PSScriptRoot 'Launcher-Engine.ps1'),
    # Source\src -> Source -> Home-Launcher -> Home -> Created
    (Join-Path $PSScriptRoot '..\..\..\..\_shared\Launcher-Engine\Source\src\Launcher-Engine.ps1')
) | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) }

if (-not $script:EngineCandidates) {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
        "Can't find Launcher-Engine.ps1.`n`nIt should be at E:\Created\_shared\Launcher-Engine\Source\src\, or next to this script.",
        $script:AppName, 'OK', 'Error') | Out-Null
    exit 1
}
. (@($script:EngineCandidates)[0])
#endregion BUNDLE-ENGINE

# ------------------------------------------------------------------------
#  Where am I? The launcher's project folder (Home\Home-Launcher\):
#    exe in  <project>\Builds\            -> <project>
#    exe anywhere else                    -> the exe's folder
#    script in <project>\Source\src\      -> <project>
#  The profile's Roots (".." = the Home folder), PrivateRoots and Vault
#  paths are relative to it.
# ------------------------------------------------------------------------
if ($script:IsExe) {
    $exeDir = Split-Path -Parent ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)
    $script:LauncherHome = if ((Split-Path -Leaf $exeDir) -eq 'Builds') { Split-Path -Parent $exeDir } else { $exeDir }
    $script:AssetPath = $null
} else {
    $script:LauncherHome = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
    $script:AssetPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\assets'))
}

# ------------------------------------------------------------------------
#  Profile: embedded in the exe, else profile.home.json next to this
#  script.
# ------------------------------------------------------------------------
try {
    if ($script:EmbeddedProfileJson) {
        $script:LauncherProfile = $script:EmbeddedProfileJson | ConvertFrom-Json
    } else {
        $profilePath = Join-Path $PSScriptRoot 'profile.home.json'
        $script:LauncherProfile = Get-Content -LiteralPath $profilePath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
} catch {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("Couldn't read profile.home.json:`n$($_.Exception.Message)",
        $script:AppName, 'OK', 'Error') | Out-Null
    exit 1
}

# The private lock needs engine v1.01 or later (an older copy of the engine
# would simply never show the private tools).
if ([version]$script:EngineVersion -lt [version]'1.01') {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("$script:AppName needs Launcher Engine v1.01 or later; this one is v$script:EngineVersion.`n`nUpdate E:\Created\_shared\Launcher-Engine\Source\.",
        $script:AppName, 'OK', 'Error') | Out-Null
    exit 1
}

try {
    Start-Launcher -LauncherProfile $script:LauncherProfile -LauncherHome $script:LauncherHome `
        -AppName $script:AppName -AppVersion $script:AppVersion -AppDate $script:AppDate `
        -AppCopyright $script:AppCopyright -Assets $script:EmbeddedAssets -AssetPath $script:AssetPath
} catch {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("$script:AppName stopped with an error:`n`n$($_.Exception.Message)",
        $script:AppName, 'OK', 'Error') | Out-Null
    exit 1
}
