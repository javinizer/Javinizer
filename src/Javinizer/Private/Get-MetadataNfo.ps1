function Get-MetadataNfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject,
        [object]$Settings,
        [object]$R18ThumbCsv
    )

    begin {
        $javlibraryGenres = @()
        $r18Genres = @()
        $actressObject = @()
        $r18CsvPath = Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs.csv'

        if ($Settings.Metadata.'normalize-genres' -eq 'True') {
            try {
                $genreCsvPath = Join-Path -Path $ScriptRoot -ChildPath 'genres.csv'
                $normalizedGenres = Import-Csv -Path $genreCsvPath
                $javlibraryGenres = $normalizedGenres.javlibrary
                $r18Genres = $normalizedGenres.r18
            } catch {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Error loading genres csv [$genreCsvPath]"
                throw $_
            }
        }

        $displayName = (($DataObject.DisplayName -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        $alternateTitle = (($DataObject.AlternateTitle -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        $director = (($DataObject.Director -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        $maker = (($DataObject.Maker -replace '&', '&amp;') -replace '<', '(') -replace , '>', ''
        $description = (($DataObject.Description -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        $series = (($DataObject.Series -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        if ($Settings.Metadata.'first-last-name-order' -eq 'True') {
            $csvFullName = $R18ThumbCsv.FullName
            $csvFullNameAlias = $R18ThumbCsv.Alias
        } else {
            $csvFullName = $R18ThumbCsv.FullNameReversed
            $csvFullNameAlias = $R18ThumbCsv.Alias
        }
    }

    process {
        $nfoString = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<movie>
    <title>$displayName</title>
    <originaltitle>$alternateTitle</originaltitle>
    <id>$($DataObject.Id)</id>
    <releasedate>$($DataObject.ReleaseDate)</releasedate>
    <year>$($DataObject.ReleaseYear)</year>
    <director>$director</director>
    <studio>$maker</studio>
    <rating>$($DataObject.Rating)</rating>
    <votes>$($DataObject.RatingCount)</votes>
    <plot>$description</plot>
    <runtime>$($DataObject.Runtime)</runtime>
    <trailer>$($DataObject.TrailerUrl)</trailer>
    <mpaa>XXX</mpaa>

"@
        if ($Settings.Metadata.'add-series-as-tag' -eq 'True') {
            $tagNfoString = @"
    <tag>Series: $series</tag>

"@
            $nfoString = $nfoString + $tagNfoString
        }

        foreach ($genre in $DataObject.Genre) {
            $genre = $genre -replace '&', '&amp;'
            if ($Settings.Metadata.'normalize-genres' -eq 'True') {
                if ($javlibraryGenres -like $genre) {
                    $index = $javlibraryGenres.IndexOf($genre)
                    if ($index -ne -1) {
                        $genre = $r18Genres[$index]
                    }
                }
            }
            $genreNfoString = @"
    <genre>$genre</genre>

"@
            $nfoString = $nfoString + $genreNfoString
        }

        if ($DataObject.Actress.Count -gt 0) {
            if ($DataObject.Actress.Count -eq 1) {
                if (-not ($R18ThumbCsv.FullName -like $DataObject.Actress)) {
                    if (-not (($DataObject.ActressThumbUrl -like '*nowprinting*') -or ($null -eq $DataObject.ActressThumbUrl))) {
                        $actressFirstName, $actressLastName = $DataObject.Actress -split ' '
                        $actressFullName = $actressFirstName + ' ' + $actressLastName
                        $actressFullNameReversed = $actressLastName + ' ' + $actressFirstName
                        $actressThumbUrl = ($DataObject.ActressThumbUrl).ToString()
                        $actressObject += [pscustomobject]@{
                            FirstName        = $actressFirstName.Trim()
                            LastName         = $actressLastName.Trim()
                            FullName         = $actressFullName.Trim()
                            FullNameReversed = $actressFullNameReversed.Trim()
                            ThumbUrl         = (@($DataObject.ActressThumbUrl) | Out-String).Trim()
                            Alias            = ''
                        }

                        try {
                            $actressObject | Export-Csv -LiteralPath $r18CsvPath -Append -NoTypeInformation
                        } catch {
                            Write-Warning "[$($MyInvocation.MyCommand.Name)] Error appending actress to [$r18CsvPath], waiting 2 seconds and trying again"
                            Start-Sleep -Seconds 2
                            try {
                                $actressObject | Export-Csv -LiteralPath $r18CsvPath -Append
                            } catch {
                                Write-Warning "[$($MyInvocation.MyCommand.Name)] Error appending actress to [$r18CsvPath], skipping"
                            }
                        }
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Actress [$($DataObject.Actress)] written to [$r18CsvPath]"
                    }
                }

                if (($DataObject.ActressThumbUrl -like '*nowprinting*') -or ($null -eq $DataObject.ActressThumbUrl)) {
                    if (($csvFullName -like $DataObject.Actress) -or ($csvFullNameAlias -like $DataObject.Actress)) {
                        $index = $csvFullname.IndexOf("$($DataObject.Actress)")
                        if ($index -eq -1) {
                            $index = $csvFullnameAlias.IndexOf("$($DataObject.Actress)")
                        }
                        if ($Settings.Metadata.'convert-alias-to-originalname' -eq 'True') {
                            if ($Settings.Metadata.'first-last-name-order' -eq 'True') {
                                $DataObject.Actress = $R18ThumbCsv.FullName[$index]
                            } else {
                                $DataObject.Actress = $R18ThumbCsv.FullNameReversed[$index]
                            }
                        }
                        $DataObject.ActressThumbUrl = $R18ThumbCsv.ThumbUrl[$index]
                    } else {
                        $DataObject.ActressThumbUrl = ''
                    }
                }

                $actressNfoString = @"
    <actor>
        <name>$($DataObject.Actress)</name>
        <thumb>$($DataObject.ActressThumbUrl)</thumb>
        <role>Actress</role>
    </actor>

"@
            } else {
                for ($i = 0; $i -lt $DataObject.Actress.Count; $i++) {
                    if (-not ($R18ThumbCsv.FullName -like $DataObject.Actress[$i])) {
                        if (($DataObject.ActressThumbUrl[$i] -notlike '*nowprinting*') -or ($null -ne $DataObject.ActressThumbUrl[$i])) {
                            $actressFirstName, $actressLastName = $DataObject.Actress[$i] -split ' '
                            $actressFullName = $actressFirstName + ' ' + $actressLastName
                            $actressFullNameReversed = $actressLastName + ' ' + $actressFirstName

                            $actressObject = [pscustomobject]@{
                                FirstName        = $actressFirstName.Trim()
                                LastName         = $actressLastName.Trim()
                                FullName         = $actressFullName.Trim()
                                FullNameReversed = $actressFullNameReversed.Trim()
                                ThumbUrl         = $DataObject.ActressThumbUrl[$i]
                                Alias            = ''
                            }

                            $actressObject | Export-Csv -LiteralPath $r18CsvPath -Append -NoTypeInformation
                            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Actress [$($DataObject.Actress[$i])] written to [$r18CsvPath]"
                        }
                    }

                    if ($null -eq $DataObject.ActressThumbUrl) {
                        # Create empty array amounting to number of actresses found if scraped from javlibrary
                        # This will allow matching actresses from r18 thumb csv
                        $DataObject.ActressThumbUrl = @()
                        foreach ($actress in $DataObject.Actress) {
                            $DataObject.ActressThumbUrl += ''
                        }
                    } else {
                        if (-not ($R18ThumbCsv.FullName -like $DataObject.Actress[$i])) {
                            if (-not (($DataObject.ActressThumbUrl[$i] -notlike '*nowprinting*') -or ($null -ne $DataObject.ActressThumbUrl[$i]))) {
                                $actressFirstName, $actressLastName = $DataObject.Actress[$i] -split ' '
                                $actressFullName = $actressFirstName + ' ' + $actressLastName
                                $actressFullNameReversed = $actressLastName + ' ' + $actressFirstName

                                $actressObject = [pscustomobject]@{
                                    FirstName        = $actressFirstName.Trim()
                                    LastName         = $actressLastName.Trim()
                                    FullName         = $actressFullName.Trim()
                                    FullNameReversed = $actressFullNameReversed.Trim()
                                    ThumbUrl         = $DataObject.ActressThumbUrl[$i]
                                    Alias            = ''
                                }

                                $actressObject | Export-Csv -LiteralPath $r18CsvPath -Append -NoTypeInformation
                                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Actress [$($DataObject.Actress[$i])] written to [$r18CsvPath]"
                            }
                        }
                    }

                    if (($dataObject.ActressThumbUrl[$i] -like '*nowprinting*') -or ($DataObject.ActressThumbUrl[$i] -eq '')) {
                        if (($csvFullName -like $DataObject.Actress[$i]) -or ($csvFullNameAlias -like $DataObject.Actress[$i])) {
                            $index = $csvFullname.IndexOf("$($DataObject.Actress[$i])")
                            if ($index -eq -1) {
                                $index = $csvFullnameAlias.IndexOf("$($DataObject.Actress[$i])")
                            }
                            if ($Settings.Metadata.'convert-alias-to-originalname' -eq 'True') {
                                if ($Settings.Metadata.'first-last-name-order' -eq 'True') {
                                    $DataObject.Actress[$i] = $R18ThumbCsv.FullName[$index]
                                } else {
                                    $DataObject.Actress[$i] = $R18ThumbCsv.FullNameReversed[$index]
                                }
                            }
                            $DataObject.ActressThumbUrl[$i] = $R18ThumbCsv.ThumbUrl[$index]
                        } else {
                            $DataObject.ActressThumbUrl[$i] = ''
                        }
                    }
                    $actressNfoString += @"
    <actor>
        <name>$($DataObject.Actress[$i])</name>
        <thumb>$($DataObject.ActressThumbUrl[$i])</thumb>
        <role>Actress</role>
    </actor>

"@
                }


            }
        }

        $nfoString = $nfoString + $actressNfoString
        $endNfoString = @"
</movie>
"@
        $nfoString = $nfoString + $endNfoString

        Write-Debug "[$($MyInvocation.MyCommand.Name)] NFO String: `
        $nfoString"
        Write-Output $nfoString
    }
}



<#

if match actress + ActressThumbUrl
check r18 csv
    if not in r18 csv
        add row
    else
        don't do anything


#>
