function Get-JavlibraryUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        [ValidateRange(2, 5)]
        [int]$Tries
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $searchUrl = "http://www.javlibrary.com/en/vl_searchbyid.php?keyword=$Name"
    }

    process {
        try {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$searchUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
        } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Session to JAVLibrary is unsuccessful, attempting to start a new session with Cloudflare"
            try {
                New-CloudflareSession
            } catch {
                throw $_
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$searchUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
        }

        # Check if the search uniquely matched a video page
        # If not, we will check the search results and check a few for if they are a match
        $searchResultUrl = $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
        if ($searchResultUrl -match 'http:\/\/www\.javlibrary\.com\/en\/\?v=') {
            $javlibraryUrl = $searchResultUrl
        }

        if ($null -eq $javlibraryUrl) {
            $searchResults = $webRequest.Links.href | Where-Object { $_ -match '\.\/\?v=(.*)' }
            $numResults = $searchResults.count

            if ($numResults -ge 2) {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Unique video match not found, trying to search [$Tries] of [$numResults] results for [$Name]"
                if ($Tries.IsPresent) {
                    $Tries = $Tries
                } else {
                    $Tries = 4
                }
            } elseif ($numResults -eq 0 -or $null -eq $searchResults) {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Search [$Name] not matched; Skipping..."
                return
            }

            $count = 1
            foreach ($result in $searchResults) {
                $videoId = ($result -split '=')[1]
                $directUrl = "http://www.javlibrary.com/en/?v=$videoId"
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$directUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
                $webRequest = Invoke-WebRequest -Uri $directUrl -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
                $resultId = (($webRequest.Content -split '<title>')[1] -split ' ')[0]
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                if ($resultId -eq $Name) {
                    $javlibraryUrl = Test-UrlLocation -Url $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Search [$Name] matched"
                    break
                }

                if ($count -gt $Tries) {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] Search [$Name] not matched; Skipping..."
                    return
                }
                $count++
            }
        }

        Write-Output $javlibraryUrl
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

