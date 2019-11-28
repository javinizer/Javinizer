function Get-JavLibraryUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        [ValidateRange(2, 5)]
        [int]$Tries
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        $searchUrl = "http://www.javlibrary.com/en/vl_searchbyid.php?keyword=$Name"
    }

    process {

        try {
            $webRequest = Invoke-WebRequest $searchUrl -WebSession $Session -UserAgent $Session.UserAgent
        } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Session to JAVLibrary is unsuccessful, attempting to start a new session with Cloudflare"
            try {
                New-CloudflareSession
            } catch {
                throw $_
            }
            $webRequest = Invoke-WebRequest $searchUrl -WebSession $Session -UserAgent $Session.UserAgent
        }

        # Check if the search uniquely matched a video page
        # If not, we will check the search results and check a few for if they are a match
        $javlibraryUrl = Test-UrlMatch -Url $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri -JavLibrary

        if ($null -eq $javlibraryUrl) {
            $searchResults = $webRequest.Links.href | Where-Object { $_ -match '\.\/\?v=(.*)' }
            $numResults = $searchResults.count

            if ($searchResults -ge 2) {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Unique video match not found, trying to search [$Tries] of [$numResults] results for [$Name]"
                if ($Tries.IsPresent) {
                    $Tries = $Tries
                } else {
                    $Tries = 2
                }
            } elseif ($searchResults -eq 0 -or $null -eq $searchResults) {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Search $Name not matched, skipping"
                break
            }

            $count = 1
            foreach ($result in $searchResults) {
                $videoId = ($result -split '=')[1]
                $directUrl = "http://www.javlibrary.com/en/?v=$videoId"
                $webRequest = Invoke-WebRequest $directUrl -WebSession $Session -UserAgent $Session.UserAgent
                $resultId = (($webRequest.Content -split '<title>')[1] -split ' ')[0]
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                if ($resultId -eq $Name) {
                    $javlibraryUrl = Test-UrlMatch -Url $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri -JavLibrary
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Search $Name matched"
                    break
                }

                if ($count -gt $Tries) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Search $Name not matched, skipping..."
                    break
                }
                $count++
            }
        }

        Write-Output $javlibraryUrl
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

