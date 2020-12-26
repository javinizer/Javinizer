function Get-JavlibraryUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter(Position = 1)]
        [String]$BaseUrl = 'http://www.javlibrary.com',

        [Parameter(Position = 2)]
        [PSObject]$Session
    )

    process {
        if ($BaseUrl[-1] -eq '/') {
            # Remove the trailing slash if it is included to create the valid searchUrl
            $BaseUrl = $BaseUrl[0..($BaseUrl.Length - 1)] -join ''
        }

        $searchUrl = "$BaseUrl/en/vl_searchbyid.php?keyword=$Id"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
        } catch {
            try {
                # Add a retry to the URL search due to 500 errors occurring randomly when scraping Javlibrary
                Start-Sleep -Seconds 3
                $webRequest = Invoke-WebRequest -Uri $searchUrl -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
            }
        }

        # Check if the search uniquely matched a video page
        # If not, we will check the search results and check a few for if they are a match
        $searchResultUrl = $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
        if ($searchResultUrl -match "$BaseUrl?v=") {
            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchResultUrl]"
                $webRequest = Invoke-WebRequest -Uri $searchResultUrl -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchResultUrl]: $PSItem" -Action 'Continue'
            }

            $resultId = Get-JavlibraryId -WebRequest $webRequest
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result is [$resultId]"
            if ($resultId -eq $Id) {
                $javlibraryUrl = $searchResultUrl
            }
        }

        if ($null -eq $javlibraryUrl) {
            $retryCount = 3
            $searchResults = $webRequest.Links.href | Where-Object { $_ -match '\.\/\?v=(.*)' }
            $numResults = $searchResults.count

            if ($retryCount -gt $numResults) {
                $retryCount = $numResults
            }

            if ($numResults -ge 1) {
                $count = 1
                foreach ($result in $searchResults) {
                    $videoId = ($result -split '=')[1]
                    $directUrl = "$BaseUrl/en/?v=$videoId"

                    try {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$directUrl]"
                        $webRequest = Invoke-WebRequest -Uri $directUrl -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$directUrl]: $PSItem" -Action 'Continue'
                    }

                    $resultId = Get-JavlibraryId -WebRequest $webRequest
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                    if ($resultId -eq $Id) {
                        $javlibraryUrl = $directUrl
                        break
                    }

                    if ($count -eq $retryCount) {
                        break
                    }

                    $count++
                }
            }
        }

        if ($null -eq $javlibraryUrl) {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on JavLibrary"
            return
        } else {
            $javlibraryUrlJa = $javlibraryUrl -replace '/en/', '/ja/'
            $javlibraryUrlZh = $javlibraryUrl -replace '/en/', '/cn/'

            $urlObject = [PSCustomObject]@{
                En = $javlibraryUrl
                Ja = $javlibraryUrlJa
                Zh = $javlibraryUrlZh
            }

            Write-Output $urlObject
        }
    }
}
