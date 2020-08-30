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
        [Alias('sort.metadata.thumbcsv.convertalias')]
        [Boolean]$ThumbCsvAlias,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.genre.normalize')]
        [Boolean]$NormalizeGenre,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.genre.ignore')]
        [Array]$IgnoreGenre,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.requiredfield')]
        [Array]$RequiredField,
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.maxtitlelength')]
        [Int]$MaxTitleLength
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
                    Write-JLog -Level Debug -Message "[$($Data[0].Id)] [$($MyInvocation.MyCommand.Name)] [$field - $priority] Set to [$($sourceData.$field | ConvertTo-Json -Compress)]"
                }
            }
        }

        $aggregatedDataObject.DisplayName = Convert-JVString -Data $aggregatedDataObject -FormatString $DisplayNameFormat


        $dataObject = [PSCustomObject]@{
            Data = $aggregatedDataObject
        }

        Write-Output $dataObject
    }
}
