function Get-JavbusUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    begin {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        $searchUrl = "https://www.javbus.com/ja/uncensored/search/$Name&type=0&parent=uc"
    }

    process {
        try {
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$searchUrl]"
            $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            throw $_
        }

        $Tries = 5
        # Get the page search results
        $searchResults = (($webRequest | ForEach-Object { $_ -split '\n' } | Select-String '<a class="movie-box" href="(.*)">').Matches) | ForEach-Object { $_.Groups[1].Value }
        $numResults = $searchResults.Count

        if ($Tries -gt $numResults) {
            $Tries = $numResults
        }

        if ($numResults -ge 1) {
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Searching [$Tries] of [$numResults] results for [$Name]"

            $count = 1
            foreach ($result in $searchResults) {
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$result]"
                $webRequest = Invoke-RestMethod -Uri $result -Method Get -Verbose:$false
                $resultId = Get-JavbusId -WebRequest $webRequest
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"
                if ($resultId -eq $Name) {
                    $directUrl = $result
                    break
                }

                if ($count -eq $Tries) {
                    break
                }

                $count++
            }

            Write-Output $directUrl
        }
    }
}

