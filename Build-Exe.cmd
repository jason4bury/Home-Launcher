<# : batch part - runs the PowerShell part below. Just double-click this file.
@echo off
setlocal
set "BUILD_DIR=%~dp0"
set "BUILD_FILE=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ([IO.File]::ReadAllText($env:BUILD_FILE))"
set "BUILD_RESULT=%ERRORLEVEL%"
echo.
pause
exit /b %BUILD_RESULT%
: end of batch part #>

# ===========================================================================
# Build-Exe.cmd - bundles and compiles the Home Launcher into
# "..\Builds\Home Launcher v<version>.exe".
#
# Interim: once E:\Created\_shared\Build-Tool.ps1 is in place it replaces this
# file (it reads build.json instead). Until then, this builds the same way.
#
# Double-click this file (no admin rights needed). It:
#   1. finds the shared engine at
#      E:\Created\_shared\Launcher-Engine\Source\src\Launcher-Engine.ps1
#      (relative to this folder; set LAUNCHER_ENGINE to use another copy),
#   2. checks $script:AppVersion matches the newest CHANGELOG entry and
#      the engine is v1.01 or later (the private-tool lock needs it),
#   3. runs PSScriptAnalyzer on the wrapper and the engine if it's installed
#      (stops on errors, shows warnings),
#   4. writes one bundled script to %TEMP%: the wrapper with the engine,
#      profile.home.json and the logo/icon pasted in, so the exe needs
#      no other files,
#   5. installs ps2exe for the current user if it's missing, then compiles
#      the bundle with -STA -noConsole and the icon into the project's
#      Builds folder (next to Source, outside the repo).
#
# The exe is NOT signed here - the shared build script will do that. If
# antivirus flags the unsigned exe, report a false positive or add an
# exclusion rather than turning protection off.
# Everything shown on screen is also written to Build-Exe.log (gitignored).
# ===========================================================================

$ErrorActionPreference = 'Stop'

# Started from a PowerShell 7 window, Windows PowerShell inherits pwsh's
# module path and can load the wrong PSScriptAnalyzer/ps2exe. Use its own.
$env:PSModulePath = @(
    (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Modules'),
    (Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules'),
    [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')
) -join ';'

$here       = if ($env:BUILD_DIR) { $env:BUILD_DIR.TrimEnd('\') } else { (Get-Location).Path }
$wrapper    = Join-Path $here 'src\Home-Launcher.ps1'
$profileJs  = Join-Path $here 'src\profile.home.json'
$assetsDir  = Join-Path $here 'assets'
$iconPath   = Join-Path $assetsDir 'Home-Launcher.ico'
$changelog  = Join-Path $here 'CHANGELOG.md'
$buildsDir  = Join-Path (Split-Path -Parent $here) 'Builds'
$logPath    = Join-Path $here 'Build-Exe.log'
$bundlePath = Join-Path $env:TEMP 'Home-Launcher.bundle.ps1'
$failed     = $false

try { Start-Transcript -LiteralPath $logPath -Force | Out-Null } catch { Write-Verbose 'No transcript.' }

function Set-Region {
    <# Replaces "#region <Name> ... #endregion <Name>" in $Text with $Body. #>
    param([string]$Text, [string]$Name, [string]$Body)
    $start = $Text.IndexOf("#region $Name")
    $endTag = "#endregion $Name"
    $end = $Text.IndexOf($endTag)
    if ($start -lt 0 -or $end -lt $start) { throw "Couldn't find the $Name region in Home-Launcher.ps1." }
    return $Text.Substring(0, $start) + $Body + $Text.Substring($end + $endTag.Length)
}

try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

    foreach ($f in $wrapper, $profileJs) {
        if (-not (Test-Path -LiteralPath $f)) { throw "Missing file: $f" }
    }

    # --- 1. Engine ---
    $engineCandidates = @(
        $env:LAUNCHER_ENGINE,
        (Join-Path $here '..\..\..\_shared\Launcher-Engine\Source\src\Launcher-Engine.ps1')
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) }
    if (-not $engineCandidates) {
        throw "Can't find Launcher-Engine.ps1. Expected E:\Created\_shared\Launcher-Engine\Source\src\Launcher-Engine.ps1, or set LAUNCHER_ENGINE to its path."
    }
    $enginePath = (Resolve-Path -LiteralPath @($engineCandidates)[0]).ProviderPath
    $engineText = [IO.File]::ReadAllText($enginePath)
    $engineVer  = if ($engineText -match "EngineVersion\s*=\s*'([^']+)'") { $Matches[1] } else { '0.00' }
    if ([version]$engineVer -lt [version]'1.01') {
        throw "The engine at $enginePath is v$engineVer. The Home Launcher needs v1.01 or later (the private-tool lock)."
    }

    # --- 2. Version ---
    $wrapperText = [IO.File]::ReadAllText($wrapper)
    if ($wrapperText -notmatch "AppVersion\s*=\s*'(\d+\.\d{2})'") {
        throw "Couldn't find `$script:AppVersion = '<major>.<two-digit minor>' in $wrapper."
    }
    $version = $Matches[1]
    $appName = if ($wrapperText -match "AppName\s*=\s*'([^']+)'") { $Matches[1] } else { 'Home Launcher' }

    $logVersion = $null
    foreach ($line in [IO.File]::ReadAllLines($changelog)) {
        if ($line -match '^##\s*\[(\d+\.\d+)\]') { $logVersion = $Matches[1]; break }
    }
    if ($logVersion -ne $version) {
        throw "The script says v$version but the newest CHANGELOG entry is v$logVersion. Make them match first."
    }

    Write-Host "Building $appName v$version.exe (Launcher Engine v$engineVer)" -ForegroundColor Cyan
    Write-Host "  Wrapper: $wrapper"
    Write-Host "  Engine:  $enginePath"
    Write-Host ''

    # --- 3. PSScriptAnalyzer (if installed) ---
    if (Get-Module -ListAvailable -Name PSScriptAnalyzer) {
        Write-Host 'Running PSScriptAnalyzer...' -ForegroundColor Cyan
        $settings = Join-Path $here 'PSScriptAnalyzerSettings.psd1'
        $results = @(foreach ($f in $wrapper, $enginePath) { Invoke-ScriptAnalyzer -Path $f -Settings $settings })
        $results | Format-Table -AutoSize Severity, RuleName, ScriptName, Line, Message | Out-String -Width 200 | Write-Host
        if (@($results | Where-Object Severity -eq 'Error').Count -gt 0) { throw 'PSScriptAnalyzer found errors (see above).' }
        if ($results.Count -eq 0) { Write-Host '  No problems found.' }
        Write-Host ''
    } else {
        Write-Warning 'PSScriptAnalyzer is not installed - skipping static analysis.'
    }

    # --- 4. Bundle ---
    $profileText = [IO.File]::ReadAllText($profileJs)
    $null = $profileText | ConvertFrom-Json      # fail now if the JSON is broken
    if ($profileText -match "(?m)^'@") { throw "profile.home.json can't contain a line starting with '@." }
    $profileObj = $profileText | ConvertFrom-Json

    $assetLines = New-Object System.Collections.Generic.List[string]
    $embedded = @{}
    foreach ($key in 'Logo', 'Icon') {
        $file = $profileObj.$key
        if (-not $file -or $embedded.ContainsKey($file)) { continue }   # Logo and Icon can be the same file
        $embedded[$file] = $true
        $p = Join-Path $assetsDir $file
        if (Test-Path -LiteralPath $p) {
            $assetLines.Add("    '$file' = '$([Convert]::ToBase64String([IO.File]::ReadAllBytes($p)))'")
        } else {
            Write-Warning "Profile $key '$file' not found in assets\ - the exe will show without it."
        }
    }
    $profileRegion = @(
        '# Embedded by Build-Exe.cmd',
        '$script:EmbeddedProfileJson = @''',
        $profileText.TrimEnd(),
        '''@',
        '$script:EmbeddedAssets = @{',
        ($assetLines -join "`r`n"),
        '}'
    ) -join "`r`n"
    $engineRegion = "# ---- Launcher Engine v$engineVer, pasted in by Build-Exe.cmd ----`r`n" + $engineText.TrimEnd() + "`r`n# ---- end of Launcher Engine ----"

    $bundle = Set-Region $wrapperText 'BUNDLE-PROFILE' $profileRegion
    $bundle = Set-Region $bundle 'BUNDLE-ENGINE' $engineRegion
    [IO.File]::WriteAllText($bundlePath, $bundle, (New-Object System.Text.UTF8Encoding($true)))

    # Make sure the bundle parses before handing it to ps2exe
    $tokens = $null; $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($bundlePath, [ref]$tokens, [ref]$parseErrors) | Out-Null
    if ($parseErrors.Count -gt 0) { throw "The bundled script doesn't parse: $($parseErrors[0].Message) (line $($parseErrors[0].Extent.StartLineNumber) of $bundlePath)" }

    # --- 5. Compile ---
    $parts = $version.Split('.')
    $fileVersion = '{0}.{1}.0.0' -f [int]$parts[0], [int]$parts[1]
    if (-not (Test-Path -LiteralPath $buildsDir)) { New-Item -ItemType Directory -Path $buildsDir -Force | Out-Null }
    $outputPath = Join-Path $buildsDir "$appName v$version.exe"

    if (-not (Get-Module -ListAvailable -Name ps2exe)) {
        Write-Host 'ps2exe module not found - installing for the current user (one-time)...' -ForegroundColor Cyan
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        } catch { Write-Verbose 'TLS 1.2 already on.' }
        if (-not (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue |
                  Where-Object { $_.Version -ge [version]'2.8.5.201' })) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null
        }
        Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
    }
    Import-Module ps2exe

    $appArgs = @{
        inputFile    = $bundlePath
        outputFile   = $outputPath
        STA          = $true
        noConsole    = $true
        noConfigFile = $true
        title        = $appName
        description  = $appName
        product      = $appName
        version      = $fileVersion
        company      = 'Jason Rhodes'
        copyright    = 'Copyright (c) 2026 Jason Rhodes'
    }
    if (Test-Path -LiteralPath $iconPath) { $appArgs['iconFile'] = $iconPath }
    else { Write-Warning "Icon not found at $iconPath - building without it." }
    Invoke-ps2exe @appArgs

    if (-not (Test-Path -LiteralPath $outputPath)) {
        throw "ps2exe didn't report an error, but $outputPath wasn't created."
    }
    Remove-Item -LiteralPath $bundlePath -Force -ErrorAction SilentlyContinue
    Write-Host ''
    Write-Host "Done: $outputPath" -ForegroundColor Green
} catch {
    $failed = $true
    Write-Host ''
    Write-Host "Build failed: $($_.Exception.Message)" -ForegroundColor Red
}

try { Stop-Transcript | Out-Null } catch { Write-Verbose 'No transcript.' }

if ($failed) { [Environment]::Exit(1) }
