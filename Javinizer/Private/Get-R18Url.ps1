function Get-R18Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        [ValidateRange(2, 5)]
        [int]$Tries
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        $searchUrl = "https://www.r18.com/common/search/searchword=$Name/"
    }

    process {
        try {
            $webRequest = Invoke-WebRequest $searchUrl
        } catch {
            throw $_
        }

        $searchResults = (($webRequest.Links | Where-Object { $_.href -like "*/videos/vod/movies/detail/-/id=*" }).href)
        $numResults = $searchResults.count

        if ($searchResults.count -ge 2) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Unique video match not found, trying to search [$Tries] of [$numResults] results for [$Id]"
            if ($Tries.IsPresent) {
                $Tries = $Tries
            } else {
                $Tries = 3
            }

            $count = 1
            foreach ($result in $searchResults) {
                $webRequest = Invoke-WebRequest $result
                $html = $webRequest.Content
                $resultId = Get-R18MovieId -Html $html
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"
                $count++
            }
        } elseif ($searchResults.count -eq 0 -or $null -eq $searchResults.count) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Search $Name not matched, skipping..."
            break
        } else {
            $directUrl = $searchResults
        }

        Write-Output $directUrl
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
