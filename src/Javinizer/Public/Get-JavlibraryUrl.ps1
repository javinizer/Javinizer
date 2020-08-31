function Get-JavlibraryUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('en', 'ja', 'zh')]
        [String]$Language
    )

    process {
        $searchUrl = "http://www.javlibrary.com/en/vl_searchbyid.php?keyword=$Id"

        try {
            Write-JLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
        } catch {
            Write-JLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]: $PSItem"
        }

        # Check if the search uniquely matched a video page
        # If not, we will check the search results and check a few for if they are a match
        $searchResultUrl = $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
        if ($searchResultUrl -match 'http:\/\/www\.javlibrary\.com\/en\/\?v=') {
            try {
                Write-JLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchResultUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
                $webRequest = Invoke-WebRequest -Uri $searchResultUrl -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
            } catch {
                Write-JLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchResultUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]: $PSItem"
            }

            $resultId = Get-JavlibraryId -WebRequest $webRequest
            Write-JLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result is [$resultId]"
            if ($resultId -eq $Id) {
                $javlibraryUrl = $searchResultUrl
            }
        }

        if ($null -eq $javlibraryUrl) {
            $Tries = 5
            $searchResults = $webRequest.Links.href | Where-Object { $_ -match '\.\/\?v=(.*)' }
            $numResults = $searchResults.count

            if ($Tries -gt $numResults) {
                $Tries = $numResults
            }

            if ($numResults -ge 1) {
                $count = 1
                foreach ($result in $searchResults) {
                    $videoId = ($result -split '=')[1]
                    $directUrl = "http://www.javlibrary.com/en/?v=$videoId"

                    try {
                        Write-JLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$directUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
                        $webRequest = Invoke-WebRequest -Uri $directUrl -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
                    } catch {
                        Write-JLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$directUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]: $PSItem"
                    }

                    $resultId = Get-JavlibraryId -WebRequest $webRequest
                    Write-JLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                    if ($resultId -eq $Id) {
                        $javlibraryUrl = (Test-UrlLocation -Url $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri).Url
                        break
                    }

                    if ($count -eq $Tries) {
                        break
                    }

                    $count++
                }
            }
        }

        if ($null -eq $javlibraryUrl) {
            Write-JLog -Level Warning -Message "[$Id] not matched on JavLibrary"
            return
        } else {
            if ($Language -eq 'ja') {
                $javlibraryUrl = $javlibraryUrl -replace '/en/', '/ja/'
            } elseif ($Language -eq 'zh') {
                $javlibraryUrl = $javlibraryUrl -replace '/en/', '/cn/'
            }

            $urlObject = [PSCustomObject]@{
                Url      = $javlibraryUrl
                Language = $Language
            }

            Write-Output $urlObject
        }
    }
}
