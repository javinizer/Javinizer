function Get-TokyoHotData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url,

        [Parameter(Position = 1)]
        [String]$Session
    )

    process {
        $movieDataObject = @()

        if ($Session) {
            $loginSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'sessionid'
            $cookie.Value = $Session
            $cookie.Domain = '.tokyo-hot.com'
            $loginSession.Cookies.Add($cookie)
        }

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -WebSession $loginSession -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action 'Continue'
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match 'locale=zh') { 'TokyoHotzh' } else { 'TokyoHot' }
            Url           = $Url
            Id            = Get-TokyoHotId -WebRequest $webRequest
            Title         = Get-TokyoHotTitle -WebRequest $webRequest
            ReleaseDate   = Get-TokyoHotReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-TokyoHotReleaseYear -WebRequest $webRequest
            Runtime       = Get-TokyoHotRuntime -WebRequest $webRequest
            Director      = Get-TokyoHotDirector -WebRequest $webRequest
            Maker         = Get-TokyoHotMaker -WebRequest $webRequest
            Series        = Get-TokyoHotSeries -WebRequest $webRequest
            Actress       = Get-TokyoHotActress -WebRequest $webRequest
            Genre         = Get-TokyoHotGenre -WebRequest $webRequest
            CoverUrl      = Get-TokyoHotCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-TokyoHotScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-TokyoHotTrailerUrl -WebRequest $webRequest
            Description   = Get-TokyoHotDescription -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] TokyoHot data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
