function Get-JVMediaInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.IO.FileInfo]$Path
    )

    $fullMetadata = ((mediainfo --Full $Path --Output=JSON) | ConvertFrom-Json).media.track
    $videoMetadata = $fullMetaData | Where-Object { $_.'@type' -eq 'Video' }[0]
    $audioMetadata = ($fullMetaData | Where-Object { $_.'@type' -eq 'Audio' })[0]
    $metadata = [PSCustomObject]@{
        VideoCodec    = $videoMetadata.CodecID
        VideoAspect   = $videoMetadata.DisplayAspectRatio_String
        VideoWidth    = $videoMetadata.Width
        VideoHeight   = $videoMetadata.Height
        VideoDuration = [Math]::Round($videoMetadata.Duration)
        AudioCodec    = $audioMetadata.CodecID
        AudioLanguage = $audioMetadata.Language
        AudioChannels = $audioMetadata.Channels
    }
    Write-Output $metadata
}
