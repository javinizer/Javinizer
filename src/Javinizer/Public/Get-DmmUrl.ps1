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
                    $contentId = ($splitId[0] + $splitId[1].PadLeft(5, '0') + $appendChar).Trim()
                }
                $cleanId = (($splitId -join "") + $appendChar).Trim()
            }

            $searchUrl = "https://www.dmm.co.jp/search/=/searchstr=$contentId/"

            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
                $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
            }

            $searchResults = $webRequest.links.href | Where-Object { $_ -match '\/mono\/dvd' -or $_ -match '\/digital\/videoa' }

            if ($searchResults) {
                $matchedResults = @()

                # Prioritize digital video before falling back to DVD matches
                if ($searchResults -match "\/digital\/videoa") {
                    $searchResults | Where-Object { $_ -match "\/digital\/videoa" -and $_ -match $contentId } | ForEach-Object {
                        $cid = ($_ | Select-String -Pattern 'cid=(.*)\/').Matches.Groups[1].Value

                        # Remove the prepended numbers in the contentId to more accurately match it to generic cid value
                        $cleanCid = $cid -replace '^\w*?(?=[a-z]+\d+)', ''

                        # Digital videos will match to contentId (ID00123)
                        if ($cleanCid -eq $contentId) {
                            $matchedResults += $_
                        }
                    }
                }

                if ($searchResults -match "\/mono\/dvd") {
                    $searchResults | Where-Object { $_ -match "\/mono\/dvd" -and $_ -match $cleanId } | ForEach-Object {
                        $cid = ($_ | Select-String -Pattern 'cid=(.*)\/').Matches.Groups[1].Value
                        $cleanCid = $cid -replace '^\w*?(?=[a-z]+\d+)', ''

                        # DVD videos will match to DVDId (ID123)
                        if ($cleanCid -eq $cleanId) {
                            $matchedResults += $_
                        }
                    }
                }
            }

            if ($matchedResults.Length -gt 0) {
                $selectedResult = $matchedResults | Select-Object -First 1

                $urlObject = [PSCustomObject]@{
                    En = $null
                    Ja = $selectedResult
                }
                Write-Output $urlObject
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on DMM"
                return
            }
        }
    }
}
