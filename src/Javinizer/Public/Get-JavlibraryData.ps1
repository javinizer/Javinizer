function Get-JavlibraryData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()

        try {
            Write-JVLog -Level Debug -Message "Performing [GET] on URL [$Url] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
        } catch {
            Write-JVLog -Level Error -Message "Error [GET] on URL [$Url]: $PSItem"
        }

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
            Actress       = Get-JavlibraryActress -WebRequest $webRequest
            Genre         = Get-JavlibraryGenre -WebRequest $webRequest
            CoverUrl      = Get-JavlibraryCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-JavlibraryScreenshotUrl -WebRequest $webRequest
        }

        Write-JVLog -Level Debug -Message "JAVLibrary data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
