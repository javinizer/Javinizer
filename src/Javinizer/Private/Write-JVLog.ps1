function Write-JVLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Message,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
        [String]$Level,

        [Parameter()]
        [AllowEmptyString()]
        [String]$Write,

        [Parameter()]
        [AllowEmptyString()]
        [String]$WriteLevel,

        [Parameter()]
        [AllowEmptyString()]
        [String]$LogPath,

        [Parameter()]
        [ValidateSet('Break', 'Continue', 'Ignore', 'Inquire', 'SilentlyContinue', 'Stop', 'Suspend')]
        [String]$Action = 'Stop'
    )

    $timeStamp = Get-Date -Format s

    if ($Level -eq 'Debug') {
        if ($WriteLevel -eq 'Debug') {
            $formattedMessage = "[$timeStamp][DEBUG] $Message"
        }
        Write-Debug -Message "$Message"
    }

    if ($Level -eq 'Info') {
        if ($WriteLevel -eq 'Debug' -or $WriteLevel -eq 'Info') {
            $formattedMessage = "[$timeStamp][INFO ] $Message"
        }
        Write-Verbose -Message $Message
    }

    if ($Level -eq 'Warning') {
        if ($WriteLevel -eq 'Debug' -or $WriteLevel -eq 'Info' -or $WriteLevel -eq 'Warning') {
            $formattedMessage = "[$timeStamp][WARN ] $Message"
        }
        Write-Warning -Message $Message
    }

    if ($Level -eq 'Error') {
        if ($writeLevel -eq 'Debug' -or $WriteLevel -eq 'Info' -or $WriteLevel -eq 'Warning' -or $WriteLevel -eq 'Error') {
            $formattedMessage = "[$timeStamp][ERROR] $Message"
            if ($LogPath -ne '' -and $null -ne $LogPath) {
                if ($formattedMessage -ne '' -and $null -ne $formattedMessage) {
                    if ($Write -eq 1) {
                        $LogMutex = New-Object System.Threading.Mutex($false, "LogMutex")
                        $LogMutex.WaitOne() | Out-Null
                        $formattedMessage | Out-File -FilePath $LogPath -Append
                        $LogMutex.ReleaseMutex() | Out-Null
                    }
                }
            }
        }
        Write-Error -Message $Message -ErrorAction $Action
    }

    if ($LogPath -ne '' -and $null -ne $LogPath) {
        if ($formattedMessage -ne '' -and $null -ne $formattedMessage) {
            if ($Write -eq 1) {
                $LogMutex = New-Object System.Threading.Mutex($false, "LogMutex")
                $LogMutex.WaitOne() | Out-Null
                $formattedMessage | Out-File -FilePath $LogPath -Append
                $LogMutex.ReleaseMutex() | Out-Null
            }
        }
    }
}
