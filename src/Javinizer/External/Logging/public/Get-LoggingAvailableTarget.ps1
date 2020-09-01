<#
    .SYNOPSIS
        Returns available logging targets
    .DESCRIPTION
        This function returns available logging targtes
    .EXAMPLE
        PS C:\> Get-LoggingAvailableTarget
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Get-LoggingAvailableTarget.md
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md
    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingAvailableTarget.ps1
#>
function Get-LoggingAvailableTarget {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Get-LoggingAvailableTarget.md')]
    param()

    return $Script:Logging.Targets
}