function Get-TokyoHotData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url

    )

    process {
        $movieDataObject = @()

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -WebSession $loginSession -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action 'Continue'
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match 'lang=ja') { 'tokyohotja' } elseif ($Url -match 'lang=zh-TW') { 'tokyohotzh' } else { 'tokyohot' }
            Url           = $Url
            Id            = Get-TokyoHotId -WebRequest $webRequest
            Title         = Get-TokyoHotTitle -WebRequest $webRequest
            Description   = Get-TokyoHotDescription -WebRequest $webRequest
            ReleaseDate   = Get-TokyoHotReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-TokyoHotReleaseYear -WebRequest $webRequest
            Runtime       = Get-TokyoHotRuntime -WebRequest $webRequest
            Maker         = Get-TokyoHotMaker -WebRequest $webRequest
            Series        = Get-TokyoHotSeries -WebRequest $webRequest
            Actress       = Get-TokyoHotActress -WebRequest $webRequest
            Genre         = Get-TokyoHotGenre -WebRequest $webRequest
            CoverUrl      = Get-TokyoHotCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-TokyoHotScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-TokyoHotTrailerUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] TokyoHot data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
