function Get-MetadataNfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject,
        [object]$Settings
    )

    begin {
        $displayName    = $DataObject.DisplayName -replace '&', '&amp;'
        $alternateTitle = $DataObject.AlternateTitle -replace '&', '&amp;'
        $director       = $DataObject.Director -replace '&', '&amp;'
        $maker          = $DataObject.Maker -replace '&', '&amp;'
        $description    = $DataObject.Description -replace '&', '&amp;'
        $series         = $DataObject.Series -replace '&', '&amp;'
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
            $genreNfoString = @"
    <genre>$genre</genre>

"@
            $nfoString = $nfoString + $genreNfoString
        }

        if ($DataObject.Actress.Count -gt 0) {
            if ($DataObject.Actress.Count -eq 1) {
                if ($null -ne $DataObject.ActressThumbUrl) {
                    if ($dataObject.ActressThumbUrl -like '*nowprinting*') {
                        $DataObject.ActressThumbUrl = ''
                    }
                    $actressNfoString = @"
    <actor>
        <name>$($DataObject.Actress)</name>
        <thumb>$($DataObject.ActressThumbUrl)</thumb>
    </actor>

"@
                } else {
                    $actressNfoString = @"
    <actor>
        <name>$($DataObject.Actress)</name>
        <thumb></thumb>
    </actor>

"@
                }
            } else {
                if ($null -ne $DataObject.ActressThumbUrl) {
                    for ($i = 0; $i -lt $DataObject.Actress.Count; $i++) {
                        if ($dataObject.ActressThumbUrl[$i] -like '*nowprinting*') {
                            $DataObject.ActressThumbUrl[$i] = ''
                        }
                        $actressNfoString += @"
    <actor>
        <name>$($DataObject.Actress[$i])</name>
        <thumb>$($DataObject.ActressThumbUrl[$i])</thumb>
    </actor>

"@
                    }
                } else {
                    for ($i = 0; $i -lt $DataObject.Actress.Count; $i++) {
                        $actressNfoString += @"
    <actor>
        <name>$($DataObject.Actress[$i])</name>
        <thumb></thumb>
    </actor>

"@
                    }
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
