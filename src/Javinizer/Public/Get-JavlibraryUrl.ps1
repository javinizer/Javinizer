#Requires -Modules @{ ModuleName="Logging"; RequiredVersion="4.4.0" }
#Requires -PSEdition Core

function Get-JavlibraryUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('en', 'ja', 'zh')]
        [String]$Language,

        [Parameter(Position = 2)]
        [String]$BaseUrl = 'http://www.javlibrary.com'
    )

    process {
        if ($BaseUrl[-1] -eq '/') {
            # Remove the trailing slash if it is included to create the valid searchUrl
            $BaseUrl = $BaseUrl[0..($BaseUrl.Length - 1)] -join ''
        }

        $searchUrl = "$BaseUrl/en/vl_searchbyid.php?keyword=$Id"

        try {
            Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
        } catch {
            Write-JVLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]: $PSItem"
        }

        # Check if the search uniquely matched a video page
        # If not, we will check the search results and check a few for if they are a match
        $searchResultUrl = $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
        if ($searchResultUrl -match "$BaseUrl?v=") {
            try {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchResultUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
                $webRequest = Invoke-WebRequest -Uri $searchResultUrl -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
            } catch {
                Write-JVLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchResultUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]: $PSItem"
            }

            $resultId = Get-JavlibraryId -WebRequest $webRequest
            Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result is [$resultId]"
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
                    $directUrl = "$BaseUrl/en/?v=$videoId"

                    try {
                        Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$directUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
                        $webRequest = Invoke-WebRequest -Uri $directUrl -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
                    } catch {
                        Write-JVLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$directUrl] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]: $PSItem"
                    }

                    $resultId = Get-JavlibraryId -WebRequest $webRequest
                    Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                    if ($resultId -eq $Id) {
                        $javlibraryUrl = (Get-JVUrlLocation -Url $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri).Url
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
            Write-JVLog -Level Warning -Message "[$Id] not matched on JavLibrary"
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
