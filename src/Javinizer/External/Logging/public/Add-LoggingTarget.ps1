<#
    .SYNOPSIS
        Enable a logging target
    .DESCRIPTION
        This function configure and enable a logging target
    .PARAMETER Name
        The name of the target to enable and configure
    .PARAMETER Configuration
        An hashtable containing the configurations for the target
    .EXAMPLE
        PS C:\> Add-LoggingTarget -Name Console -Configuration @{Level = 'DEBUG'}
    .EXAMPLE
        PS C:\> Add-LoggingTarget -Name File -Configuration @{Level = 'INFO'; Path = 'C:\Temp\script.log'}
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Add-LoggingTarget.md
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md
    .LINK
        https://logging.readthedocs.io/en/latest/AvailableTargets.md
    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Add-LoggingTarget.ps1
#>
function Add-LoggingTarget {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Add-LoggingTarget.md')]
    param(
        [Parameter(Position = 2)]
        [hashtable] $Configuration = @{}
    )

    DynamicParam {
        New-LoggingDynamicParam -Name 'Name' -Target
    }

    End {
        $Script:Logging.EnabledTargets[$PSBoundParameters.Name] = Merge-DefaultConfig -Target $PSBoundParameters.Name -Configuration $Configuration

        # Special case hack - resolve target file path if it's a relative path
        # This can't be done in the Init scriptblock of the logging target because that scriptblock gets created in the
        # log consumer runspace and doesn't inherit the current SessionState. That means that the scriptblock doesn't know the
        # current working directory at the time when `Add-LoggingTarget` is being called and can't accurately resolve the relative path.
        if($PSBoundParameters.Name -eq 'File'){
            $Script:Logging.EnabledTargets[$PSBoundParameters.Name].Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Configuration.Path)
        }

        if ($Script:Logging.Targets[$PSBoundParameters.Name].Init -is [scriptblock]) {
            & $Script:Logging.Targets[$PSBoundParameters.Name].Init $Configuration
        }
    }
}