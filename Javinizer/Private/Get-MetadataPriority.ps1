function Get-MetadataPriority {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$Settings,
        [ValidateSet('id', 'title', 'releasedate', 'releaseyear', 'runtime', 'description', 'director', 'maker', 'label', 'series', 'rating', 'actress', 'actressthumburl', 'genre', 'coverurl', 'screenshoturl', 'alternatetitle')]
        [string]$Type
    )

    Process {
        $priority = $Settings.Metadata."$Type-priority"
        $priorityArray = $priority -split ','
        Write-Output $priorityArray
    }
}
