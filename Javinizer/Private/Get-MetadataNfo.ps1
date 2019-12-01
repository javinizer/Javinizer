function Get-MetadataNfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject,
        [object]$Settings
    )

    process {
        $nfoString = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<movie>
    <title>$($DataObject.DisplayName)</title>
    <originaltitle>$($DataObject.AlternateTitle)</originaltitle>
    <releasedate>$($DataObject.ReleaseDate)</releasedate>
    <year>$($DataObject.ReleaseYear)</year>
    <director>$($DataObject.Director)</director>
    <studio>$($DataObject.Maker)</studio>
    <rating>$($DataObject.Rating)</rating>
    <votes>$($DataObject.RatingCount)</votes>
    <plot>$($DataObject.Description)</plot>
    <runtime>$($DataObject.Runtime)</runtime>
    <trailer>$($DataObject.Trailer)</trailer>
    <mpaa>XXX</mpaa>
"@

        if ($Settings.Metadata.'add-series-as-tag' -eq 'True') {
            $tagNfoString = @"
    <tag>Series: $($DataObject.Series)</tag>

"@
            $nfoString = $nfoString + $tagNfoString
        }

        foreach ($genre in $DataObject.Genre) {
            $genreNfoString = @"
    <genre>$genre</genre>

"@
            $nfoString = $nfoString + $genreNfoString
        }

        for ($i = 0; $i -lt $DataObject.Actress.Count; $i++) {
            $actressNfoString = @"
    <actor>
        <name>$($DataObject.Actress[$i])</name>
        <thumb>$($DataObject.ActressThumbUrl[$i])</thumb>
    </actor>

"@
            $nfoString = $nfoString + $actressNfoString
        }

        $endNfoString = @"
</movie>
"@
        $nfoString = $nfoString + $endNfoString

        Write-Debug "[$($MyInvocation.MyCommand.Name)] NFO String: `
        $nfoString"
        Write-Output $nfoString
    }
}
