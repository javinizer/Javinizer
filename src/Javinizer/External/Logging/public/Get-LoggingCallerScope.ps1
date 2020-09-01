<#
    .SYNOPSIS
        Returns the default caller scope
    .DESCRIPTION
        This function returns an int representing the scope where the invocation scope for the caller should be obtained from
    .EXAMPLE
        PS C:\> Get-LoggingCallerScope
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Get-LoggingCallerScope.md
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md
    .LINK
        https://logging.readthedocs.io/en/latest/LoggingFormat.md
    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingCallerScope.ps1
#>
function Get-LoggingCallerScope {
    [CmdletBinding()]
    param()

    return $Script:Logging.CallerScope
}