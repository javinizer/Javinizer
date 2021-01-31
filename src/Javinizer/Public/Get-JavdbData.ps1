function Get-JavdbData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action 'Continue'
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match 'locale=zh') { 'Javdbzh' } else { 'Javdb' }
            Url           = $Url
            Id            = Get-JavdbId -WebRequest $webRequest
            Title         = Get-JavdbTitle -WebRequest $webRequest
            ReleaseDate   = Get-JavdbReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-JavdbReleaseYear -WebRequest $webRequest
            Runtime       = Get-JavdbRuntime -WebRequest $webRequest
            Director      = Get-JavdbDirector -WebRequest $webRequest
            Maker         = Get-JavdbMaker -WebRequest $webRequest
            Series        = Get-JavdbSeries -WebRequest $webRequest
            Actress       = Get-JavdbActress -WebRequest $webRequest
            Genre         = Get-JavdbGenre -WebRequest $webRequest
            CoverUrl      = Get-JavdbCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-JavdbScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-JavdbTrailerUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Javdb data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
