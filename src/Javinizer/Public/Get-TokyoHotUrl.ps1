function Get-TokyoHotUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter()]
        [Switch]$AllResults
    )

    process {
        $searchUrl = "https://www.tokyo-hot.com/product/?q=$Id"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -WebSession $loginSession -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
        }

        $results = $webRequest.links | Where-Object { $_.outerHTML -like "*description2*" }

        try {
            $resultObject = $results | ForEach-Object {
                [PSCustomObject]@{
                    Id    = if ($resultId = ($_.outerHTML) | Select-String -Pattern '<div class="actor"> \(Product ID: (.*)\)</div>') {
                        $resultId.Matches.Groups[1].Value
                    }
                    Title = if ($title = ($_.outerHTML) | Select-String -Pattern '<div class="title">(.*)<\/div>') {
                        $title.Matches.Groups[1].Value
                    }
                    Url   = "https://tokyo-hot.com" + $_.href
                }
            }
        } catch {
            # Do nothing
        }

        if ($Id -in $resultObject.Id) {
            $matchedResult = $resultObject | Where-Object { $Id -eq $_.Id }

            # If we have more than one exact match, select the first option
            if ($matchedResult.Count -gt 1 -and !($AllResults)) {
                $matchedResult = $matchedResult[0]
            }

            $urlObject = foreach ($entry in $matchedResult) {
                [PSCustomObject]@{
                    En    = $entry.Url + "?lang=en"
                    Ja    = $entry.Url + "?lang=ja"
                    Zh    = $entry.Url + "?lang=zh-TW"
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
