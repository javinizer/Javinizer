#Requires -Modules @{ ModuleName="Logging"; RequiredVersion="4.4.0" }
#Requires -PSEdition Core

function Get-JVAggregatedData {
    [CmdletBinding(DefaultParameterSetName = 'Setting')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [PSObject]$Data,

        [Parameter(Mandatory = $true, ParameterSetName = 'Setting')]
        [PSObject]$Settings,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.actress')]
        [Array]$ActressPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.alternatetitle')]
        [Array]$AlternateTitlePriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.coverurl')]
        [Array]$CoverUrlPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.description')]
        [Array]$DescriptionPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.director')]
        [Array]$DirectorPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.genre')]
        [Array]$GenrePriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.id')]
        [Array]$IdPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.label')]
        [Array]$LabelPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.maker')]
        [Array]$MakerPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.releasedate')]
        [Array]$ReleaseDatePriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.runtime')]
        [Array]$RuntimePriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.series')]
        [Array]$SeriesPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.screenshoturl')]
        [Array]$ScreenshotUrlPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.title')]
        [Array]$TitlePriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.priority.trailerurl')]
        [Array]$TrailerUrlPriority,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.displayname')]
        [String]$DisplayNameFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.firstnameorder')]
        [Boolean]$FirstNameOrder,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.thumbcsv')]
        [Boolean]$ThumbCsv,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('location.thumbcsv')]
        [System.IO.FileInfo]$ThumbCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'),

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.thumbcsv.convertalias')]
        [Boolean]$ThumbCsvAlias,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.genrecsv')]
        [Boolean]$ReplaceGenre,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('location.genrecsv')]
        [System.IO.FileInfo]$GenreCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvGenres.csv'),

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.genre.ignore')]
        [Array]$IgnoreGenre,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.requiredfield')]
        [Array]$RequiredField,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.translate')]
        [Boolean]$Translate,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.translate.language')]
        [String]$TranslateLanguage
    )

    process {
        if ($Settings) {
            $ActressPriority = $Settings.'sort.metadata.priority.actress'
            $AlternateTitlePriority = $Settings.'sort.metadata.priority.alternatetitle'
            $CoverUrlPriority = $Settings.'sort.metadata.priority.coverurl'
            $DescriptionPriority = $Settings.'sort.metadata.priority.description'
            $DirectorPriority = $Settings.'sort.metadata.priority.director'
            $GenrePriority = $Settings.'sort.metadata.priority.genre'
            $IdPriority = $Settings.'sort.metadata.priority.id'
            $LabelPriority = $Settings.'sort.metadata.priority.label'
            $MakerPriority = $Settings.'sort.metadata.priority.maker'
            $ReleaseDatePriority = $Settings.'sort.metadata.priority.releasedate'
            $RuntimePriority = $Settings.'sort.metadata.priority.runtime'
            $SeriesPriority = $Settings.'sort.metadata.priority.series'
            $ScreenshotUrlPriority = $Settings.'sort.metadata.priority.screenshoturl'
            $TitlePriority = $Settings.'sort.metadata.priority.title'
            $TrailerUrlPriority = $Settings.'sort.metadata.priority.trailerurl'
            $DisplayNameFormat = $Settings.'sort.metadata.nfo.displayname'
            $ThumbCsv = $Settings.'sort.metadata.thumbcsv'
            $ThumbCsvAlias = $Settings.'sort.metadata.thumbcsv.convertalias'
            $ReplaceGenre = $Settings.'sort.metadata.genrecsv'
            $IgnoreGenre = $Settings.'sort.metadata.genre.ignore'
            $Translate = $Settings.'sort.metadata.nfo.translate'
            $TranslateLanguage = $Settings.'sort.metadata.nfo.translate.language'
            if ($Settings.'location.genrecsv' -ne '') {
                $GenreCsvPath = $Settings.'location.genrecsv'
            }
            if ($Settings.'location.thumbcsv' -ne '') {
                $ThumbCsvPath = $Settings.'location.genrecsv'
            }
        }

        $aggregatedDataObject = [PSCustomObject]@{
            Id             = $null
            DisplayName    = $null
            Title          = $null
            AlternateTitle = $null
            Description    = $null
            ReleaseDate    = $null
            Runtime        = $null
            Director       = $null
            Maker          = $null
            Label          = $null
            Series         = $null
            Actress        = $null
            Genre          = $null
            CoverUrl       = $null
            ScreenshotUrl  = $null
            TrailerUrl     = $null
        }

        $metadataFields = @(
            'Actress',
            'AlternateTitle',
            'CoverUrl',
            'Description',
            'Director',
            'Genre',
            'Id',
            'Label',
            'Maker',
            'ReleaseDate',
            'Runtime',
            'Series',
            'ScreenshotUrl',
            'Title',
            'TrailerUrl'
        )

        foreach ($field in $metadataFields) {
            $metadataPriority = (Get-Variable -Name "$($field)Priority" -ValueOnly)
            foreach ($priority in $metadataPriority) {
                $sourceData = $Data | Where-Object { $_.Source -eq $priority }

                if ($null -eq $aggregatedDataObject.$field) {
                    if ($field -eq 'AlternateTitle') {
                        $aggregatedDataObject.$field = $sourceData.Title
                    } else {
                        $aggregatedDataObject.$field = $sourceData.$field
                    }
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [$field - $priority] Set to [$($sourceData.$field | ConvertTo-Json -Compress)]"
                }
            }
        }

        # The displayname value is updated after the previous fields have already been scraped
        $aggregatedDataObject.DisplayName = Convert-JVString -Data $aggregatedDataObject -FormatString $DisplayNameFormat

        if ($ThumbCsv) {
            if (Test-Path -LiteralPath $ThumbCsvPath) {
                try {
                    $actressCsv = Import-Csv -LiteralPath $thumbCsvPath
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when importing thumbnail csv [$genreCsvPath]: $PSItem"
                }

                for ($x = 0; $x -lt $aggregatedDataObject.Actress.Count; $x++) {
                    if ($ThumbCsvAlias) {
                        $aliases = @()
                        $aliasObject = @()
                        $csvAlias = $actressCsv.Alias
                        foreach ($alias in ($csvAlias | Where-Object { $_ -ne '' })) {
                            $index = [Array]::IndexOf($csvAlias, $alias)
                            $aliases = $alias -split '\|'
                            foreach ($alias in $aliases) {
                                $aliasObject += [PSCustomObject]@{
                                    LastName  = ($alias -split ' ')[0]
                                    FirstName = ($alias -split ' ')[1]
                                    Index     = $index
                                }
                            }
                        }

                        if ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                            $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                            $actressString = "$($actressCsv[$matched.Index].LastName) $($actressCsv[$matched.Index].FirstName)".Trim()

                            if ($matched.Count -eq 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched.Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched.Index].LastName
                            } elseif ($matched.Count -gt 1) {
                                # Automatically select the first match if multiple actresses with identical names are found
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched[0].Index].LastName
                            }

                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] replaced by [$actressString]"
                        }
                    }

                    # Check if FirstName/LastName matches the thumb csv
                    if ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                        if ($matched.Count -eq 1) {
                            $matchedActress = $matched
                        } elseif ($matched.Count -gt 1) {
                            # Automatically select the first match if multiple actresses with identical names are found
                            $matchedActress = $matched[0]
                        }

                        if ($null -ne $matchedActress) {
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                            $actressString = "$($aggregatedDataObject.Actress[$x].LastName) $($aggregatedDataObject.Actress[$x].FirstName)".Trim()
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [ThumbUrl - $($matchedActress.ThumbUrl)] added to actress [$actressString]"
                        }
                        # Check if JapaneseName matches the thumb csv
                    } elseif ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName')) {
                        if ($matched.Count -eq 1) {
                            $matchedActress = $matched
                        } elseif ($matched.Count -gt 1) {
                            # Automatically select the first match if multiple actresses with identical names are found
                            $matchedActress = $matched[0]
                        }

                        if ($null -ne $matchedActress) {
                            $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            $actressString = "$($aggregatedDataObject.Actress[$x].JapaneseName)".Trim()
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [ThumbUrl - $($matchedActress.ThumbUrl)] added to actress [$actressString]"
                        }
                        # Check if FirstName matches the thumb csv for single-word names
                    } elseif ($null -eq $aggregatedDataObject.Actress[$x].LastName -and $null -ne $aggregatedDataObject.Actress[$x].FirstName) {
                        $matched = Compare-Object -ReferenceObject ($actressCsv | Where-Object { $_.LastName -eq '' }) -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName')

                        if ($matched.Count -eq 1) {
                            $matchedActress = $matched
                        } elseif ($matched.Count -gt 1) {
                            # Automatically select the first match if multiple actresses with identical names are found
                            $matchedActress = $matched[0]
                        }

                        if ($null -ne $matchedActress) {
                            $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                            $actressString = "$($aggregatedDataObject.Actress[$x].FirstName)".Trim()
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [ThumbUrl - $($matchedActress.ThumbUrl)] added to actress [$actressString]"
                        }
                    }
                }
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Thumbnail csv file is missing or cannot be found at path [$thumbCsvPath]"
            }
        }

        if ($ReplaceGenre) {
            if (Test-Path -LiteralPath $GenreCsvPath) {
                try {
                    $replaceGenres = Import-Csv -LiteralPath $GenreCsvPath
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when importing genre csv [$GenreCsvPath]: $PSItem"
                }

                $newGenres = $aggregatedDataObject.Genre
                foreach ($genrePair in $replaceGenres) {
                    if ($($genrePair.Original -in $newGenres)) {
                        $newGenres = $newGenres -replace "$($genrePair.Original)", "$($genrePair.Replacement)"
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Genre - $($genrePair.Original)] replaced as [$($genrePair.Replacement)]"
                    }
                }

                $aggregatedDataObject.Genre = $newGenres
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Genre csv file is missing or cannot be found at path [$grenreCsvPath]"
            }

        }

        if ($IgnoreGenre) {
            $newGenres = $aggregatedDataObject.Genre
            foreach ($genre in $IgnoreGenre) {
                if ($genre -in $newGenres) {
                    $newGenres = $newGenres -replace "$genre", $null
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Genre - $genre] ignored"
                }
            }
            $aggregatedDataObject.Genre = $newGenres | Where-Object { $_ -ne '' }
        }

        if ($Translate) {
            if ($TranslateLanguage) {
                $descriptionTemp = $aggregatedDataObject.Description
                $translatedDescription = Get-TranslatedString -String $descriptionTemp -Language $TranslateLanguage

                if ($null -ne $translatedDescription -or $translatedDescription -ne '') {
                    $aggregatedDataObject.Description = $translatedDescription
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Description - $descriptionTemp] translated to [$($aggregatedDataObject.Description)]"
                }
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($Data[0].Id)] Translation language is missing"
            }
        }

        $dataObject = [PSCustomObject]@{
            Data = $aggregatedDataObject
        }

        Write-Output $dataObject
    }
}
