function Invoke-JVWebRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Uri,

        [Parameter()]
        [ValidateSet('Delete', 'Get', 'Head', 'Merge', 'Options', 'Patch', 'Post', 'Put', 'Trace')]
        [String]$Method = 'Get',

        [Parameter()]
        [PSObject]$WebSession,

        [Parameter()]
        [String]$UserAgent,

        [Parameter()]
        [String]$Body,

        [Parameter()]
        [Switch]$RestMethod
    )

    process {
        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [$Method] on URL [$Uri]"
            if (-not ($RestMethod)) {
                if (-not ($WebSession)) {
                    $request = Invoke-WebRequest -Uri $Uri -Method:$Method -Body:$Body -MaximumRetryCount 3 -RetryIntervalSec 2 -Verbose:$false
                } elseif ($WebSession -and $UserAgent) {
                    $request = Invoke-WebRequest -Uri $Uri -Method:$Method -Body:$Body -WebSession:$WebSession -UserAgent:$UserAgent -MaximumRetryCount 3 -RetryIntervalSec 2 -Verbose:$false
                } else {
                    $request = Invoke-WebRequest -Uri $Uri -Method:$Method -Body:$Body -WebSession:$WebSession -MaximumRetryCount 3 -RetryIntervalSec 2 -Verbose:$false
                }
            } else {
                if (-not ($WebSession)) {
                    $request = Invoke-RestMethod -Uri $Uri -Method:$Method -Body:$Body -MaximumRetryCount 3 -RetryIntervalSec 2 -Verbose:$false
                } elseif ($WebSession -and $UserAgent) {
                    $request = Invoke-RestMethod -Uri $Uri -Method:$Method -Body:$Body -WebSession:$WebSession -UserAgent:$UserAgent -MaximumRetryCount 3 -RetryIntervalSec 2 -Verbose:$false
                } else {
                    $request = Invoke-RestMethod -Uri $Uri -Method:$Method -Body:$Body -WebSession:$WebSession -MaximumRetryCount 3 -RetryIntervalSec 2 -Verbose:$false
                }
            }
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [$Method] on URL [$Uri]" -Action Stop
        }

        Write-Output $request
    }
}
