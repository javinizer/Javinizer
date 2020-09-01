<#
    .SYNOPSIS
        Returns enabled logging targets
    .DESCRIPTION
        This function returns enabled logging targtes
    .PARAMETER Name
        The Name of the target to retrieve, if not passed all configured targets will be returned
    .EXAMPLE
        PS C:\> Get-LoggingTarget
    .EXAMPLE
        PS C:\> Get-LoggingTarget -Name Console
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Get-LoggingTarget.md
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md
    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingTarget.ps1
#>
function Get-LoggingTarget {
    [CmdletBinding(HelpUri = 'https://logging.readthedocs.io/en/latest/functions/Get-LoggingTarget.md')]
    param(
        [string] $Name = $null
    )

    if ($PSBoundParameters.Name) {
        return $Script:Logging.EnabledTargets[$Name]
    }

    return $Script:Logging.EnabledTargets
}
