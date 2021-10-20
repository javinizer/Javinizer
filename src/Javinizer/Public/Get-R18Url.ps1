function Get-R18Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter()]
        [Switch]$Strict,

        [Parameter()]
        [Switch]$AllResults
    )

    process {
        $searchUrl = "https://www.r18.com/common/search/searchword=$Id/"

        # If contentId is given, convert it back to standard movie ID to validate
        if (!($Strict)) {
            if ($Id -match '(?:\d{1,5})?([a-zA-Z]{1,10}|[tT]28|[rR]18)(\d{5})') {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Content ID [$Id] detected"
                $splitId = $Id | Select-String -Pattern '([a-zA-Z|tT28|rR18]{1,10})(\d{1,5})'
                $studioName = $splitId.Matches.Groups[1].Value
                $rawStudioId = $splitId.Matches.Groups[2].Value
                $studioIdIndex = ($rawStudioId | Select-String -Pattern '[1-9]').Matches.Index
                $studioId = ($rawStudioId[$studioIdIndex..($rawStudioId.Length - 1)] -join '').PadLeft(3, '0')

                $Id = "$($studioName.ToUpper())-$studioId"
            }
        }

        # Convert the movie Id (ID-###) to content Id (ID00###) to match dmm naming standards
        if ($Id -match '([a-zA-Z|tT28|rR18]+-\d+z{0,1}Z{0,1}e{0,1}E{0,1})') {
            $splitId = $Id -split '-'
            $contentId = $splitId[0] + $splitId[1].PadLeft(5, '0')
        }

        # Try matching the video with Video ID
        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
        }

        try {
            $rawHtml = $webRequest.Content -split '<li class="item-list'
            if ($rawHtml.Count -gt 1) {
                $results = $rawHtml[1..($rawHtml.Count - 1)]
                $resultObject = $results | ForEach-Object {
                    [PSCustomObject]@{
                        Id    = (($_ -split '<img alt="')[1] -split '"')[0]
                        Title = (($_ -split '<dt>')[1] -split '<\/dt>')[0]
                        Url   = (($_ -split '<a class="i3NLink" href="')[1] -split '"')[0]
                    }
                }
            }
        } catch {
            # Do nothing
        }

        # If not matched by Video ID, try matching the video with Content ID
        if ($null -eq $resultObject) {
            $searchUrl = "https://www.r18.com/common/search/searchword=$contentId/"

            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
                $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
            }

            try {
                $rawHtml = $webRequest.Content -split '<li class="item-list"'
                if ($rawHtml.Count -gt 1) {
                    $results = $rawHtml[1..($rawHtml.Count - 1)]
                    $resultObject = $results | ForEach-Object {
                        [PSCustomObject]@{
                            Id    = (($_ -split '<img alt="')[1] -split '"')[0]
                            Title = (($_ -split '<dt>')[1] -split '<\/dt>')[0]
                            Url   = (($_ -split '<a class="i3NLink" href="')[1] -split '"')[0]
                        }
                    }
                }
            } catch {
                # Do nothing
            }
        }

        # If not matched by Video ID or Content ID, try matching the video with generic R18 URL
        if ($Id -notin $resultObject.Id) {
            $testUrl = "https://www.r18.com/videos/vod/movies/detail/-/id=$contentId/"

            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$testUrl]"
                $webRequest = Invoke-WebRequest -Uri $testUrl -Method Get -Verbose:$false
            } catch {
                $webRequest = $null
            }

            if ($null -ne $webRequest) {
                $resultId = Get-R18Id -WebRequest $webRequest
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result is [$resultId]"
                if ($resultId -eq $Id) {
                    $resultObject = [PSCustomObject]@{
                        Id    = $resultId
                        Title = Get-R18Title -Webrequest $webRequest
                        Url   = $testUrl
                    }
                }
            }
        }

        if ($Id -in $resultObject.Id) {
            $matchedResult = $resultObject | Where-Object { $Id -eq $_.Id }

            if ($matchedResult.Count -gt 1 -and !($AllResults)) {
                $matchedResult = $matchedResult[0]
            }

            <# $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'lg'
            $cookie.Value = 'zh'
            $cookie.Domain = '.r18.com'
            $session.Cookies.Add($cookie) #>

            $urlObject = foreach ($entry in $matchedResult) {
                $matchedContentId = (($entry.Url -split 'id=')[1] -split '\/')[0]

                <# try {
                    $zhUrl = Invoke-WebRequest -Uri ($entry.Url + '&lg=zh') -Method Get -WebSession $session -Verbose:$false

                } catch {
                    Write-Warning "[$(Get-R18Id -Webrequest $Webrequest)] R18 Ja actresses not found"
                    $zhUrl = $null
                } #>

                [PSCustomObject]@{
                    En    = $entry.Url
                    Zh    = $entry.Url + '&lg=zh'
                    EnApi = "https://www.r18.com/api/v4f/contents/$($matchedContentId)?lang=en"
                    ZhApi = "https://www.r18.com/api/v4f/contents/$($matchedContentId)?lang=zh"
                    Id    = $entry.Id
                    Title = $entry.Title
                }
            }

            Write-Output $urlObject
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on R18"
            return
        }
    }
}
