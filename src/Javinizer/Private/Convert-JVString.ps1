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
        [Int]$MaxTitleLength,

        [Parameter()]
        [String]$Delimiter,

        [Parameter()]
        [Boolean]$ActressLanguageJa,

        [Parameter()]
        [Boolean]$FirstNameOrder,

        [Parameter()]
        [Boolean]$GroupActress
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

        $actressObject = @()
        if ($ActressLanguageJa) {
            if ($null -ne $Data.Actress.Japanese) {
                $actressObject = $Data.Actress.JapaneseName
            } elseif ($FirstNameOrder) {
                foreach ($actress in $Data.Actress) {
                    $actressObject += "$($actress.FirstName) $($actress.LastName)".Trim()
                }
            } else {
                foreach ($actress in $Data.Actress) {
                    $actressObject += "$($actress.LastName) $($actress.FirstName)".Trim()
                }
            }
        } elseif ($FirstNameOrder) {
            if ($null -ne $Data.Actress.FirstName) {
                foreach ($actress in $Data.Actress) {
                    $actressObject += "$($actress.FirstName) $($actress.LastName)".Trim()
                }
            } else {
                $actressObject = $Data.Actress.JapaneseName
            }
        } else {
            if ($null -ne $Data.Actress.FirstName) {
                foreach ($actress in $Data.Actress) {
                    $actressObject += "$($actress.LastName) $($actress.FirstName)".Trim()
                }
            } else {
                $actressObject = $Data.Actress.JapaneseName
            }
        }

        $actresses = ($actressObject | Sort-Object) -join $Delimiter

        if ($GroupActress) {
            if (($actresses -split $Delimiter).Count -gt 1) {
                $actresses = '@Group'
            } elseif ($actresses -match 'Unknown') {
                $actresses = '@Unknown'
            }
        } else {
            $actresses = ($actressObject | Sort-Object) -join $Delimiter
        }

        $convertedName = $FormatString `
            -replace '<ID>', "$($Data.Id)" `
            -replace '<CONTENTID>', "$($Data.ContentId)" `
            -replace '<TITLE>', "$($Data.Title)" `
            -replace '<RELEASEDATE>', "$($Data.ReleaseDate)" `
            -replace '<YEAR>', "$(($Data.ReleaseDate -split '-')[0])" `
            -replace '<STUDIO>', "$($Data.Maker)" `
            -replace '<RUNTIME>', "$($Data.Runtime)" `
            -replace '<SET>', "$($Data.Series)" `
            -replace '<LABEL>', "$($Data.Label)" `
            -replace '<ACTORS>', "$actresses" `
            -replace '<ORIGINALTITLE>', "$($Data.AlternateTitle)" `
            -replace '<RESOLUTION>', "$($Data.MediaInfo.VideoHeight)"

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
