function New-CloudflareSession {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Position = 0)]
        [string]$Url = "http://www.javlibrary.com/en/",
        [string]$ScriptRoot
    )

    begin {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        $cookieName = @()
        $cookieContent = @()
        $requestObject = @()
        $cfPath = Join-Path -Path $ScriptRoot -ChildPath 'cfscraper.py'
    }

    process {
        if ($PSCmdlet.ShouldProcess('Current Shell', 'Create new CloudFlare session')) {
            try {
                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                    $cfScrape, $userAgent = python $cfPath $Url
                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                    $cfScrape, $userAgent = python3 $cfPath $Url
                }
            } catch {
                throw $_
            }

            $cfScrapeSplit = ($cfScrape -split ";").Trim()

            foreach ($cookie in $cfScrapeSplit) {
                $cookieName += ($cookie -split '=')[0]
                $cookieContent += ($cookie -split '=')[1]
            }

            $requestObject += [pscustomobject]@{
                CookieName    = $cookieName
                CookieContent = $cookieContent
                UserAgent     = $userAgent
            }

            $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession


            # Create __cfuid cookie
            $cookie = New-Object System.Net.Cookie($requestObject.CookieName[0], $requestObject.CookieContent[0], '/', 'javlibrary.com')
            $session.Cookies.Add($cookie)
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Cookie __cfuid: [$($requestObject.CookieContent[0])]"


            # Create cf_clearance cookie
            $cookie = New-Object System.Net.Cookie($requestObject.CookieName[1], $requestObject.CookieContent[1], '/', 'javlibrary.com')
            $session.Cookies.Add($cookie)
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Cookie cf_clearance: [$($requestObject.CookieContent[1])]"

            # Replace WebRequest session UserAgent with UserAgent created by cfscrape
            # This is needed so that you will not be flagged as a bot by CloudFlare
            $session.UserAgent = $requestObject.UserAgent
        }
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] UserAgent: [$($session.UserAgent)]"
        $global:Session = $session
        $global:SessionCFDUID = $requestObject.CookieContent[0]
    }

    end {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Successfully created session with Cloudflare"
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
