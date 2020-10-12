
function Set-JavlibraryOwned {
    param (
        [Parameter(Mandatory = $true)]
        [String]$Id,

        [Parameter(Mandatory = $true)]
        [String]$UserId,

        [Parameter(Mandatory = $true)]
        [String]$LoginSession,

        [Parameter(Mandatory = $true)]
        [PSObject]$Session
    )

    process {
        $ProgressPreference = 'SilentlyContinue'
        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info "[$Id] [$($MyInvocation.MyCommand.Name)] Setting owned on JavLibrary"

        try {
            $url = (Get-JavlibraryUrl -Id $Id -BaseUrl 'http://www.javlibrary.com' -Session:$Session).En
            if ($null -ne $url) {
                $request = Invoke-WebRequest -Uri $url -WebSession $Session -UserAgent $Session.UserAgent -Method Get -Verbose:$false
                $ajaxId = Get-JavlibraryAjaxId -Webrequest $request

            } else {
                return
            }

            $index = 0
            $timeout = New-TimeSpan -Seconds 20
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            while ($check.Content -notmatch '"ERROR":1' -and $stopwatch.Elapsed -lt $timeout) {
                if ($check.Content -match '"ERROR":-3') {
                    Start-Sleep -Seconds 3
                }
                $check = Invoke-WebRequest -Uri "https://www.javlibrary.com/ajax/ajax_cv_favoriteadd.php" `
                    -Method "POST" `
                    -Headers @{
                    "method"           = "POST"
                    "authority"        = "www.javlibrary.com"
                    "scheme"           = "https"
                    "path"             = "/ajax/ajax_cv_favoriteadd.php"
                    "accept"           = "application/json, text/javascript, */*; q=0.01"
                    "x-requested-with" = "XMLHttpRequest"
                    "origin"           = "https://www.javlibrary.com"
                    "sec-fetch-site"   = "same-origin"
                    "sec-fetch-mode"   = "cors"
                    "sec-fetch-dest"   = "empty"
                    "referer"          = $url
                    "accept-encoding"  = "gzip, deflate, br"
                    "accept-language"  = "en-US, en; q=0.9"
                    "cookie"           = "timezone=420; over18=18; userid=$UserId; session=$LoginSession"
                } `
                    -ContentType "application/x-www-form-urlencoded; charset=UTF-8" `
                    -Body "type=2&targetid=$ajaxId" `
                    -WebSession $Session `
                    -UserAgent $Session.UserAgent `
                    -Verbose:$false
            }
            if ($stopwatch.elapsed -gt $timeout) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Timed out while setting owned status for [$url]"
            }
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occurred when setting owned status for [$url]: $PSItem"
        }
    }
}
