function Get-JavbusData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()

        try {
            Write-JLog -Level Debug -Message "Performing [GET] on URL [$Url]"
            $webRequest = Invoke-RestMethod -Uri $Url -Verbose:$false
        } catch {
            Write-JLog -Level Error -Message "Error [GET] on URL [$Url]: $PSItem"
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match '/ja') { 'javbusja' } elseif ($Url -match '/zh') { 'javbuszh' } else { 'javbuszh' }
            Url           = $Url
            Id            = Get-JavbusId -WebRequest $webRequest
            Title         = Get-JavbusTitle -WebRequest $webRequest
            ReleaseDate   = Get-JavbusReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-JavbusReleaseYear -WebRequest $webRequest
            Runtime       = Get-JavbusRuntime -WebRequest $webRequest
            Director      = Get-JavbusDirector -WebRequest $webRequest
            Maker         = Get-JavbusMaker -WebRequest $webRequest
            Label         = Get-JavbusLabel -WebRequest $webRequest
            Series        = Get-JavbusSeries -WebRequest $webRequest
            Rating        = Get-JavbusRating -WebRequest $webRequest
            Actress       = Get-JavbusActress -WebRequest $webRequest
            Genre         = Get-JavbusGenre -WebRequest $webRequest
            CoverUrl      = Get-JavbusCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-JavbusScreenshotUrl -WebRequest $webRequest
        }

        Write-JLog -Level Debug -Message "JavBus data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
