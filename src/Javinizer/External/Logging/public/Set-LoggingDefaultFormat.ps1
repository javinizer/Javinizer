<#
    .SYNOPSIS
        Sets a global logging message format

    .DESCRIPTION
        This function sets a global logging message format

    .PARAMETER Format
        The string used to format the message to log

    .EXAMPLE
        PS C:\> Set-LoggingDefaultFormat -Format '[%{level:-7}] %{message}'

    .EXAMPLE
        PS C:\> Set-LoggingDefaultFormat

        It sets the default format as [%{timestamp:+%Y-%m-%d %T%Z}] [%{level:-7}] %{message}

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Set-LoggingDefaultFormat.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/LoggingFormat.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingDefaultFormat.ps1
#>
function Set-LoggingDefaultFormat {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Set-LoggingDefaultFormat.md')]
    param(
        [string] $Format = $Defaults.Format
    )

    Wait-Logging
    $Script:Logging.Format = $Format

    # Setting format on already configured targets
    foreach ($Target in $Script:Logging.EnabledTargets.Values) {
        if ($Target.ContainsKey('Format')) {
            $Target['Format'] = $Script:Logging.Format
        }
    }

    # Setting format on available targets
    foreach ($Target in $Script:Logging.Targets.Values) {
        if ($Target.Defaults.ContainsKey('Format')) {
            $Target.Defaults.Format.Default = $Script:Logging.Format
        }
    }
}
