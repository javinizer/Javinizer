#Requires -PSEdition Core

function Get-DmmData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()
        $dmmUrl = $Url

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "Performing [GET] on URL [$dmmUrl]"
            $webRequest = Invoke-WebRequest -Uri $dmmUrl -Method Get -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "Error [GET] on URL [$dmmUrl]: $PSItem"
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = 'dmm'
            Url           = $dmmUrl
            Id            = Get-DmmContentId -WebRequest $webRequest
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
            Actress       = Get-DmmActress -WebRequest $webRequest
            Genre         = Get-DmmGenre -WebRequest $webRequest
            CoverUrl      = Get-DmmCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-DmmScreenshotUrl -WebRequest $webRequest
            #TrailerUrl    = Get-DmmTrailerUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "DMM data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
