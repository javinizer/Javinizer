function Get-Jav321Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    begin {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        $searchUrl = "https://jp.jav321.com/search"
    }

    process {
        try {
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Post -Body "sn=$Name" -Verbose:$false
        } catch {
            return
        }


        $Tries = 5
        # Get the page search results
        $searchResults = $webRequest.Links.OuterHtml | Where-Object { $_ -match 'jav321.com/video/' } |
            Select-String -Pattern 'jav321.com/video/(.*)" target' |
                ForEach-Object { $_.Matches.Groups[1].Value} |
                    Select-Object -Unique

        $numResults = $searchResults.Count

        if ($Tries -gt $numResults) {
            $Tries = $numResults
        }

        if ($numResults -ge 1) {
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Searching [$Tries] of [$numResults] results for [$Name]"

            $count = 1
            foreach ($result in $searchResults) {
                $result = "https://jp.jav321.com/video/$result"
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$result]"
                $webRequest = Invoke-RestMethod -Uri $result -Method Get -Verbose:$false
                $resultId = Get-Jav321Id -WebRequest $webRequest
                if ($resultId -eq $Name) {
                    $directUrl = $result
                    break
                }

                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                if ($count -eq $Tries) {
                    break
                }

                $count++
            }

            if ($null -eq $directUrl) {
                Write-Verbose "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Search [$Name] not matched on Jav321"
                return
            } else {
                Write-Output $directUrl
            }
        } else {
            Write-Verbose "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Search [$Name] not matched on Jav321"
            return
        }
    }
}

