<#
    .SYNOPSIS
        Sets a global logging severity level.

    .DESCRIPTION
        This function sets a global logging severity level.
        Log messages written with a lower logging level will be discarded.

    .PARAMETER Level
        The level severity name to set as default for enabled targets

    .EXAMPLE
        PS C:\> Set-LoggingDefaultLevel -Level ERROR

        PS C:\> Write-Log -Level INFO -Message "Test"
        => Discarded.

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Set-LoggingDefaultLevel.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingDefaultLevel.ps1
#>
function Set-LoggingDefaultLevel {
    [CmdletBinding(HelpUri = 'https://logging.readthedocs.io/en/latest/functions/Set-LoggingDefaultLevel.md')]
    param()

    DynamicParam {
        New-LoggingDynamicParam -Name "Level" -Level
    }

    End {
        $Script:Logging.Level = $PSBoundParameters.Level
        $Script:Logging.LevelNo = Get-LevelNumber -Level $PSBoundParameters.Level

        # Setting level on already configured targets
        foreach ($Target in $Script:Logging.EnabledTargets.Values) {
            if ($Target.ContainsKey('Level')) {
                $Target['Level'] = $Script:Logging.Level
            }
        }

        # Setting level on available targets
        foreach ($Target in $Script:Logging.Targets.Values) {
            if ($Target.Defaults.ContainsKey('Level')) {
                $Target.Defaults.Level.Default = $Script:Logging.Level
            }
        }
    }
}
