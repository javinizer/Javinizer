function Get-JavAggregatedData {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.actress')]
        [Array]$ActressPriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.alternatetitle')]
        [Array]$AlternateTitlePriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.coverurl')]
        [Array]$CoverUrlPriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.description')]
        [Array]$DescriptionPriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.director')]
        [Array]$DirectorPriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.genre')]
        [Array]$GenrePriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.id')]
        [Array]$IdPriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.label')]
        [Array]$LabelPriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.maker')]
        [Array]$MakerPriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.releasedate')]
        [Array]$ReleaseDatePriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.runtime')]
        [Array]$RuntimePriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.series')]
        [Array]$SeriesPriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.screenshoturl')]
        [Array]$ScreenshotUrlPriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.title')]
        [Array]$TitlePriority,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.priority.trailerurl')]
        [Array]$TrailerUrlPriority
    )

    process {
        Write-Host $ActressPriority
        Write-Host $LabelPriority
    }
}
