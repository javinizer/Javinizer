function Get-JavbusUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Id,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('ja', 'en', 'zh')]
        [string]$Language
    )

    process {
        $searchUrl = "https://www.javbus.com/search/$Id&type=0&parent=uc"

        try {
            Write-JLog -Level Debug -Message "Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            try {
                $searchUrl = "https://www.javbus.com/uncensored/search/$Id&type=0&parent=uc"
                Write-JLog -Level Debug -Message "Performing [GET] on URL [$searchUrl]"
                $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                try {
                    $searchUrl = "https://www.javbus.org/search/$Id&type=0&parent=uc"
                    Write-JLog -Level Debug -Message "Performing [GET] on URL [$searchUrl]"
                    $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
                } catch {
                    Write-JLog -Level Warning -Message "Search [$Id] not matched on JavBus"
                    return
                }
            }
        }

        $Tries = 5
        # Get the page search results
        $searchResults = (($webRequest | ForEach-Object { $_ -split '\n' } | Select-String '<a class="movie-box" href="(.*)">').Matches) | ForEach-Object { $_.Groups[1].Value }
        $numResults = $searchResults.Count

        if ($Tries -gt $numResults) {
            $Tries = $numResults
        }

        if ($numResults -ge 1) {
            Write-JLog -Level Debug -Message "Searching [$Tries] of [$numResults] results for [$Id]"

            $count = 1
            foreach ($result in $searchResults) {
                try {
                    Write-JLog -Level Debug -Message "Performing [GET] on URL [$result]"
                    $webRequest = Invoke-RestMethod -Uri $result -Method Get -Verbose:$false
                } catch {
                    Write-JLog -Level Error -Message "Error [GET] on URL [$result]: $PSItem"
                }
                $resultId = Get-JavbusId -WebRequest $webRequest
                if ($resultId -eq $Id) {
                    if ($Language -eq 'zh') {
                        $directUrl = "https://" + ($result -split '/')[-2] + "/" + ($result -split '/')[-1]
                    } else {
                        $directUrl = "https://" + ($result -split '/')[-2] + "/$Language/" + ($result -split '/')[-1]
                    }
                    break
                }

                Write-JLog -Level Debug -Message "Result [$count] is [$resultId]"

                if ($count -eq $Tries) {
                    break
                }

                $count++
            }

            if ($null -eq $directUrl) {
                Write-JLog -Level Warning -Message "Search [$Id] not matched on JavBus"
                return
            } else {
                Write-Output $directUrl
            }
        }
    }
}
