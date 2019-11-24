function Get-CFSessionObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Url
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $cookieName = @()
        $cookieContent = @()
        $requestObject = @()
        $cfPath = Join-Path -Path $PSScriptRoot -ChildPath 'cf.py'
    }

    process {
        try {
            $cfScrape = python $cfPath $Url
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

        # Replace WebRequest session UserAgent with UserAgent created by cfscrape
        # This is needed so that you will not be flagged as a bot by CloudFlare
        $session.UserAgent = $requestObject.UserAgent
    }

    end {
        $global:Session = $session
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
