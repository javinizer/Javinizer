<#
    .SYNOPSIS
        Returns the default message level

    .DESCRIPTION
        This function returns a string representing the default message level used by enabled targets that don't override it

    .EXAMPLE
        PS C:\> Get-LoggingDefaultLevel

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Get-LoggingDefaultLevel.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingDefaultLevel.ps1
#>
function Get-LoggingDefaultLevel {
    [CmdletBinding(HelpUri = 'https://logging.readthedocs.io/en/latest/functions/Get-LoggingDefaultLevel.md')]
    param()

    return Get-LevelName -Level $Script:Logging.LevelNo
}
