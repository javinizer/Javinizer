function Get-MetadataNfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        $nfoString = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<movie>
    <title>$($DataObject.DisplayTitle)</title>
    <originaltitle>$($DataObject.AlternateTitle)</originaltitle>
    <premiered>$($DataObject.ReleaseDate)</premiered>
    <director>$($DataObject.Director)</director>
    <studio>$($DataObject.Maker)</studio>
    <ratings>
        <rating name="javinizer" max="10">
            <value>$($DataObject.Rating)</value>
        </rating>
    </ratings>
    <plot>$($DataObject.Description)</plot>
    <runtime>$($DataObject.Runtime)</runtime>
    <country>Japan</country>

"@

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
        Write-Output $nfoString
    }


    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
