function Get-TokyoHotUrl {
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
        $searchUrl = "https://www.tokyo-hot.com/product/?q=$Id"

        if ($Session) {
            $loginSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'sessionid'
            $cookie.Value = $Session
            $cookie.Domain = '.tokyo-hot.com'
            $loginSession.Cookies.Add($cookie)
        }

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -WebSession $loginSession -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
            # not really sure retry is needed for TokyoHot
            # try {
            #     # Add a retry to the URL search due to 500 errors occurring randomly when scraping TokyoHot
            #     Start-Sleep -Seconds 3
            #     $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -WebSession $loginSession -Verbose:$false
            # } catch {
            #     Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
            # }
        }

        $results = $webRequest.Links | Where-Object { $null -ne $_.title }

        # HTML for search result
        # <div class="description2">
        #    <div class="title">Throng Fuck</div>
        #    <div class="actor"> (Product ID: n0533)</div>
        #    <div class="text">Throng Fuck The perfection of the TOK...</div>
        # </div>


        try {
            $resultObject = $results | ForEach-Object {
                [PSCustomObject]@{
                    Id    = (($_.outerHTML) | Select-String -Pattern '<div class="actor">(Product ID: .*)<\/div>').Matches.Groups[1].Value
                    Title = (($_.outerHTML) | Select-String -Pattern '<div class="title">(.*)<\/div>').Matches.Groups[1].Value
                    Url   = "https://tokyo-hot.com" + $_.href
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
                    En    = $entry.Url
                    Id    = $entry.Id
                    Title = $entry.Title
                }
            }

            Write-Output $urlObject
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on TokyoHot"
            return
        }
    }
}
