function Get-MetadataPriority {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$Settings,
        [ValidateSet('id', 'title', 'releasedate', 'releaseyear', 'runtime', 'description', 'director', 'maker', 'label', 'series', 'rating', 'actress', 'genre', 'coverurl', 'screenshoturl', 'alternatetitle')]
        [string]$Type
    )

    process {
        $priority = $Settings.Metadata."$Type-priority"
        $priorityArray = $priority -split ','
        Write-Output $priorityArray
    }
}
