function Get-MetadataPriority {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$Settings,
        [ValidateSet('id', 'title', 'releasedate', 'releaseyear', 'runtime', 'description', 'director', 'maker', 'label', 'series', 'rating', 'ratingcount', 'actress', 'trailerurl', 'actressthumburl', 'genre', 'coverurl', 'screenshoturl', 'alternatetitle')]
        [string]$Type
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        $priority = $Settings.Metadata."$Type-priority"
        $priorityArray = $priority -split ','
        Write-Output $priorityArray
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
