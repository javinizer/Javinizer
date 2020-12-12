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
        [Boolean]$GroupActress,

        [Parameter()]
        [Boolean]$IsFileName
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
                if ($shortTitle -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                    $Data.Title = $shortTitle + '...'
                } else {
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

            if ($Data.AlternateTitle.Length -ge $MaxTitleLength) {
                $shortTitle = $Data.AlternateTitle.Substring(0, $MaxTitleLength)
                if ($shortTitle -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                    $Data.AlternateTitle = $shortTitle + '...'
                } else {
                    $splitTitle = $shortTitle -split ' '
                    if ($splitTitle.Count -gt 1) {
                        # Remove the last word of the title just in case it is cut off
                        $title = ($splitTitle[0..($splitTitle.Length - 2)] -join ' ')
                        if ($title[-1] -match '\W') {
                            $Data.AlternateTitle = ($title.Substring(0, $title.Length - 2)) + '...'
                        } else {
                            $Data.AlternateTitle = $title + '...'
                        }
                    } else {
                        $Data.AlternateTitle = $shortTitle + '...'
                    }
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
            } elseif ($actresses -match 'Unknown' -or $actresses -eq '') {
                $actresses = '@Unknown'
            }
        } else {
            $actresses = ($actressObject | Sort-Object) -join $Delimiter
        }

        # This will set blank data properties as Unknown
        if ($IsFileName) {
            $Data.PSObject.Properties | ForEach-Object {
                if ($null -eq $_.Value -or $_.Value -eq '') {
                    $Data."$($_.Name)" = 'Unknown'
                }
            }
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
