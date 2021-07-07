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
        [Alias('sort.metadata.priority.contentid')]
        [Array]$ContentIdPriority,

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
        [Alias('sort.metadata.genrecsv.autoadd')]
        [Boolean]$GenreCsvAutoAdd,

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
        [Alias('sort.metadata.nfo.translate.module')]
        [String]$TranslateModule,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.translate.field')]
        [Array]$TranslateFields,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.translate.language')]
        [String]$TranslateLanguage,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.translate.keeporiginaldescription')]
        [Boolean]$KeepOriginalDescription,

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
        [Boolean]$UnknownActress,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.format.tag')]
        [Array]$Tag,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.format.tagline')]
        [String]$Tagline,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.format.credits')]
        [Array]$Credits,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('scraper.option.idpreference')]
        [String]$IdPreference,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('scraper.option.addmaleactors')]
        [Boolean]$AVDanyu,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.mediainfo')]
        [PSObject]$MediaInfo,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.format.groupactress')]
        [Boolean]$GroupActress,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.actressastag')]
        [Boolean]$ActressAsTag,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.preferactressalias')]
        [Boolean]$PreferActressAlias,

        [Alias('sort.metadata.tagcsv')]
        [Boolean]$ReplaceTag,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.tagcsv.autoadd')]
        [Boolean]$TagCsvAutoAdd,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('location.tagcsv')]
        [System.IO.FileInfo]$TagCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvTags.csv'),

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [String]$FileName
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
            $ContentIdPriority = $Settings.'sort.metadata.priority.contentid'
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
            $Translate = $Settings.'sort.metadata.nfo.translate'
            $TranslateFields = $Settings.'sort.metadata.nfo.translate.field'
            $TranslateLanguage = $Settings.'sort.metadata.nfo.translate.language'
            $KeepOriginalDescription = $Settings.'sort.metadata.nfo.translate.keeporiginaldescription'
            $DelimiterFormat = $Settings.'sort.format.delimiter'
            $ActressLanguageJa = $Settings.'sort.metadata.nfo.actresslanguageja'
            $ThumbCsvAutoAdd = $Settings.'sort.metadata.thumbcsv.autoadd'
            $GenreCsvAutoAdd = $Settings.'sort.metadata.genrecsv.autoadd'
            $FirstNameOrder = $Settings.'sort.metadata.nfo.firstnameorder'
            $UnknownActress = $Settings.'sort.metadata.nfo.unknownactress'
            $ActressAsTag = $Settings.'sort.metadata.nfo.actressastag'
            $Tag = $Settings.'sort.metadata.nfo.format.tag'
            $Tagline = $Settings.'sort.metadata.nfo.format.tagline'
            $Credits = $Settings.'sort.metadata.nfo.format.credits'
            $IdPreference = $Settings.'scraper.option.idpreference'
            $GroupActress = $Settings.'sort.format.groupactress'
            $TagCsvAutoAdd = $Settings.'sort.metadata.tagcsv.autoadd'
            $ReplaceTag = $Settings.'sort.metadata.tagcsv'
            $TranslateModule = $Settings.'sort.metadata.nfo.translate.module'
            $AvDanyu = $Settings.'scraper.option.addmaleactors'
            $PreferActressAlias = $Settings.'sort.metadata.nfo.preferactressalias'
            if ($Settings.'location.genrecsv' -ne '') {
                $GenreCsvPath = $Settings.'location.genrecsv'
            }
            if ($Settings.'location.thumbcsv' -ne '') {
                $ThumbCsvPath = $Settings.'location.thumbcsv'
            }
            if ($Settings.'location.tagcsv' -ne '') {
                $TagCsvPath = $Settings.'location.tagcsv'
            }
        }

        $aggregatedDataObject = [PSCustomObject]@{
            Id               = $null
            ContentId        = $null
            DisplayName      = $null
            Title            = $null
            AlternateTitle   = $null
            Description      = $null
            Rating           = $null
            ReleaseDate      = $null
            Runtime          = $null
            Director         = $null
            Maker            = $null
            Label            = $null
            Series           = $null
            Tag              = $null
            Tagline          = $null
            Credits          = $null
            Actress          = $null
            Genre            = $null
            CoverUrl         = $null
            ScreenshotUrl    = $null
            TrailerUrl       = $null
            OriginalFileName = $FileName
            MediaInfo        = $MediaInfo
        }

        $selectedDataObject = [PSCustomObject]@{
            Id             = $null
            ContentId      = $null
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
            Tag            = $null
            Tagline        = $null
            Credits        = $null
            Actress        = $null
            Genre          = $null
            CoverUrl       = $null
            ScreenshotUrl  = $null
            TrailerUrl     = $null
            MediaInfo      = $MediaInfo
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
            'TrailerUrl',
            'ContentId'
        )

        foreach ($field in $metadataFields) {
            $metadataPriority = (Get-Variable -Name "$($field)Priority" -ValueOnly)
            foreach ($priority in $metadataPriority) {
                $sourceData = $Data | Where-Object { $_.Source -eq $priority }

                if ($null -eq $aggregatedDataObject.$field) {
                    $selectedDataObject.$field = $priority
                    if ($field -eq 'AlternateTitle') {
                        $aggregatedDataObject.$field = $sourceData.Title
                    } elseif ($field -eq 'Id') {
                        if ($IdPreference -eq 'contentid') {
                            $aggregatedDataObject.$field = $sourceData.ContentId
                        } else {
                            $aggregatedDataObject.$field = $sourceData.Id
                        }
                    } elseif ($field -eq 'Actress') {
                        if ($null -eq $sourceData.Actress) {
                            $aggregatedDataObject.$field = $null
                        } else {
                            $aggregatedDataObject.$field = @($sourceData.Actress)
                        }
                    } else {
                        $aggregatedDataObject.$field = $sourceData.$field
                    }
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [$field - $priority] Set to [$($sourceData.$field | ConvertTo-Json -Depth 32 -Compress)]"
                }
            }
        }

        if ($AvDanyu) {
            $maleActors = (Get-AVDanyuData -ContentId $aggregatedDataObject.ContentId).Actors

            if ($maleActors) {
                $aggregatedDataObject.Actress += $maleActors
            }
        }

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
                            if (($actress.JapaneseName -ne '' -and $null -ne $actress.JapaneseName) -and ($actress.JapaneseName -notin $actressCsv.JapaneseName)) {
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
                        if ((($aggregatedDataObject.Actress[$x].LastName -eq '' -or $null -eq $aggregatedDataObject.Actress[$x].LastName) -and ($aggregatedDataObject.Actress[$x].FirstName -ne '' -and $null -ne $aggregatedDataObject.Actress[$x].FirstName)) -and ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName'))) {
                            $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                            if ($matched.Count -eq 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched.Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched.Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched.Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched.Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName match"
                            } elseif ($matched.Count -gt 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName match"
                            }
                        } elseif ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                            $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                            if ($matched.Count -eq 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched.Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched.Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched.Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched.Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName LastName match"
                            } elseif ($matched.Count -gt 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName LastName match"
                            }
                        } elseif (($aggregatedDataObject.Actress[$x].JapaneseName -ne '') -and ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName'))) {
                            $aliasString = "$($matched.JapaneseName)".Trim()
                            if ($matched.Count -eq 1) {
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched.Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched.Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched.Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched.Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using JapaneseName match"
                            } elseif ($matched.Count -gt 1) {
                                $actressString = "$($actressCsv[$matched.Index].LastName) $($actressCsv[$matched.Index].FirstName) - $($actressCsv[$matched[0].Index].JapaneseName)".Trim()
                                $aggregatedDataObject.Actress[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                $aggregatedDataObject.Actress[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                $aggregatedDataObject.Actress[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using JapaneseName match"
                            }
                        }
                    }
                }

                for ($x = 0; $x -lt $aggregatedDataObject.Actress.Count; $x++) {
                    $matched = @()
                    $matchedActress = @()
                    if (($aggregatedDataObject.Actress[$x].JapaneseName -ne '') -and ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName'))) {
                        $originalActressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                        if ($matched.Count -eq 1) {
                            $matchedActress = $matched
                            $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                            if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            }
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
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
                                $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] matched to [$actressString]"
                            }
                        }
                    } elseif (($aggregatedDataObject.Actress[$x].LastName -eq '' -and $aggregatedDataObject.Actress[$x].FirstName -ne '') -and ($matched = Compare-Object -ReferenceObject ($actressCsv | Where-Object { $_.LastName -eq '' }) -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName'))) {
                        $originalActressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                        if ($matched.Count -eq 1) {
                            $matchedActress = $matched
                            $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                            if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            }
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] matched to [$actressString]"
                        }
                    } elseif ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $aggregatedDataObject.Actress[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                        $originalActressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                        if ($matched.Count -eq 1) {
                            $matchedActress = $matched
                            $aggregatedDataObject.Actress[$x].FirstName = $matchedActress.FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $matchedActress.LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $matchedActress.JapaneseName
                            if ($null -eq $aggregatedDataObject.ThumbUrl -or $aggregatedDataObject.ThumbUrl -eq '') {
                                $aggregatedDataObject.Actress[$x].ThumbUrl = $matchedActress.ThumbUrl
                            }
                            $actressString = $aggregatedDataObject.Actress[$x] | ConvertTo-Json -Depth 32 -Compress
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Actress - $originalActressString] matched to [$actressString]"
                        }
                    }
                }
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Thumbnail csv file is missing or cannot be found at path [$thumbCsvPath]"
            }
        }

        if ($PreferActressAlias) {
            $originalActress = ($Data | Where-Object { $_.Source -eq $selectedDataObject.Actress }).Actress
            if ($aggregatedDataObject.Actress.Count -gt 1) {
                for ($x = 0; $x -lt $aggregatedDataObject.Actress.Count; $x++) {
                    if ($originalActress[$x].EnglishAlias.Count -gt 1) {
                        $aggregatedDataObject.Actress[$x].FirstName = $originalActress[$x].EnglishAlias[-1].FirstName
                        $aggregatedDataObject.Actress[$x].LastName = $originalActress[$x].EnglishAlias[-1].LastName
                        $aggregatedDataObject.Actress[$x].JapaneseName = $originalActress[$x].JapaneseAlias[-1].JapaneseName
                    } else {
                        if ($originalActress[$x].EnglishAlias) {
                            $aggregatedDataObject.Actress[$x].FirstName = $originalActress[$x].EnglishAlias.FirstName
                            $aggregatedDataObject.Actress[$x].LastName = $originalActress[$x].EnglishAlias.LastName
                            $aggregatedDataObject.Actress[$x].JapaneseName = $originalActress[$x].JapaneseAlias.JapaneseName
                        }
                    }
                }
            } elseif ($aggregatedDataObject.Actress.Count -eq 1) {
                if ($originalActress.EnglishAlias.Count -gt 1) {
                    $aggregatedDataObject.Actress[0].FirstName = $originalActress.EnglishAlias[-1].FirstName
                    $aggregatedDataObject.Actress[0].LastName = $originalActress.EnglishAlias[-1].LastName
                    $aggregatedDataObject.Actress[0].JapaneseName = $originalActress.EnglishAlias[-1].JapaneseName
                } else {
                    if ($originalActress.EnglishAlias) {
                        $aggregatedDataObject.Actress[0].FirstName = $originalActress.EnglishAlias.FirstName
                        $aggregatedDataObject.Actress[0].LastName = $originalActress.EnglishAlias.LastName
                        $aggregatedDataObject.Actress[0].JapaneseName = $originalActress.JapaneseAlias.JapaneseName
                    }
                }
            }
        }

        if ($UnknownActress) {
            if ($null -eq $aggregatedDataObject.Actress) {
                $aggregatedDataObject.Actress = @()
                $aggregatedDataObject.Actress += [PSCustomObject]@{
                    LastName     = $null
                    FirstName    = 'Unknown'
                    JapaneseName = 'Unknown'
                    ThumbUrl     = $null
                }
            }
        }

        if ($GenreCsvAutoAdd) {
            $newGenres = @()
            if (Test-Path -LiteralPath $GenreCsvPath) {
                try {
                    $replaceGenres = Import-Csv -LiteralPath $GenreCsvPath
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when importing genre csv [$GenreCsvPath]: $PSItem"
                }

                $currentGenres = $aggregatedDataObject.Genre

                foreach ($genre in $currentGenres) {
                    if ($genre -notin $replaceGenres.Original) {
                        $newGenres += [PSCustomObject]@{
                            Original    = $genre
                            Replacement = ''
                        }
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Genre - $($genre)] added as a new genre"
                    }
                }

                $newGenres | Export-Csv -LiteralPath $GenreCsvPath -Append
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Genre csv file is missing or cannot be found at path [$genreCsvPath]"
            }
        }

        if ($ReplaceGenre) {
            if (Test-Path -LiteralPath $GenreCsvPath) {
                try {
                    $replaceGenres = Import-Csv -LiteralPath $GenreCsvPath
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when importing genre csv [$GenreCsvPath]: $PSItem"
                }

                $newGenres = @()
                $originalGenres = $aggregatedDataObject.Genre
                foreach ($genre in $originalGenres) {
                    if ($genre -in $replaceGenres.Original) {
                        $genreIndexNum = $replaceGenres.Original.IndexOf($genre)
                        if ($replaceGenres.Replacement[$genreIndexNum] -ne '' -and $null -ne $replaceGenres.Replacement[$genreIndexNum]) {
                            $newGenres += $replaceGenres.Replacement[$genreIndexNum]
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Genre - $($replaceGenres.Original[$genreIndexNum])] replaced as [$($replaceGenres.Replacement[$genreIndexNum])]"
                        } else {
                            $newGenres += $genre
                        }
                    } else {
                        $newGenres += $genre
                    }
                }

                $aggregatedDataObject.Genre = $newGenres
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Genre csv file is missing or cannot be found at path [$genreCsvPath]"
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
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Translation language is missing"
            }
        }

        # The displayname value is updated after the previous fields have already been scraped and translated
        $aggregatedDataObject.DisplayName = Convert-JVString -Data $aggregatedDataObject -FormatString $DisplayNameFormat -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress

        if ($Tag[0]) {
            if ($null -eq $aggregatedDataObject.Tag) {
                $aggregatedDataObject.Tag = @()
            }
            foreach ($entry in $Tag) {
                $tagString = (Convert-JVString -Data $aggregatedDataObject -FormatString $entry -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress)
                if ($null -ne $tagString -and $tagstring -ne '') {
                    $aggregatedDataObject.Tag += $tagString
                }
            }
            if ($null -eq $aggregatedDataObject.Tag[0]) {
                $aggregatedDataObject.Tag = $null
            }
        }

        if ($ActressAsTag) {
            if ($null -eq $aggregatedDataObject.Tag) {
                $aggregatedDataObject.Tag = @()
            }
            foreach ($actress in $aggregatedDataObject.Actress) {
                $actressName = $null
                if ($ActressLanguageJa) {
                    if ($null -ne $actress.JapaneseName) {
                        $actressName = ($actress.JapaneseName)
                        if ($null -ne $actress.FirstName -or $null -ne $actress.LastName) {
                            if ($FirstNameOrder) {
                                $altName = ("$($actress.FirstName) $($actress.LastName)").Trim()
                            } else {
                                $altName = ("$($actress.LastName) $($actress.FirstName)").Trim()
                            }
                        }
                    }

                    if ($null -eq $actressName) {
                        if ($null -ne $actress.FirstName -or $null -ne $actress.LastName) {
                            if ($FirstNameOrder) {
                                $actressName = ("$($actress.FirstName) $($actress.LastName)").Trim()
                            } else {
                                $actressName = ("$($actress.LastName) $($actress.FirstName)").Trim()
                            }
                            $altName = $null
                        }
                    }
                } else {
                    if ($null -ne $actress.FirstName -or $null -ne $actress.LastName) {
                        if ($FirstNameOrder) {
                            $actressName = ("$($actress.FirstName) $($actress.LastName)").Trim()
                        } else {
                            $actressName = ("$($actress.LastName) $($actress.FirstName)").Trim()
                        }

                        if ($null -ne $actress.JapaneseName) {
                            $altName = ($actress.JapaneseName)
                        }
                    }

                    if ($null -eq $actressName) {
                        if ($null -ne $actress.JapaneseName) {
                            $actressName = ($actress.JapaneseName).Trim()
                        }
                        $altName = $null
                    }
                }
                if ($null -ne $actressName) {
                    $aggregatedDataObject.Tag += $actressName
                }
            }
        }

        if ($TagCsvAutoAdd) {
            $newTags = @()
            if (Test-Path -LiteralPath $TagCsvPath) {
                try {
                    $replaceTags = Import-Csv -LiteralPath $TagCsvPath
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when importing tag csv [$TagCsvPath]: $PSItem"
                }

                $currentTags = $aggregatedDataObject.Tag

                foreach ($tag in $currentTags) {
                    if ($tag -notin $replaceTags.Original) {
                        $newTags += [PSCustomObject]@{
                            Original    = if ($tag.Count -gt 1) { $tag } else { $tag[0] }
                            Replacement = ''
                        }
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [Tag - $($tag)] added as a new tag"
                    }
                }

                $newTags | Export-Csv -LiteralPath $TagCsvPath -Append
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Tag csv file is missing or cannot be found at path [$tagCsvPath]"
            }
        }

        if ($ReplaceTag) {
            if (Test-Path -LiteralPath $TagCsvPath) {
                try {
                    $replaceTags = Import-Csv -LiteralPath $TagCsvPath
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when importing tag csv [$TagCsvPath]: $PSItem"
                }

                $newTags = @()
                $originalTags = $aggregatedDataObject.Tag
                foreach ($tag in $originalTags) {
                    if ($tag -in $replaceTags.Original) {
                        $replacement = ($replaceTags | Where-Object { $_.Original -eq $tag }).Replacement
                        if ($replacement -ne '' -and $null -ne $replacement) {
                            $newTags += $replacement
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($aggregatedDataObject.Id)] [$($MyInvocation.MyCommand.Name)] [Tag - $tag] replaced as [$replacement]"
                        } else {
                            $newtags += $tag
                        }
                    } else {
                        $newTags += $tag
                    }
                }

                $aggregatedDataObject.Tag = $newTags
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] Tag csv file is missing or cannot be found at path [$tagCsvPath]"
            }
        }

        if ($Tagline -ne '') {
            $taglineString = (Convert-JVString -Data $aggregatedDataObject -FormatString $Tagline -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress)
            if ($null -ne $taglineString -and $taglineString -ne '') {
                $aggregatedDataObject.Tagline += $taglineString
            }
        }

        if ($Credits[0]) {
            $aggregatedDataObject.Credits = @()
            foreach ($entry in $Credits) {
                $credit = (Convert-JVString -Data $aggregatedDataObject -FormatString $entry -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress)
                if ($null -ne $credit -and $credit -ne '') {
                    $aggregatedDataObject.Credits += $credit
                }
            }
            if ($null -eq $aggregatedDataObject.Credits[0]) {
                $aggregatedDataObject.Credits = $null
            }
        }

        $dataObject = [PSCustomObject]@{
            Data     = $aggregatedDataObject
            AllData  = $Data
            Selected = $selectedDataObject
        }

        Write-Output $dataObject
    }
}
