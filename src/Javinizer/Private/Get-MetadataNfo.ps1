function Get-MetadataNfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject,
        [object]$Settings,
        [object]$R18ThumbCsv
    )

    begin {
        $displayName = (($DataObject.DisplayName -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        $alternateTitle = (($DataObject.AlternateTitle -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        $director = (($DataObject.Director -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        $maker = (($DataObject.Maker -replace '&', '&amp;') -replace '<', '(') -replace , '>', ''
        $description = (($DataObject.Description -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        $series = (($DataObject.Series -replace '&', '&amp;') -replace '<', '(') -replace , '>', ')'
        if ($Settings.Metadata.'first-last-name-order' -eq 'True') {
            $csvFullName = $R18ThumbCsv.FullName
            $csvFullNameAlias = $R18ThumbCsv.Alias
        } else {
            $csvFullName = $R18ThumbCsv.FullNameReversed
            $csvFullNameAlias = $R18ThumbCsv.Alias
        }
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
                if (($DataObject.ActressThumbUrl -like '*nowprinting*') -or ($null -eq $DataObject.ActressThumbUrl)) {
                    if (($csvFullName -like $DataObject.Actress) -or ($csvFullNameAlias -like $DataObject.Actress)) {
                        $index = $csvFullname.IndexOf("$($DataObject.Actress)")
                        if ($index -eq -1) {
                            $index = $csvFullnameAlias.IndexOf("$($DataObject.Actress)")
                        }
                        $DataObject.ActressThumbUrl = $R18ThumbCsv.ThumbUrl[$index]
                    } else {
                        $DataObject.ActressThumbUrl = ''
                    }
                }

                $actressNfoString = @"
    <actor>
        <name>$($DataObject.Actress)</name>
        <thumb>$($DataObject.ActressThumbUrl)</thumb>
    </actor>

"@
            } else {
                for ($i = 0; $i -lt $DataObject.Actress.Count; $i++) {
                    if ($null -eq $DataObject.ActressThumbUrl) {
                        # Create empty array amounting to number of actresses found if scraped from javlibrary
                        # This will allow matching actresses from r18 thumb csv
                        $DataObject.ActressThumbUrl = @()
                        foreach ($actress in $DataObject.Actress) {
                            $DataObject.ActressThumbUrl += ''
                        }
                    }
                    if (($dataObject.ActressThumbUrl[$i] -like '*nowprinting*') -or ($DataObject.ActressThumbUrl[$i] -eq '')) {
                        if (($csvFullName -like $DataObject.Actress[$i]) -or ($csvFullNameAlias -like $DataObject.Actress[$i])) {
                            $index = $csvFullname.IndexOf("$($DataObject.Actress[$i])")
                            if ($index -eq -1) {
                                $index = $csvFullnameAlias.IndexOf("$($DataObject.Actress[$i])")
                            }
                            $DataObject.ActressThumbUrl[$i] = $R18ThumbCsv.ThumbUrl[$index]
                        } else {
                            $DataObject.ActressThumbUrl[$i] = ''
                        }
                    }
                    $actressNfoString += @"
    <actor>
        <name>$($DataObject.Actress[$i])</name>
        <thumb>$($DataObject.ActressThumbUrl[$i])</thumb>
    </actor>

"@
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
