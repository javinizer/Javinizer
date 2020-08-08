function Write-JLog {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Message,

        [Parameter()]
        [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
        [string]$Level
    )

    if ($Level -eq 'Debug') {
        Write-Debug -Message $Message
        Write-Log -Level $Level -Message $Message | Wait-Logging
    }

    if ($Level -eq 'Info') {
        Write-Host $Message
        Write-Log -Level $Level -Message $Message | Wait-Logging
    }

    if ($Level -eq 'Warning') {
        Write-Warning -Message $Message
        Write-Log -Level $Level -Message $Message | Wait-Logging
    }

    if ($Level -eq 'Error') {
        Write-Log -Level $Level -Message $Message | Wait-Logging
        throw $_
    }
}
