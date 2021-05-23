function Get-DmmUrl {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter()]
        [String]$r18Url,

        [Parameter()]
        [Switch]$Strict,

        [Parameter()]
        [Switch]$AllResults
    )

    process {
        $r18Results = Get-R18Url -Id $Id -Strict:$Strict -AllResults -WarningAction SilentlyContinue
        $resultObject = foreach ($entry in $r18Results) {
            $cid = (($entry.En -split 'id=')[1] -split '\/')[0]
            [PSCustomObject]@{
                Id        = $Id
                ContentId = $cid
                Title     = $entry.Title
                Url       = "https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=$cid"
            }
        }

        if ($Id -in $resultObject.Id) {
            $matchedResult = $resultObject | Where-Object { $Id -eq $_.Id }

            if ($matchedResult.Count -gt 1 -and !($AllResults)) {
                $matchedResult = $matchedResult[0]
            }

            $urlObject = foreach ($entry in $matchedResult) {
                [PSCustomObject]@{
                    En    = "https://www.dmm.co.jp/en/mono/dvd/-/detail/=/cid=$($entry.ContentId)"
                    Ja    = "https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=$($entry.ContentId)"
                    Id    = $entry.Id
                    Title = $entry.Title
                }
            }
            Write-Output $urlObject

        } else {
            # The digital/videoa URL is not being caught by the html for movie IDs matching '0001 - 0009'
            # Convert the movie Id (ID-###) to content Id (ID00###) to match dmm naming standards
            if (!($Strict)) {
                if ($Id -match '([a-zA-Z|tT28|rR18]+-\d+z{0,1}Z{0,1}e{0,1}E{0,1})') {
                    $splitId = $Id -split '-'
                    if (($splitId[1])[-1] -match '\D') {
                        $appendChar = ($splitId[1])[-1]
                        $splitId[1] = $splitId[1] -replace '\D', ''
                    }
                    $Id = ($splitId[0] + $splitId[1].PadLeft(5, '0') + $appendChar).Trim()
                }
            }

            $urlObject = [PSCustomObject]@{
                En = "https://www.dmm.co.jp/en/mono/dvd/-/detail/=/cid=$Id"
                Ja = "https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=$Id"
            }

            try {
                $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
                $cookie = New-Object System.Net.Cookie
                $cookie.Name = 'age_check_done'
                $cookie.Value = '1'
                $cookie.Domain = 'dmm.co.jp'
                $session.Cookies.Add($cookie)
                # Need to test the URL for a valid match before outputting the URL
                Invoke-WebRequest $urlObject.Ja -WebSession $session
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on DMM"
                return
            }

            if ($urlObject) {
                Write-Output $urlObject
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on DMM"
                return
            }
        }
    }
}
