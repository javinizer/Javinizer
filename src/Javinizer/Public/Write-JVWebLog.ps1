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
        $message = [PSCustomObject]@{
            Timestamp       = Get-Date -Format s
            Path            = $OriginalPath
            DestinationPath = $DestinationPath
            Id              = $Data.Id
            ReleaseDate     = $Data.ReleaseDate
            Maker           = $Data.Maker
        }

        $LogMutex = New-Object System.Threading.Mutex($false, "LogMutex")
        $LogMutex.WaitOne() | Out-Null
        $message | Export-Csv -LiteralPath $HistoryPath -Append -Encoding utf8 -UseQuotes Always
        $LogMutex.ReleaseMutex() | Out-Null
    }
}
