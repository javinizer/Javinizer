function Update-JVNfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [System.IO.DirectoryInfo]$Path,

        [Parameter(Mandatory = $true)]
        [PSObject]$Settings,

        [Parameter()]
        [Switch]$Preview,

        [Parameter()]
        [Int]$Total
    )

    begin {
        $index = 1
        if ($Preview) {
            # Don't write to the log file if the function is run in Preview mode
            $script:JVLogWrite = '0'
        }

        $thumbCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'
        $genreCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvGenres.csv'
        $uncensorCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvUncensor.csv'
        $tagCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvTags.csv'

        $locationSettings = @(
            'location.thumbcsv',
            'location.genrecsv',
            'location.uncensorcsv',
            'location.tagcsv'
        )

        $locations = foreach ($setting in $locationSettings) {
            [PSCustomObject]@{
                Name    = (($setting -split '\.')[1] -split 'csv')[0]
                Setting = $setting
            }
        }

        # If the csv locations are defined in the settings file, we want to prefer them over the default ones
        foreach ($location in $locations) {
            if ($Settings."$($location.Setting)" -ne '') {
                if (Test-Path -Path $Settings."$($location.Setting)") {
                    Set-Variable -Name "$($location.Name)CsvPath" -Value $Settings."$($location.Setting)"
                } else {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "Invalid $($location.Name) csv path [$($Settings.'location.thumbcsv')]: $PSItem"
                }
            }
        }

        if ($Settings.'sort.metadata.thumbcsv') {
            $thumbCsv = Import-Csv -Path $thumbCsvPath
        }

        if ($Settings.'sort.metadata.genrecsv') {
            $genreCsv = Import-Csv -Path $genreCsvPath
        }

        if ($Settings.'sort.metadata.tagcsv') {
            $tagCsv = Import-Csv -Path $tagCsvPath
        }

        if ($Settings.'sort.metadata.genre.ignore') {
            $ignoreGenre = $Settings.'sort.metadata.genre.ignore'
        }

        $uncensorCsv = Import-Csv -Path $uncensorCsvPath

        # $translateLanguage = $Settings.'sort.metadata.nfo.translate.language'
    }

    process {
        $percentComplete = [math]::Round($index / $Total * 100)
        Write-Progress -Id 1 -Activity "Checking nfo: $Path" -Status "$percentComplete% Complete: $index / $total" -PercentComplete $percentComplete
        try {
            [xml]$nfo = Get-Content -LiteralPath $Path
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "Error occurred when retrieving nfo: $PSItem"
        }

        $ratingObject = [PSCustomObject]@{
            Rating = $nfo.movie.rating
            Votes  = $nfo.movie.votes
        }

        if ($nfo.movie.premiered) {
            $releaseDate = $nfo.movie.premiered
        } else {
            $releaseDate = $nfo.movie.releasedate
        }

        $actressObject = foreach ($actress in $nfo.movie.actor) {

            if ($actress.Name -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                if ($Settings.'sort.metadata.nfo.firstnameorder') {
                    $firstName = ($actress.altname -split ' ')[0]
                    $lastName = ($actress.altname -split ' ')[1]
                    $japaneseName = $actress.name
                } else {
                    $nameParts = ($actress.altname -split ' ').Count
                    if ($nameParts -eq 1) {
                        $lastName = $null
                        $firstName = $actress.altname
                    } else {
                        $lastName = ($actress.altname -split ' ')[0]
                        $firstName = ($actress.altname -split ' ')[1]
                    }
                    $japaneseName = $actress.name
                }
            } else {
                if ($Settings.'sort.metadata.nfo.firstnameorder') {
                    $firstName = ($actress.name -split ' ')[0]
                    $lastName = ($actress.name -split ' ')[1]
                    $japaneseName = $actress.altname
                } else {
                    $nameParts = ($actress.name -split ' ').Count
                    if ($nameParts -eq 1) {
                        $lastName = $null
                        $firstName = $actress.name
                    } else {
                        $lastName = ($actress.name -split ' ')[0]
                        $firstName = ($actress.name -split ' ')[1]
                    }
                    $japaneseName = $actress.altname
                }
            }

            [PSCustomObject]@{
                LastName     = $lastName
                FirstName    = $firstName
                JapaneseName = $japaneseName
                ThumbUrl     = $actress.thumb
            }
        }

        # We want to convert the nfo back to its aggregated data format
        # So that we can perform modifications to it and recreate the nfo
        $aggregatedDataObject = [PSCustomObject]@{
            Id             = $nfo.movie.id
            ContentId      = $nfo.movie.id
            DisplayName    = $nfo.movie.title
            Title          = $null
            AlternateTitle = $nfo.movie.originaltitle
            Description    = $nfo.movie.plot
            Rating         = $ratingObject
            ReleaseDate    = $releaseDate
            Runtime        = $nfo.movie.runtime
            Director       = $nfo.movie.director
            Maker          = $nfo.movie.studio
            Label          = $null
            Series         = $nfo.movie.set
            Tag            = $nfo.movie.tag
            Tagline        = $nfo.movie.tagline
            Credits        = $nfo.movie.credits
            Actress        = $actressObject
            Genre          = $nfo.movie.genre
            CoverUrl       = $null
            ScreenshotUrl  = $null
            TrailerUrl     = $nfo.movie.trailer
            MediaInfo      = $null
        }

        if ($thumbCsv) {
            if ($Settings.'sort.metadata.thumbcsv.convertalias') {
                $aliases = @()
                $aliasObject = @()
                $csvAlias = $thumbCsv.Alias
                foreach ($alias in ($csvAlias | Where-Object { $_ -ne '' })) {
                    $index = [Array]::IndexOf($csvAlias, $alias)
                    $aliases = $alias -split '\|'
                    foreach ($alias in $aliases) {
                        # Match if the name contains Japanese characters
                        if ($alias -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                            $aliasObject += [PSCustomObject]@{
                                LastName     = ''
                                FirstName    = ''
                                JapaneseName = $alias
                                Index        = $index
                            }
                        } else {
                            $nameParts = ($alias -split ' ').Count
                            if ($nameParts -eq 1) {
                                $lastName = ''
                                $firstName = $alias
                            } else {
                                $lastName = ($alias -split ' ')[0]
                                $firstName = ($alias -split ' ')[1]
                            }

                            $aliasObject += [PSCustomObject]@{
                                LastName     = $lastName
                                FirstName    = $firstName
                                JapaneseName = ''
                                Index        = $index
                            }
                        }
                    }
                }

                # Try three methods for matching aliases
                # FirstName | FirstName, LastName | JapaneseName
                for ($x = 0; $x -lt $aggregatedDataObject.Actress.Count; $x++) {
                    if ((($aggregatedDataObject.Actress[$x].LastName -eq '' -or $null -eq $aggregatedDataObject.Actress[$x].LastName) -and ($aggregatedDataObject.Actress[$x].FirstName -ne '' -and $null -ne $aggregatedDataObject.Actress[$x].FirstName)) -and ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName'))) {
                        $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                        if ($matched.Count -eq 1) {
                            $aggregatedDataObject.Actress[$x].FirstName = $thumbCsv[$matched.Index].FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $thumbCsv[$matched.Index].LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $thumbCsv[$matched.Index].JapaneseName
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $thumbCsv[$matched.Index].ThumbUrl
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName match"
                        } elseif ($matched.Count -gt 1) {
                            $aggregatedDataObject.Actress[$x].FirstName = $thumbCsv[$matched[0].Index].FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $thumbCsv[$matched[0].Index].LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $thumbCsv[$matched[0].Index].JapaneseName
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $thumbCsv[$matched[0].Index].ThumbUrl
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName match"
                        }
                    } elseif ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                        $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                        if ($matched.Count -eq 1) {
                            $aggregatedDataObject.Actress[$x].FirstName = $thumbCsv[$matched.Index].FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $thumbCsv[$matched.Index].LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $thumbCsv[$matched.Index].JapaneseName
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $thumbCsv[$matched.Index].ThumbUrl
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName LastName match"
                        } elseif ($matched.Count -gt 1) {
                            $aggregatedDataObject.Actress[$x].FirstName = $thumbCsv[$matched[0].Index].FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $thumbCsv[$matched[0].Index].LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $thumbCsv[$matched[0].Index].JapaneseName
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $thumbCsv[$matched[0].Index].ThumbUrl
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName LastName match"
                        }
                    } elseif (($aggregatedDataObject.Actress[$x].JapaneseName -ne '') -and ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName'))) {
                        $aliasString = "$($matched.JapaneseName)".Trim()
                        if ($matched.Count -eq 1) {
                            $aggregatedDataObject.Actress[$x].FirstName = $thumbCsv[$matched.Index].FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $thumbCsv[$matched.Index].LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $thumbCsv[$matched.Index].JapaneseName
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $thumbCsv[$matched.Index].ThumbUrl
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using JapaneseName match"
                        } elseif ($matched.Count -gt 1) {
                            $actressString = "$($thumbCsv[$matched.Index].LastName) $($thumbCsv[$matched.Index].FirstName) - $($thumbCsv[$matched[0].Index].JapaneseName)".Trim()
                            $aggregatedDataObject.Actress[$x].FirstName = $thumbCsv[$matched[0].Index].FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $thumbCsv[$matched[0].Index].LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $thumbCsv[$matched[0].Index].JapaneseName
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $thumbCsv[$matched[0].Index].ThumbUrl
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using JapaneseName match"
                        }
                    }
                }
            }

            for ($x = 0; $x -lt $aggregatedDataObject.Actress.Count; $x++) {
                $matched = @()
                $matchedActress = @()
                if (($aggregatedDataObject.Actress[$x].JapaneseName -ne '') -and ($matched = Compare-Object -ReferenceObject $thumbCsv -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName'))) {
                    $originalActressString = ($aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress) -replace 'null', '""'
                    if ($matched.Count -eq 1) {
                        $matchedActress = $matched
                        $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                        $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                        $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                        if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                        }
                        $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                        if ($originalActressString -ne $actressString) {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] replaced as [$actressString]"
                        }
                    } elseif ($matched.Count -gt 1) {
                        $matchedActress = $matched | Where-Object { $_.FirstName -like $aggregatedDataObject.Actress[$x].FirstName -and $_.LastName -like $aggregatedDataObject.Actress[$x].LastName }
                        if ($matchedActress.Count -eq 1) {
                            $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                            if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            }
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            if ($originalActressString -ne $actressString) {
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] replaced as [$actressString]"
                            }
                        }
                    }
                } elseif (($aggregatedDataObject.Actress[$x].LastName -eq '' -and $aggregatedDataObject.Actress[$x].FirstName -ne '') -and ($matched = Compare-Object -ReferenceObject ($thumbCsv | Where-Object { $_.LastName -eq '' }) -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName'))) {
                    $originalActressString = ($aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress) -replace 'null', '""'
                    if ($matched.Count -eq 1) {
                        $matchedActress = $matched
                        $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                        $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                        $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                        if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                        }
                        $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                        if ($originalActressString -ne $actressString) {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] replaced as [$actressString]"
                        }
                    }
                } elseif ($matched = Compare-Object -ReferenceObject $thumbCsv -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                    $originalActressString = ($aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress) -replace 'null', '""'
                    if ($matched.Count -eq 1) {
                        $matchedActress = $matched
                        $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                        $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                        $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                        if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                        }
                        $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress

                        if ($originalActressString -ne $actressString) {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] replaced as [$actressString]"
                        }
                    }
                }
            }
        }

        if ($genreCsv) {
            $newGenres = @()
            $originalGenres = $aggregatedDataObject.Genre
            foreach ($genre in $originalGenres) {
                if ($genre -in $genreCsv.Original) {
                    $genreIndexNum = $genreCsv.Original.IndexOf($genre)
                    if ($genreCsv.Replacement[$genreIndexNum] -ne '' -and $null -ne $genreCsv.Replacement[$genreIndexNum]) {
                        $newGenres += $genreCsv.Replacement[$genreIndexNum]
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Genre - $($genreCsv.Original[$genreIndexNum])] replaced as [$($genreCsv.Replacement[$genreIndexNum])]"
                    }
                } else {
                    $newGenres += $genre
                }
            }

            $aggregatedDataObject.Genre = $newGenres
        }

        if ($ignoreGenre) {
            if ($aggregatedDataObject.Genre) {
                $originalGenres = $aggregatedDataObject.Genre
                $ignoredGenres = $IgnoreGenre -join '|'
                $aggregatedDataObject.Genre = $aggregatedDataObject.Genre | Where-Object { $_ -notmatch $ignoredGenres -and $_ -ne '' }
                $originalGenres | ForEach-Object {
                    if ($aggregatedDataObject.Genre -notcontains $_) {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Genre - $_] ignored"
                    }
                }
            }
        }

        if ($tagCsv) {
            $newTags = @()
            $originalTags = $aggregatedDataObject.Tag
            foreach ($tag in $originalTags) {
                if ($tag -in $tagCsv.Original) {
                    $tagIndexNum = $tagCsv.Original.IndexOf($tag)
                    if ($tagCsv.Replacement[$tagIndexNum] -ne '' -and $null -ne $tagCsv.Replacement[$tagIndexNum]) {
                        $newTags += $tagCsv.Replacement[$tagIndexNum]
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Tag - $($tagCsv.Original[$tagIndexNum])] replaced as [$($tagCsv.Replacement[$tagIndexNum])]"
                    }
                } else {
                    $newTags += $tag
                }
            }

            $aggregatedDataObject.Tag = $newTags
        }

        <# if ($Translate) {
            # Code copied from Get-JVAggregatedData
            if ($translateLanguage) {
                $translatedObject = [PSCustomObject]@{
                    Title          = $null
                    AlternateTitle = $null
                    Description    = $null
                    Director       = $null
                    Series         = $null
                    Genre          = $null
                    Maker          = $null
                    Label          = $null
                }

                $translatedObject.PSObject.Properties | ForEach-Object {
                    if ($_.Name -in $TranslateFields) {
                        if ($_.Name -eq 'Genre') {
                            $_.Value = Get-TranslatedString -String ($aggregatedDataObject."$($_.Name)" -join '|') -Language $TranslateLanguage -Module $TranslateModule
                            $genres = @()
                            $rawGenres = $_.Value -split '\|'
                            foreach ($genre in $rawGenres) {
                                $genres += ($genre).Trim()
                            }
                        } else {
                            $_.Value = Get-TranslatedString -String $aggregatedDataObject."$($_.Name)" -Language $TranslateLanguage -Module $TranslateModule
                        }
                        if ($null -ne $_.Value -and ($_.Value).Trim() -ne '') {
                            if ($_.Name -eq 'Genre') {
                                $aggregatedDataObject."$($_.Name)" = $genres
                            } elseif ($_.Name -eq 'Description') {
                                if ($KeepOriginalDescription) {
                                    $description = ($_.Value).Trim() + "`n`n" + $aggregatedDataObject."$($_.Name)"
                                    $aggregatedDataObject."$($_.Name)" = $description
                                } else {
                                    $aggregatedDataObject."$($_.Name)" = ($_.Value).Trim()
                                }
                            } else {
                                $aggregatedDataObject."$($_.Name)" = ($_.Value).Trim()
                            }
                        }
                    }
                }
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] Translation language is missing"
            }
        } #>

        try {
            $updatedNfo = $aggregatedDataObject | Get-JVNfo -ActressLanguageJa:$Settings.'sort.metadata.nfo.actresslanguageja' -NameOrder:$Settings.'sort.metadata.nfo.firstnameorder' -AltNameRole:$Settings.'sort.metadata.nfo.altnamerole' -ErrorAction Stop

            if ($uncensorCsv) {
                foreach ($string in $uncensorCsv.GetEnumerator()) {
                    if ($updatedNfo | Select-String -Pattern $string.Original -SimpleMatch) {
                        $updatedNfo = $updatedNfo -replace [regex]::Escape($string.Original), $string.Replacement
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Uncensor - $($string.Original)] replaced as [$($string.Replacement)]"
                    }
                }
            }

            # Reassign variable $updatedNfo using content read from a file
            # So we can properly compare it to the original using Compare-Object
            $tempFile = New-TemporaryFile
            Set-Content -Path $tempFile -Value $updatedNfo
            $updatedNfo = Get-Content -LiteralPath $tempFile
            Remove-Item -Path $tempFile

            # We only want to rewrite files that have been modified from the original
            if (Compare-Object -ReferenceObject (Get-Content -LiteralPath $Path) -DifferenceObject $updatedNfo) {
                if (!($Preview)) {
                    try {
                        $updatedNfo | Out-File -FilePath $Path
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "Error updating nfo [$Path]: $PSItem"
                    }
                    Write-Host "Updated [$Path]"
                } else {
                    Write-Host "Preview: Updated [$Path]"
                }
            }
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "Error recreating nfo [$Path]: $PSItem" -Action Continue
        }
        $index++
    }

    end {
        Write-Progress -Id 1 -Activity "Checking nfo: $Path" -Completed
    }
}
