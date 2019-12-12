function Display-ConfirmMessage {
    [CmdletBinding()]
    param(
        [string]$Message,
        [string]$Default
    )

    process {
        $Default = $Default.ToUpper()
        Write-Host "$Message"
        $selection = Read-Host "[Y] Yes  [N] No  (Default is ""$Default"")"
        do {
            if ($selection -eq '' -or $null -eq $selection) {
                $selection = $Default
            } elseif ($selection -eq 'y' -or $selection -eq 'yes') {
                $selection = 'y'
            } elseif ($selection -eq 'n' -or $selection -eq 'no') {
                $selection = 'n'
            } else {
                Write-Warning "Your selection [$selection] is invalid."
                $selection = Read-Host "[Y] Yes  [N] No  (Default is ""$Default"")"
            }
        } until ($selection -eq 'y' -or $selection -eq 'n')

        Write-Output $selection
    }
}
