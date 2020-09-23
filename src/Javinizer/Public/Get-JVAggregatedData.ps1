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
        [Alias('sort.metadata.priority.rating')]
        [Array]$RatingPriority,

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
        [Alias('sort.metadata.nfo.displayname')]
        [String]$DisplayNameFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.firstnameorder')]
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
        [Alias('sort.metadata.nfo.translatedescription')]
        [Boolean]$Translate,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.translatedescription.language')]
        [String]$TranslateLanguage,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.format.delimiter')]
        [String]$DelimiterFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.actresslanguageja')]
        [Boolean]$ActressLanguageJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.thumbcsv.autoadd')]
        [Boolean]$ThumbCsvAutoAdd,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.unknownactress')]
        [Boolean]$UnknownActress
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
            $RatingPriority = $Settings.'sort.metadata.priority.rating'
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
            $Translate = $Settings.'sort.metadata.nfo.translatedescription'
            $TranslateLanguage = $Settings.'sort.metadata.nfo.translatedescription.language'
            $DelimiterFormat = $Settings.'sort.format.delimiter'
            $ActressLanguageJa = $Settings.'sort.metadata.nfo.actresslanguageja'
            $ThumbCsvAutoAdd = $Settings.'sort.metadata.thumbcsv.autoadd'
            $FirstNameOrder = $Settings.'sort.metadata.nfo.firstnameorder'
            $AddUnknownActress = $Settings.'sort.metadata.nfo.unknownactress'
            if ($Settings.'location.genrecsv' -ne '') {
                $GenreCsvPath = $Settings.'location.genrecsv'
            }
            if ($Settings.'location.thumbcsv' -ne '') {
                $ThumbCsvPath = $Settings.'location.thumbcsv'
            }
        }

        $aggregatedDataObject = [PSCustomObject]@{
            Id             = $null
            DisplayName    = $null
            Title          = $null
            AlternateTitle = $null
            Description    = $null
            Rating         = $null
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
            'Rating',
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
        $aggregatedDataObject.DisplayName = Convert-JVString -Data $aggregatedDataObject -FormatString $DisplayNameFormat -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder

        if ($ThumbCsv) {
            if (Test-Path -LiteralPath $ThumbCsvPath) {
                try {
                    $actressCsv = Import-Csv -LiteralPath $thumbCsvPath
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when importing thumbnail csv [$genreCsvPath]: $PSItem"
                }

                if ($ThumbCsvAutoAdd) {
                    if ($Data.Source -contains 'r18') {
                        $r18Data = $Data | Where-Object { $_.Source -eq 'r18' }
                        foreach ($actress in $r18Data.Actress) {
                            if ($actress.JapaneseName -notin $actressCsv.JapaneseName) {
                                try {
                                    $fullName = "$($actress.LastName) $($actress.FirstName)".Trim()
                                    $actressObject = [PSCustomObject]@{
                                        FullName     = $fullName
                                        LastName     = $actress.LastName
                                        FirstName    = $actress.FirstName
                                        JapaneseName = $actress.JapaneseName
                                        ThumbUrl     = $actress.ThumbUrl
                                        Alias        = $null
                                    }
                                    # We only want to write the actress if the thumburl isn't null
                                    if ($actressObject.ThumbUrl -ne '' -and $null -ne $actressObject.ThumbUrl) {
                                        $actressObject | Export-Csv -LiteralPath $ThumbCsvPath -Append
                                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Wrote [$fullName - $($actress.JapaneseName)] to thumb csv"
                                    }
                                } catch {
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occured when updating Javinizer thumb csv at path [$ThumbCsvPath]: $PSItem"
                                }
                            }
                        }
                    } elseif ($Data.Source -contains 'r18zh') {
                        $r18Data = $Data | Where-Object { $_.Source -eq 'r18zh' }
                        foreach ($actress in $r18Data.Actress) {
                            if ($actress.JapaneseName -notin $actressCsv.JapaneseName) {
                                try {
                                    $fullName = "$($actress.LastName) $($actress.FirstName)".Trim()
                                    $actressObject = [PSCustomObject]@{
                                        FullName     = $fullName
                                        LastName     = $actress.LastName
                                        FirstName    = $actress.FirstName
                                        JapaneseName = $actress.JapaneseName
                                        ThumbUrl     = $actress.ThumbUrl
                                        Alias        = $null
                                    }
                                    $actressObject | Export-Csv -LiteralPath $ThumbCsvPath -Append
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Wrote [$fullName - $($actress.JapaneseName)] to thumb csv"
                                } catch {
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occured when updating Javinizer thumb csv at path [$ThumbCsvPath]: $PSItem"
                                }
                            }
                        }
                    }
                    # Reimport the csv to catch any updates
                    try {
                        $actressCsv = Import-Csv -LiteralPath $thumbCsvPath
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when importing thumbnail csv [$genreCsvPath]: $PSItem"
                    }

                }

                if ($ThumbCsvAlias) {
                    $aliases = @()
                    $aliasObject = @()
                    $csvAlias = $actressCsv.Alias
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
                        if (($aggregatedDataObject.Actress[$x].LastName -eq '' -and $aggregatedDataObject.Actress[$x].FirstName -ne '') -and ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName'))) {
                            $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                            if ($matched.Count -eq 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched.Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched.Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched.Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched.Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName match"
                            } elseif ($matched.Count -gt 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName match"
                            }
                        } elseif ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                            $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                            if ($matched.Count -eq 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName LastName match"
                            } elseif ($matched.Count -gt 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName LastName match"
                            }
                        } elseif (($aggregatedDataObject.Actress[$x].JapaneseName -ne '') -and ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName'))) {
                            $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                            if ($matched.Count -eq 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched.Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched.Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched.Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched.Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using JapaneseName match"
                            } elseif ($matched.Count -gt 1) {
                                $actressString = "$($actressCsv[$matched.Index].LastName) $($actressCsv[$matched.Index].FirstName) - $($actressCsv[$matched[0].Index].JapaneseName)".Trim()
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using JapaneseName match"
                            }
                        }
                    }
                }

                for ($x = 0; $x -lt $aggregatedDataObject.Actress.Count; $x++) {
                    $matched = @()
                    $matchedActress = @()
                    if (($aggregatedDataObject.Actress[$x].JapaneseName -ne '') -and ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName'))) {
                        $originalActressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                        if ($matched.Count -eq 1) {
                            $matchedActress = $matched
                            $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                            if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            }
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] matched to [$actressString]"
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
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] matched to [$actressString]"
                            }
                        }
                    } elseif (($aggregatedDataObject.Actress[$x].LastName -eq '' -and $aggregatedDataObject.Actress[$x].FirstName -ne '') -and ($matched = Compare-Object -ReferenceObject ($actressCsv | Where-Object { $_.LastName -eq '' }) -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName'))) {
                        $originalActressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                        if ($matched.Count -eq 1) {
                            $matchedActress = $matched
                            $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                            if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            }
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] matched to [$actressString]"
                        }
                    } elseif ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                        $originalActressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                        if ($matched.Count -eq 1) {
                            $matchedActress = $matched
                            $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                            if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            }
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] matched to [$actressString]"
                        }
                    }
                }
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Thumbnail csv file is missing or cannot be found at path [$thumbCsvPath]"
            }
        }

        if ($AddUnknownActress) {
            if ($null -eq $aggregatedDataObject.Actress) {
                $aggregatedDataObject.Actress += [PSCustomObject]@{
                    LastName     = $null
                    FirstName    = 'Unknown'
                    JapaneseName = 'Unknown'
                    ThumbUrl     = $null
                }
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
            if ($aggregatedDataObject.Genre) {
                $originalGenres = $aggregatedDataObject.Genre
                $ignoredGenres = $IgnoreGenre -join '|'
                $aggregatedDataObject.Genre = $aggregatedDataObject.Genre | Where-Object { $_ -notmatch $ignoredGenres -and $_ -ne '' }
                $originalGenres | ForEach-Object {
                    if ($aggregatedDataObject.Genre -notcontains $_) {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Genre - $_] ignored"
                    }
                }
            }
        }

        if ($Translate) {
            if ($TranslateLanguage) {
                $originalDescription = $aggregatedDataObject.Description
                [String]$translatedDescription = Get-TranslatedString -String $originalDescription -Language $TranslateLanguage
                if ($null -eq $translatedDescription -or $translatedDescription -eq '') {
                    $aggregatedDataObject.Description = $originalDescription
                } else {
                    $aggregatedDataObject.Description = $translatedDescription.Trim()
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Description - $originalDescription] translated to [$($aggregatedDataObject.Description)]"
                }

            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Translation language is missing"
            }
        }

        $dataObject = [PSCustomObject]@{
            Data = $aggregatedDataObject
        }

        Write-Output $dataObject
    }
}
