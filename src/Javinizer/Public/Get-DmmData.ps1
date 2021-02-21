function Get-DmmData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url,

        [Parameter()]
        [Boolean]$ScrapeActress
    )

    process {
        $movieDataObject = @()
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $cookie = New-Object System.Net.Cookie
        $cookie.Name = 'age_check_done'
        $cookie.Value = '1'
        $cookie.Domain = 'dmm.co.jp'
        $session.Cookies.Add($cookie)

        if ($Url -match '/en/') {
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'ckcy'
            $cookie.Value = '2'
            $cookie.Domain = 'dmm.co.jp'
            $session.Cookies.Add($cookie)
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'cklg'
            $cookie.Value = 'en'
            $cookie.Domain = 'dmm.co.jp'
            $session.Cookies.Add($cookie)
        }

        $webRequest = Invoke-JVWebRequest -Uri $Url -WebSession $session -Method Get -Verbose:$false

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match '/en/') { 'dmm' } else { 'dmmja' }
            Url           = $Url
            Id            = Get-DmmId -Url $Url
            ContentId     = Get-DmmContentId -Url $Url
            Title         = Get-DmmTitle -WebRequest $webRequest
            Description   = Get-DmmDescription -WebRequest $webRequest
            ReleaseDate   = Get-DmmReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-DmmReleaseYear -WebRequest $webRequest
            Runtime       = Get-DmmRuntime -WebRequest $webRequest
            Director      = Get-DmmDirector -WebRequest $webRequest
            Maker         = Get-DmmMaker -WebRequest $webRequest
            Label         = Get-DmmLabel -WebRequest $webRequest
            Series        = Get-DmmSeries -WebRequest $webRequest
            Rating        = Get-DmmRating -WebRequest $webRequest
            Actress       = Get-DmmActress -WebRequest $webRequest -ScrapeActress:$ScrapeActress
            Genre         = Get-DmmGenre -WebRequest $webRequest
            CoverUrl      = Get-DmmCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-DmmScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-DmmTrailerUrl -WebRequest $webRequest -Session:$session
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] DMM data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
