function Write-JVWebLog {
    param (
        [Parameter()]
        [String]$OriginalPath,

        [Parameter()]
        [String]$DestinationPath,

        [Parameter()]
        [System.IO.FileInfo]$HistoryPath,

        [Parameter()]
        [PSObject]$Data
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
            Actress         = $Data.Actress | ConvertTo-Json -Compress
            Genre           = $Data.Genre | ConvertTo-Json -Compress
            Series          = $Data.Series
            Tag             = $Data.Tag | ConvertTo-Json -Compress
            Tagline         = $Data.Tagline | ConvertTo-Json -Compress
            Credits         = $Data.Credits | ConvertTo-Json -Compress
            CoverUrl        = $Data.CoverUrl
            ScreenshotUrl   = $Data.ScreenshotUrl | ConvertTo-Json -Compress
            TrailerUrl      = $Data.TrailerUrl
            MediaInfo       = $Data.MediaInfo | ConvertTo-Json -Compress
        }

        $LogMutex = New-Object System.Threading.Mutex($false, "LogMutex")
        $LogMutex.WaitOne() | Out-Null
        $message | Export-Csv -LiteralPath $HistoryPath -Append -Encoding utf8 -UseQuotes Always
        $LogMutex.ReleaseMutex() | Out-Null
    }
}
