function Get-R18Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        [string]$AltName,
        [ValidateRange(2, 5)]
        [int]$Tries
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $searchUrl = "https://www.r18.com/common/search/searchword=$Name/"
    }

    process {
        try {
            Write-Debug "[$($MyInvocation.MyCommand.Name)/Get-DMMUrl] Performing [GET] on Uri [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            throw $_
        }

        $searchResults = (($webRequest.Links | Where-Object { $_.href -like "*/videos/vod/movies/detail/-/id=*" }).href)
        $numResults = $searchResults.count
        if ($searchResults.count -ge 2) {
            if ($Tries.IsPresent) {
                $Tries = $Tries
            } else {
                $Tries = 5
            }

            Write-Debug "[$($MyInvocation.MyCommand.Name)] Unique video match not found, trying to search [$Tries] of [$numResults] results for [$Id]"

            $count = 1
            foreach ($result in $searchResults) {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$result]"
                $webRequest = Invoke-WebRequest -Uri $result -Method Get -Verbose:$false
                $resultId = Get-R18Id -WebRequest $webRequest
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"
                if ($resultId -eq $Name) {
                    $directUrl = $result
                    break
                }
                $count++
            }
        } elseif ($searchResults.count -eq 0 -or $null -eq $searchResults.count) {
            if ($AltName -eq '') {
                $AltName = $Name -split '-'
                $AltName = $AltName[0] + '00' + $AltName[1]
            }

            $searchUrl = "https://www.r18.com/common/search/searchword=$AltName/"

            try {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$searchUrl]"
                $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                throw $_
            }

            $searchResults = (($webRequest.Links | Where-Object { $_.href -like "*/videos/vod/movies/detail/-/id=*" }).href)
            $numResults = $searchResults.count

            if ($searchResults.count -ge 2) {
                if ($Tries.IsPresent) {
                    $Tries = $Tries
                } else {
                    $Tries = 5
                }

                Write-Debug "[$($MyInvocation.MyCommand.Name)] Unique video match not found, trying to search [$Tries] of [$numResults] results for [$Id]"

                $count = 1
                foreach ($result in $searchResults) {
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$result]"
                    $webRequest = Invoke-WebRequest -Uri $result -Method Get -Verbose:$false
                    $resultId = Get-R18Id -WebRequest $webRequest
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"
                    if ($resultId -eq $Name) {
                        $directUrl = $result
                        break
                    }
                    $count++
                }
            } elseif ($searchResults.count -eq 0 -or $null -eq $searchResults.count) {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Search [$Name] not matched; Skipping..."
                return
            } else {
                $directUrl = $searchResults
            }
        } else {
            $directUrl = $searchResults
        }

        Write-Output $directUrl
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
