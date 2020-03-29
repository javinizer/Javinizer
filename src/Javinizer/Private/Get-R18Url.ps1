function Get-R18Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        [string]$AltName,
        [int]$Tries,
        [switch]$Zh
    )

    begin {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        $searchResults = @()
        $altSearchResults = @()
        $searchUrl = "https://www.r18.com/common/search/searchword=$Name/"
    }

    process {
        # Try matching the video with Video ID
        try {
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            throw $_
        }

        $Tries = 5
        $searchResults = (($webRequest.Links | Where-Object { $_.href -like "*/videos/vod/*/detail/-/id=*" }).href)
        $numResults = $searchResults.count

        if ($Tries -gt $numResults) {
            $Tries = $numResults
        }

        if ($numResults -ge 1) {
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Searching [$Tries] of [$numResults] results for [$Name]"

            $count = 1
            foreach ($result in $searchResults) {
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$result]"
                $webRequest = Invoke-WebRequest -Uri $result -Method Get -Verbose:$false
                $resultId = Get-R18Id -WebRequest $webRequest
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"
                if ($resultId -eq $Name) {
                    $directUrl = $result
                    break
                }

                if ($count -eq $Tries) {
                    break
                }

                $count++
            }
        }

        # If not matched by Video ID, try matching the video with Content ID
        if ($null -eq $directUrl) {
            if ($AltName -eq '' -or $null -eq $AltName) {
                $splitAltName = $Name -split '-'
                $AltName = $splitAltName[0] + '00' + $splitAltName[1]
            }

            $searchUrl = "https://www.r18.com/common/search/searchword=$AltName/"

            try {
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$searchUrl]"
                $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                throw $_
            }

            $Tries = 5
            $altSearchResults = (($webRequest.Links | Where-Object { $_.href -like "*/videos/vod/movies/detail/-/id=*" }).href)
            $numResults = $altSearchResults.count

            if ($Tries -gt $numResults) {
                $Tries = $numResults
            }

            $count = 1
            foreach ($result in $altSearchResults) {
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$result]"
                $webRequest = Invoke-WebRequest -Uri $result -Method Get -Verbose:$false
                $resultId = Get-R18Id -WebRequest $webRequest
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"
                if ($resultId -eq $Name) {
                    $directUrl = $result
                    break
                }

                if ($count -eq $Tries) {
                    break
                }

                $count++
            }
        }

        # If not matched by Video ID or Content ID, try matching the video with generic R18 URL
        if ($null -eq $directUrl) {
            $testUrl = "https://www.r18.com/videos/vod/movies/detail/-/id=$AltName/"

            try {
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$testUrl]"
                $webRequest = Invoke-WebRequest -Uri $testUrl -Method Get -Verbose:$false
            } catch {
                $webRequest = $null
            }

            if ($null -ne $webRequest) {
                $resultId = Get-R18Id -WebRequest $webRequest
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Result is [$resultId]"
                if ($resultId -eq $Name) {
                    $directUrl = $testUrl
                }
            }
        }

        if ($null -eq $directUrl) {
            # Write-Verbose "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Search [$Name] not matched on R18/Dmm"
            return
        } else {
            if ($Zh.IsPresent) {
                $directUrl = $directUrl + '&lg=zh'
            }
            Write-Output $directUrl
        }
    }

    end {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
