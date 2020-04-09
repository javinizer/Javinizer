function Format-Color([hashtable] $Colors = @{ }, [switch] $SimpleMatch) {

    $lines = ($input | Out-String) -replace "`r", "" -split "`n"
    foreach ($line in $lines) {
        $color = ''
        foreach ($pattern in $Colors.Keys) {
            if (!$SimpleMatch -and $line -match $pattern) {
                $color = $Colors[$pattern]
                if ($color) {
                    $seg1 = ($line -split $pattern)[0]
                    $seg2 = ($line -split $pattern)[1]
                    Write-Host $seg1 -NoNewLine
                    Write-Host $pattern -ForegroundColor $color -NoNewline
                    Write-Host $seg2
                }
            }

            elseif ($SimpleMatch -and $line -like $pattern) {
                $color = $Colors[$pattern]
                if ($color) {
                    $seg1 = ($line -split $pattern)[0]
                    $seg2 = ($line -split $pattern)[1]
                    Write-Host $seg1 -NoNewLine
                    Write-Host $pattern -ForegroundColor $color -NoNewline
                    Write-Host $seg2
                }
            }
        }
        if (!$color) {
            Write-Host $line
        }
    }
}
