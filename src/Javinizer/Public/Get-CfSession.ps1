function Get-CfSession {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$__cf_bm,

        [Parameter(Mandatory = $true, Position = 1)]
        [String]$cf_clearance,

        [Parameter(Mandatory = $true, Position = 2)]
        [String]$UserAgent,

        [Parameter()]
        [String]$BaseUrl
    )

    process {
        $BaseUrl = $BaseUrl -replace 'http(s)?:\/\/(www)?'
        $WwwUrl = 'www' + $BaseUrl
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $cookie = New-Object System.Net.Cookie('__cf_bm', "$__cf_bm", '/', "$WwwUrl")
        $session.Cookies.Add($cookie)
        $cookie = New-Object System.Net.Cookie('cf_clearance', "$cf_clearance", '/', "$BaseUrl")
        $session.Cookies.Add($cookie)

        $session.UserAgent = $UserAgent

        Write-Output $session
    }
}
