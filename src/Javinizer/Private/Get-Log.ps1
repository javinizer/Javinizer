function Get-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,
        [string]$LogLevel,
        [string]$LogView,
        [string]$Order,
        [int]$Entries
    )

    process {

        $logColorHash = @{
            #'INFO'  = 'Green';
            'ERROR' = 'Red';
            'WARN'  = 'Yellow'
        }

        # Replace backslash with double backslash to conform with accepted JSON format
        $log = Get-Content -Path $javinizerLogPath | ForEach-Object { $_ -replace '\\', '\\' } | ConvertFrom-Json

        if ($LogView -eq 'Object') {
            Write-Output $log
        }

        else {
            # Set object filter to the desired loglevel
            if ($PSBoundParameters.ContainsKey('LogLevel')) {
                if ($Order -eq 'Asc') {
                    $log = $log | Where-Object { $_.level -eq "$LogLevel" } | Select-Object -First $Entries
                } else {
                    $log = $log | Where-Object { $_.level -eq "$LogLevel" } | Sort-Object timestamp -Descending | Select-Object -First $Entries
                }
            } else {
                if ($Order -eq 'Asc') {
                    $log = $log | Sort-Object timestamp | Select-Object -First $Entries
                } else {
                    $log = $log | Sort-Object timestamp -Descending | Select-Object -First $Entries
                }
            }

            if ($LogView -eq 'Table') {
                $log | Format-Table -AutoSize | Format-Color $logColorHash
            } elseif ($LogView -eq 'Grid') {
                $log | Out-GridView
            } else {
                $log | Format-Color $logColorHash
            }
        }
    }
}
