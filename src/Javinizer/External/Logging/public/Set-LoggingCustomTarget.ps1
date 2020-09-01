<#
    .SYNOPSIS
        Sets a folder as custom target repository

    .DESCRIPTION
        This function sets a folder as a custom target repository.
        Every *.ps1 file will be loaded as a custom target and available to be enabled for logging to.

    .PARAMETER Path
        A valid path containing *.ps1 files that defines new loggin targets

    .EXAMPLE
        PS C:\> Set-LoggingCustomTarget -Path C:\Logging\CustomTargets

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Set-LoggingCustomTarget.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/CustomTargets.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingCustomTarget.ps1
#>
function Set-LoggingCustomTarget {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Set-LoggingCustomTarget.md')]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string] $Path
    )

    Write-Verbose 'Stopping Logging Manager'
    Stop-LoggingManager

    $Script:Logging.CustomTargets = $Path

    Write-Verbose 'Starting Logging Manager'
    Start-LoggingManager
}
