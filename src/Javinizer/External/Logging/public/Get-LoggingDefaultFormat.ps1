<#
    .SYNOPSIS
        Returns the default message format
    .DESCRIPTION
        This function returns a string representing the default message format used by enabled targets that don't override it
    .EXAMPLE
        PS C:\> Get-LoggingDefaultFormat
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Get-LoggingDefaultFormat.md
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md
    .LINK
        https://logging.readthedocs.io/en/latest/LoggingFormat.md
    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingDefaultFormat.ps1
#>
function Get-LoggingDefaultFormat {
    [CmdletBinding()]
    param()

    return $Script:Logging.Format
}