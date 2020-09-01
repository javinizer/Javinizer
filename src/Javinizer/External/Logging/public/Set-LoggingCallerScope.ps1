<#
    .SYNOPSIS
        Sets the scope from which to get the caller scope

    .DESCRIPTION
        This function sets the scope to obtain information from the caller

    .PARAMETER CallerScope
        Integer representing the scope to use to find the caller information. Defaults to 1 which represent the scope of the function where Write-Log is being called from

    .EXAMPLE
        PS C:\> Set-LoggingCallerScope -CallerScope 2

    .EXAMPLE
        PS C:\> Set-LoggingCallerScope

        It sets the caller scope to 1

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Set-LoggingCallerScope.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingCallerScope.ps1
#>
function Set-LoggingCallerScope {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Set-LoggingCallerScope.md')]
    param(
        [int]$CallerScope = $Defaults.CallerScope
    )

    Wait-Logging
    $Script:Logging.CallerScope = $CallerScope
}
