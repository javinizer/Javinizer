function Get-AventertainmentData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()
        $webRequest = Invoke-JVWebRequest -Uri $Url -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match 'languageID=1') { 'aventertainment' } else { 'aventertainmentja' }
            Url           = $Url
            Id            = Get-AventertainmentId -WebRequest $webRequest
            Title         = Get-AventertainmentTitle -WebRequest $webRequest
            ReleaseDate   = Get-AventertainmentReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-AventertainmentReleaseYear -WebRequest $webRequest
            Runtime       = Get-AventertainmentRuntime -WebRequest $webRequest
            Maker         = Get-AventertainmentMaker -WebRequest $webRequest
            Actress       = Get-AventertainmentActress -WebRequest $webRequest -Url $Url
            Genre         = Get-AventertainmentGenre -WebRequest $webRequest
            CoverUrl      = Get-AventertainmentCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-AventertainmentScreenshotUrl -WebRequest $webRequest
        }

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] AVEntertainment data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
