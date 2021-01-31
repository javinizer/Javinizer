function Get-JavdbUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id
    )

    process {
        $searchUrl = "https://javdb.com/search?q=$Id&f=all"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            try {
                # Add a retry to the URL search due to 500 errors occurring randomly when scraping Javdb
                Start-Sleep -Seconds 3
                $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
            }
        }

        $results = $webRequest.Links | Where-Object { $null -ne $_.title }

        $resultObject = $results | ForEach-Object {
            [PSCustomObject]@{
                Id  = (($_.outerHTML) | Select-String -Pattern '<div class="uid">(.*)<\/div>').Matches.Groups[1].Value
                Url = "https://javdb.com" + $_.href
            }
        }

        if ($Id -in $resultObject.Id) {
            $matchedResult = $resultObject | Where-Object { $Id -eq $_.Id }

            # If we have more than one exact match, select the first option
            if ($matchedResult.Count -gt 1) {
                $matchedResult = $matchedResult[0]
            }

            $urlObject = [PSCustomObject]@{
                En = $matchedResult.Url + "?locale=en"
                Zh = $matchedResult.Url + "?locale=zh"
            }

            Write-Output $urlObject
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on Javdb"
            return
        }
    }
}
