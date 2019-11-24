function Get-JavLibraryUrl {
    [CmdletBinding()]
    param (
        [string]$Id,
        [ValidateRange(2, 5)]
        [int]$Tries
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        $cookieName = @()
        $cookieContent = @()
        $requestObject = @()
        $cfPath = Join-Path -Path $PSScriptRoot -ChildPath 'cf.py'
    }

    process {
        $searchUrl = "http://www.javlibrary.com/en/vl_searchbyid.php?keyword=$Id"

        # Run cfscrape request to get cookies and user agent to authorize PowerShell webrequest
        try {
            $cfScrape = python $cfPath $searchUrl
            #$cfScrape = python cf.py $searchUrl
        } catch {
            throw $_
        }

        $cfScrapeSplit = $cfScrape -split "'"
        $cookieName += $cfScrapeSplit[1], $cfScrapeSplit[5]
        $cookieContent += $cfScrapeSplit[3], $cfScrapeSplit[7]
        $userAgent = $cfScrapeSplit[9]

        $requestObject += [pscustomobject]@{
            CookieName    = $cookieName
            CookieContent = $cookieContent
            UserAgent     = $userAgent
        }

        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

        # Create __cfuid cookie
        $cookie = New-Object System.Net.Cookie($requestObject.CookieName[0], $requestObject.CookieContent[0], '/', 'javlibrary.com')
        $session.Cookies.Add($cookie)

        # Create cf_clearance cookie
        $cookie = New-Object System.Net.Cookie($requestObject.CookieName[1], $requestObject.CookieContent[1], '/', 'javlibrary.com')
        $session.Cookies.Add($cookie)

        try {
            $webRequest = Invoke-WebRequest $searchUrl -WebSession $session -UserAgent $requestObject.UserAgent
        } catch {
            throw $_
        }

        # Check if the search uniquely matched a video page
        # If not, we will check the search results and check a few for if they are a match
        $javlibraryUrl = Test-UrlMatch -Url $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri -JavLibrary

        if ($null -eq $javlibraryUrl) {
            $searchResults = $webRequest.Links.href | Where-Object { $_ -match '\.\/\?v=(.*)' }
            $numResults = $searchResults.count
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Unique video match not found, trying to search [$Tries] of [$numResults] results for [$Id]"

            if ($searchResults -ge 3) {
                if ($Tries.IsPresent) {
                    $Tries = $Tries
                } else {
                    $Tries = 3
                }
            } else {
                $Tries = 2
            }

            $count = 1
            foreach ($result in $searchResults) {
                Write-Host $Tries
                $videoId = ($result -split '=')[1]
                $directUrl = "http://www.javlibrary.com/en/?v=$videoId"
                $webRequest = Invoke-WebRequest $directUrl -WebSession $session -UserAgent $requestObject.userAgent
                $resultId = (($webRequest.Content -split '<title>')[1] -split ' ')[0]
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                if ($resultId -eq $Id) {
                    $javlibraryUrl = Test-UrlMatch -Url $webRequest.BaseResponse.RequestMessage.RequestUri.AbsoluteUri -JavLibrary
                    break
                }

                if ($count -gt $Tries) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Search $Id not matched, skipping"
                    break
                }
                $count++
            }
        }

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Search $Id matched"
        Write-Output $javlibraryUrl
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }

}

