function Get-CfSession {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Cfduid,

        [Parameter(Mandatory = $true, Position = 1)]
        [String]$Cfclearance,

        [Parameter(Mandatory = $true, Position = 2)]
        [String]$UserAgent
    )

    process {
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $cookie = New-Object System.Net.Cookie('__cfduid', "$Cfduid", '/', 'javlibrary.com')
        $session.Cookies.Add($cookie)
        $cookie = New-Object System.Net.Cookie('cf_clearance', "$Cfclearance", '/', 'javlibrary.com')
        $session.Cookies.Add($cookie)
        $session.UserAgent = $UserAgent
        Write-Output $session
    }
}
