function Get-JavlibraryUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter(Position = 1)]
        [String]$BaseUrl = 'http://www.javlibrary.com',

        [Parameter(Position = 2)]
        [PSObject]$Session,

        [Parameter()]
        [Switch]$AllResults
    )

    process {
        if ($BaseUrl[-1] -eq '/') {
            # Remove the trailing slash if it is included to create the valid searchUrl
            $BaseUrl = $BaseUrl[0..($BaseUrl.Length - 1)] -join ''
        }

        $searchUrl = "$BaseUrl/en/vl_searchbyid.php?keyword=$Id"

        $webRequest = Invoke-JVWebRequest -Uri $searchUrl -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false


        # Check if the search uniquely matched a video page
        # If not, we will check the search results and check a few for if they are a match
        $searchResultUrl = $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
        if ($searchResultUrl -match "\?v=") {
            $resultId = Get-JavlibraryId -WebRequest $webRequest
            if ($resultId -eq $Id) {
                $urlObject = [PSCustomObject]@{
                    En    = $searchResultUrl
                    Ja    = $searchResultUrl -replace '/en/', '/ja/'
                    Zh    = $searchResultUrl -replace '/en/', '/cn/'
                    Id    = Get-JavlibraryId -Webrequest $webRequest
                    Title = Get-JavlibraryTitle -Webrequest $webRequest
                }
                Write-Output $urlObject
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] not matched on JavLibrary"
                return
            }
        } else {
            try {
                $results = ($webRequest.Content | Select-String -Pattern '<a href="\.\/\?v=(.*)" title="(.*)"><div class="id">(.*-.*)<\/div>' -AllMatches).Matches
                $resultObject = $results | ForEach-Object {
                    $splitTitle = ($_.Groups[2].Value -split ' ')
                    [PSCustomObject]@{
                        Id    = ($_.Groups[3].Value -split '<\/div>')[0]
                        Title = ($splitTitle[1..($splitTitle.Length - 1)]) -join ' '
                        Url   = $BaseUrl + "/en/?v=" + $_.Groups[1].Value
                    }
                }
            } catch {
                # Do nothing
            }

            if ($Id -in $resultObject.Id) {
                $matchedResult = $resultObject | Where-Object { $Id -eq $_.Id }

                if ($matchedResult.Count -gt 1 -and !($AllResults)) {
                    $checkResult = $matchedResult | Where-Object { $_.Title -notlike '*Blu-ray Disc*' }
                    if ($checkResult.Count -eq 0) {
                        $matchedResult = $matchedResult[0]
                    } elseif ($checkResult.Count -gt 1) {
                        $matchedResult = $checkResult[0]
                    } else {
                        $matchedResult = $checkResult
                    }
                }

                $urlObject = foreach ($entry in $matchedResult) {
                    [PSCustomObject]@{
                        En    = $entry.Url
                        Ja    = $entry.Url -replace '/en/', '/ja/'
                        Zh    = $entry.Url -replace '/en/', '/cn/'
                        Id    = $entry.Id
                        Title = $entry.Title
                    }
                }

                Write-Output $urlObject
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] not matched on JavLibrary"
                return
            }
        }
    }
}
