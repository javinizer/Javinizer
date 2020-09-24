#Requires -PSEdition Core

function Get-JavlibraryData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url,

        [Parameter()]
        [String]$JavlibraryBaseUrl
    )

    process {
        $movieDataObject = @()

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem"
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
            Actress       = Get-JavlibraryActress -WebRequest $webRequest -JavlibraryBaseUrl $JavlibraryBaseUrl
            Genre         = Get-JavlibraryGenre -WebRequest $webRequest
            CoverUrl      = Get-JavlibraryCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-JavlibraryScreenshotUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] JAVLibrary data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
