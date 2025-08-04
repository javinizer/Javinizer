function Get-JavadatabaseData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Object]$UrlObject
    )

    process {
        $Url = if ($UrlObject -is [String]) { $UrlObject } else { $UrlObject.Url }

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error [GET] on URL [$Url]: $PSItem" -Action 'Continue'
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = 'javdatabase'
            Url           = $Url
            ContentId     = Get-JavadatabaseContentId -WebRequest $webRequest
            Id            = if ($UrlObject -is [String]) { Get-JavadatabaseId -WebRequest $webRequest } else { $UrlObject.Id }
            Title         = if ($UrlObject -is [String]) { Get-JavadatabaseTitle -WebRequest $webRequest } else { $UrlObject.Title }
            ReleaseDate   = Get-JavadatabaseReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-JavadatabaseReleaseYear -WebRequest $webRequest
            Runtime       = Get-JavadatabaseRuntime -WebRequest $webRequest
            Director      = Get-JavadatabaseDirector -WebRequest $webRequest
            Maker         = Get-JavadatabaseMaker -WebRequest $webRequest
            Label         = Get-JavadatabaseLabel -WebRequest $webRequest
            Series        = Get-JavadatabaseSeries -WebRequest $webRequest
            Actress       = Get-JavadatabaseActress -WebRequest $webRequest
            Genre         = Get-JavadatabaseGenre -WebRequest $webRequest
            CoverUrl      = Get-JavadatabaseCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-JavadatabaseScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-JavadatabaseTrailerUrl -WebRequest $webRequest
            Rating        = Get-JavadatabaseRating -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] Javdatabase data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
