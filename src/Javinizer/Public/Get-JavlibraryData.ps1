function Get-JavlibraryData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url,

        [Parameter()]
        [String]$JavlibraryBaseUrl,

        [Parameter()]
        [PSObject]$Session
    )

    process {
        $movieDataObject = @()
        $webRequest = Invoke-JVWebRequest -Uri $Url -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match '/ja/') { 'javlibraryja' } elseif ($Url -match '/cn/' -or $Url -match '/tw/') { 'javlibraryzh' } else { 'javlibrary' }
            Url           = $Url
            Id            = Get-JavlibraryId -WebRequest $webRequest
            AjaxId        = Get-JavlibraryAjaxId -WebRequest $webRequest
            Title         = Get-JavlibraryTitle -WebRequest $webRequest
            ReleaseDate   = Get-JavlibraryReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-JavlibraryReleaseYear -WebRequest $webRequest
            Runtime       = Get-JavlibraryRuntime -WebRequest $webRequest
            Director      = Get-JavlibraryDirector -WebRequest $webRequest
            Maker         = Get-JavlibraryMaker -WebRequest $webRequest
            Label         = Get-JavlibraryLabel -WebRequest $webRequest
            Rating        = Get-JavlibraryRating -WebRequest $webRequest
            Actress       = Get-JavlibraryActress -WebRequest $webRequest -JavlibraryBaseUrl $JavlibraryBaseUrl -Session:$Session -Url $Url
            Genre         = Get-JavlibraryGenre -WebRequest $webRequest
            CoverUrl      = Get-JavlibraryCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-JavlibraryScreenshotUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] JAVLibrary data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
