function Get-Jav321Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Id
    )

    process {
        $searchUrl = "https://jp.jav321.com/search"

        try {
            Write-JLog -Level Debug -Message "Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Post -Body "sn=$Id" -Verbose:$false
        } catch {
            Write-JLog -Level Error -Message "Error [GET] on URL [$searchUrl]: $PSItem"
            return
        }


        $Tries = 5
        # Get the page search results
        $searchResults = $webRequest.Links.OuterHtml | Where-Object { $_ -match 'jav321.com/video/' } |
        Select-String -Pattern 'jav321.com/video/(.*)" target' |
        ForEach-Object { $_.Matches.Groups[1].Value } |
        Select-Object -Unique

        $numResults = $searchResults.Count

        if ($Tries -gt $numResults) {
            $Tries = $numResults
        }

        if ($numResults -ge 1) {
            Write-JLog -Level Debug -Message "Searching [$Tries] of [$numResults] results for [$Id]"

            $count = 1
            foreach ($result in $searchResults) {
                $result = "https://jp.jav321.com/video/$result"
                try {
                    Write-JLog -Level Debug -Message "Performing [GET] on URL [$result]"
                    $webRequest = Invoke-RestMethod -Uri $result -Method Get -Verbose:$false
                } catch {
                    Write-JLog -Level Error -Message "Error [GET] on URL [$result]: $PSItem"
                }

                $resultId = Get-Jav321Id -WebRequest $webRequest
                if ($resultId -eq $Id) {
                    $directUrl = $result
                    break
                }

                Write-JLog -Level Debug -Message "Result [$count] is [$resultId]"
                if ($count -eq $Tries) {
                    break
                }

                $count++
            }

            if ($null -eq $directUrl) {
                Write-JLog -Level Warning -Message "Search [$Id] not matched on Jav321"
                return
            } else {
                Write-Output $directUrl
            }
        } else {
            Write-JLog -Level Warning -Message "Search [$Id] not matched on Jav321"
            return
        }
    }
}
