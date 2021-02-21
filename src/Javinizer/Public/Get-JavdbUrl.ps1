function Get-JavdbUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter(Position = 1)]
        [String]$Session,

        [Parameter()]
        [Switch]$AllResults
    )

    process {
        $searchUrl = "https://javdb.com/search?q=$Id&f=all"

        if ($Session) {
            $loginSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = '_jdb_session'
            $cookie.Value = $Session
            $cookie.Domain = 'javdb.com'
            $loginSession.Cookies.Add($cookie)
        }

        $webRequest = Invoke-JVWebRequest -Uri $searchUrl -Method Get -WebSession $loginSession -Verbose:$false


        $results = $webRequest.Links | Where-Object { $null -ne $_.title }

        try {
            $resultObject = $results | ForEach-Object {
                [PSCustomObject]@{
                    Id    = (($_.outerHTML) | Select-String -Pattern '<div class="uid">(.*)<\/div>').Matches.Groups[1].Value
                    Title = (($_.outerHTML) | Select-String -Pattern '<div class="video-title">(.*)<\/div>').Matches.Groups[1].Value
                    Url   = "https://javdb.com" + $_.href
                }
            }
        } catch {
            # Do nothing
        }

        try {
            $cleanId = ($Id | Select-String -Pattern '\d+(\D+-\d+)').Matches.Groups[1].Value
        } catch {
            # Do nothing
        }

        if ($Id -in $resultObject.Id -or $cleanId -in $resultObject.Id) {
            $matchedResult = $resultObject | Where-Object { $Id -eq $_.Id -or $cleanId -eq $_.Id }

            # If we have more than one exact match, select the first option
            if ($matchedResult.Count -gt 1 -and !($AllResults)) {
                $matchedResult = $matchedResult[0]
            }

            $urlObject = foreach ($entry in $matchedResult) {
                [PSCustomObject]@{
                    En    = $entry.Url + "?locale=en"
                    Zh    = $entry.Url + "?locale=zh"
                    Id    = $entry.Id
                    Title = $entry.Title
                }
            }

            Write-Output $urlObject
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] not matched on Javdb"
            return
        }
    }
}
