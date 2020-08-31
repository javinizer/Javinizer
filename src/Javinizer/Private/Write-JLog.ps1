function Write-JLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
        [string]$Level,
        [Parameter()]
        [ValidateSet('Break', 'Continue', 'Ignore', 'Inquire', 'SilentlyContinue', 'Stop', 'Suspend')]
        [string]$Action = 'Stop'
    )

    if ($Level -eq 'Debug') {
        Write-Debug -Message $Message
        Write-Log -Level $Level -Message $Message | Wait-Logging
    }

    if ($Level -eq 'Info') {
        Write-Verbose -Message $Message
        Write-Log -Level $Level -Message $Message | Wait-Logging
    }

    if ($Level -eq 'Warning') {
        Write-Warning -Message $Message
        Write-Log -Level $Level -Message $Message | Wait-Logging
    }

    if ($Level -eq 'Error') {
        Write-Log -Level $Level -Message $Message | Wait-Logging
        Write-Error -Message $Message -ErrorAction $Action
    }
}
