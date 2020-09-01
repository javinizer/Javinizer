function Get-R18Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('en', 'zh')]
        [String]$Language
    )

    process {
        $searchResults = @()
        $altSearchResults = @()
        $searchUrl = "https://www.r18.com/common/search/searchword=$Id/"

        # If contentId is given, convert it back to standard movie ID to validate
        if ($Id -match '(?:\d{1,5})?([a-zA-Z]{2,10}|[tT]28|[rR]18)(\d{1,5})') {
            Write-JVLog -Level Debug -Message "Content ID [$Id] detected"
            $splitId = $Id | Select-String -Pattern '([a-zA-Z|tT28|rR18]{1,10})(\d{1,5})'
            $studioName = $splitId.Matches.Groups[1].Value
            $rawStudioId = $splitId.Matches.Groups[2].Value
            $studioIdIndex = ($rawStudioId | Select-String -Pattern '[1-9]').Matches.Index
            $studioId = ($rawStudioId[$studioIdIndex..($rawStudioId.Length - 1)] -join '').PadLeft(3, '0')

            $Id = "$($studioName.ToUpper())-$studioId"
        }

        # Convert the movie Id (ID-###) to content Id (ID00###) to match dmm naming standards
        if ($Id -match '([a-zA-Z|tT28|rR18]+-\d+z{0,1}Z{0,1}e{0,1}E{0,1})') {
            $splitId = $Id -split '-'
            $contentId = $splitId[0] + $splitId[1].PadLeft(5, '0')
        }

        # Try matching the video with Video ID
        try {
            Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            Write-JVLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem"
        }

        $retryCount = 3
        $searchResults = (($webRequest.Links | Where-Object { $_.href -like "*/videos/vod/*/detail/-/id=*" }).href)
        $numResults = $searchResults.count

        if ($retryCount -gt $numResults) {
            $retryCount = $numResults
        }

        if ($numResults -ge 1) {
            Write-JVLog -Level Debug -Message "Searching [$retryCount] of [$numResults] results for [$Id]"

            $count = 1
            foreach ($result in $searchResults) {
                try {
                    Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                    $webRequest = Invoke-WebRequest -Uri $result -Method Get -Verbose:$false
                } catch {
                    Write-JVLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$result]: $PSItem"
                }

                $resultId = Get-R18Id -WebRequest $webRequest
                Write-JVLog -Level Debug -Message "Result [$count] is [$resultId]"
                if ($resultId -eq $Id) {
                    $directUrl = $result
                    break
                }

                if ($count -eq $retryCount) {
                    break
                }

                $count++
            }
        }

        # If not matched by Video ID, try matching the video with Content ID
        if ($null -eq $directUrl) {
            $searchUrl = "https://www.r18.com/common/search/searchword=$contentId/"

            try {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
                $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                Write-JVLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem"
            }

            $retryCount = 5
            $altSearchResults = (($webRequest.Links | Where-Object { $_.href -like "*/videos/vod/movies/detail/-/id=*" }).href)
            $numResults = $altSearchResults.count

            if ($retryCount -gt $numResults) {
                $retryCount = $numResults
            }

            $count = 1
            foreach ($result in $altSearchResults) {
                try {
                    Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                    $webRequest = Invoke-WebRequest -Uri $result -Method Get -Verbose:$false
                } catch {
                    Write-JVLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$result]: $PSItem"
                }

                $resultId = Get-R18Id -WebRequest $webRequest
                Write-JVLog -Level Debug -Message "Result [$count] is [$resultId]"
                if ($resultId -eq $Id) {
                    $directUrl = $result
                    break
                }

                if ($count -eq $retryCount) {
                    break
                }

                $count++
            }
        }

        # If not matched by Video ID or Content ID, try matching the video with generic R18 URL
        if ($null -eq $directUrl) {
            $testUrl = "https://www.r18.com/videos/vod/movies/detail/-/id=$contentId/"

            try {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$testUrl]"
                $webRequest = Invoke-WebRequest -Uri $testUrl -Method Get -Verbose:$false
            } catch {
                $webRequest = $null
            }

            if ($null -ne $webRequest) {
                $resultId = Get-R18Id -WebRequest $webRequest
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result is [$resultId]"
                if ($resultId -eq $Id) {
                    $directUrl = $testUrl
                }
            }
        }

        if ($null -eq $directUrl) {
            Write-JVLog -Level Warning -Message "[$Id] not matched on R18"
            return
        } else {
            if ($Language -eq 'zh') {
                $directUrl = $directUrl + '&lg=zh'
            }

            $urlObject = [PSCustomObject]@{
                Url      = $directUrl
                Language = $Language
            }

            Write-Output $urlObject
        }
    }
}
