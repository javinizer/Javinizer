function Write-JVWebLog {
    param (
        [Parameter()]
        [String]$OriginalPath,

        [Parameter()]
        [String]$DestinationPath,

        [Parameter()]
        [System.IO.FileInfo]$HistoryPath,

        [Parameter()]
        [PSObject]$Data,

        [Parameter()]
        [PSObject]$AllData
    )

    process {
        <# $actress = foreach ($actor in $Data.Actress) {
            $name = "$($actor.LastName) $($actor.FirstName)".Trim()
            if ($null -eq $name -or $name -eq '') {
                $name = $actor.JapaneseName
            }
        } #>

        $message = [PSCustomObject]@{
            Timestamp       = Get-Date -Format o
            Path            = $OriginalPath
            DestinationPath = $DestinationPath
            Id              = $Data.Id
            ContentId       = $Data.ContentId
            DisplayName     = $Data.DisplayName
            Title           = $Data.Title
            AlternateTitle  = $Data.AlternateTitle
            Description     = $Data.Description
            Rating          = $Data.Rating.Count
            Votes           = $Data.Rating.Votes
            ReleaseDate     = $Data.ReleaseDate
            Maker           = $Data.Maker
            Label           = $Data.Label
            Runtime         = $Data.Runtime
            Director        = $Data.Director
            Actress         = $Data.Actress | ConvertTo-Json -Depth 32 -Compress
            Genre           = $Data.Genre | ConvertTo-Json -Depth 32 -Compress
            Series          = $Data.Series
            Tag             = $Data.Tag | ConvertTo-Json -Depth 32 -Compress
            Tagline         = $Data.Tagline | ConvertTo-Json -Depth 32 -Compress
            Credits         = $Data.Credits | ConvertTo-Json -Depth 32 -Compress
            CoverUrl        = $Data.CoverUrl
            ScreenshotUrl   = $Data.ScreenshotUrl | ConvertTo-Json -Depth 32 -Compress
            TrailerUrl      = $Data.TrailerUrl
            MediaInfo       = $Data.MediaInfo | ConvertTo-Json -Depth 32 -Compress
            AllData         = $AllData | ConvertTo-Json -Depth 32 -Compress
        }

        $LogMutex = New-Object System.Threading.Mutex($false, "LogMutex")
        $LogMutex.WaitOne() | Out-Null
        $message | Export-Csv -LiteralPath $HistoryPath -Append -Encoding utf8 -UseQuotes Always
        $LogMutex.ReleaseMutex() | Out-Null
    }
}
