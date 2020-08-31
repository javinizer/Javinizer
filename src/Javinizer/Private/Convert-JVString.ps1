function Convert-JVString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$Data,
        [Parameter(Mandatory = $true)]
        [String]$FormatString,
        [Parameter()]
        [Int]$PartNumber,
        [Parameter()]
        [Int]$MaxTitleLength
    )

    process {
        # These symbols need to be removed to create a valid Windows filesystem name
        $invalidSymbols = @(
            '\',
            '/',
            ':',
            '*',
            '?',
            '"',
            '<',
            '>',
            '|',
            "'"
        )

        if ($maxTitleLength) {
            if ($Data.Title.Length -ge $MaxTitleLength) {
                $shortTitle = $Data.Title.Substring(0, $MaxTitleLength)
                $splitTitle = $shortTitle -split ' '
                if ($splitTitle.Count -gt 1) {
                    # Remove the last word of the title just in case it is cut off
                    $title = ($splitTitle[0..($splitTitle.Length - 2)] -join ' ')
                    if ($title[-1] -match '\W') {
                        $Data.Title = ($title.Substring(0, $title.Length - 2)) + '...'
                    } else {
                        $Data.Title = $title + '...'
                    }
                } else {
                    $Data.Title = $shortTitle + '...'
                }
            }
        }

        $convertedName = $FormatString `
            -replace '<ID>', "$($Data.Id)" `
            -replace '<TITLE>', "$($Data.Title)" `
            -replace '<RELEASEDATE>', "$($Data.ReleaseDate)" `
            -replace '<YEAR>', "$(($Data.ReleaseDate -split '-')[0])" `
            -replace '<STUDIO>', "$($Data.Maker)" `
            -replace '<RUNTIME>', "$($Data.Runtime)" `
            -replace '<SET>', "$($Data.Series)" `
            -replace '<LABEL>', "$($Data.Label)" `
            -replace '<ORIGINALTITLE>', "$($Data.AlternateTitle)"

        foreach ($symbol in $invalidSymbols) {
            if ([regex]::Escape($symbol) -eq '/') {
                $convertedName = $convertedName -replace [regex]::Escape($symbol), '-'
            } else {
                $convertedName = $convertedName -replace [regex]::Escape($symbol), ''
            }
        }

        if ($PartNumber) {
            $convertedName += "-pt$PartNumber"
        }

        Write-Output $convertedName
    }
}
