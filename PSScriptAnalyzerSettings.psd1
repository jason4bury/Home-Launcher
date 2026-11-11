# PSScriptAnalyzer settings for Home-Launcher.ps1 and Launcher-Engine.ps1.
# Build-Exe.cmd runs it on both. To run it by hand:
#   Invoke-ScriptAnalyzer -Path .\src\Home-Launcher.ps1 -Settings .\PSScriptAnalyzerSettings.psd1
@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        # Private GUI helpers inside one script, not exported cmdlets, so
        # -WhatIf/-Confirm support and singular nouns add nothing here.
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns'
    )
}
