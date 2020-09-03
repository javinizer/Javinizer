#Requires -PSEdition Core

function Get-JVNfo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$DisplayName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Title,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$AlternateTitle,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$ReleaseDate,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Runtime,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Director,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Maker,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Label,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Series,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PSObject]$Actress,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Array]$Genre,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$CoverUrl,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Array]$ScreenshotUrl,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$TrailerUrl,

        [Parameter()]
        [Boolean]$ActressLanguageJa,

        [Parameter()]
        [Boolean]$NameOrder,

        [Parameter()]
        [Boolean]$AddTag
    )

    process {
        function Convert-NfoChar {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
                [AllowEmptyString()]
                [String]$String
            )

            process {
                $newString = ((($String -replace '&', '&amp;') -replace '<', '(') -replace '>', ')') -replace '/', '-'
                Write-Output $newString
            }
        }

        $DisplayName = Convert-NfoChar -String $DisplayName -ErrorAction SilentlyContinue
        $AlternateTitle = Convert-NfoChar -String $AlternateTitle -ErrorAction SilentlyContinue
        $Title = Convert-NfoChar -String $Title -ErrorAction SilentlyContinue
        $Description = Convert-NfoChar -String $Description -ErrorAction SilentlyContinue
        $Director = Convert-NfoChar -String $Director -ErrorAction SilentlyContinue
        $Maker = Convert-NfoChar -String $Maker -ErrorAction SilentlyContinue
        $Label = Convert-NfoChar -String $Label -ErrorAction SilentlyContinue
        $Series = Convert-NfoChar -String $Series -ErrorAction SilentlyContinue

        $nfoString = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<movie>
    <title>$DisplayName</title>
    <originaltitle>$AlternateTitle</originaltitle>
    <id>$Id</id>
    <releasedate>$ReleaseDate</releasedate>
    <director>$Director</director>
    <studio>$Maker</studio>
    <plot>$Description</plot>
    <runtime>$Runtime</runtime>
    <trailer>$TrailerUrl</trailer>
    <mpaa>XXX</mpaa>
    <set>$Series</set>

"@

        if ($AddTag) {
            $tagNfoString = @"
    <tag>$Series</tag>

"@
            $nfoString = $nfoString + $tagNfoString
        }

        foreach ($item in $Genre) {
            $item = Convert-NfoChar -String $item
            $genreNfoString = @"
    <genre>$item</genre>

"@
            $nfoString = $nfoString + $genreNfoString
        }

        foreach ($item in $Actress) {
            $actressName = $null
            if ($ActressLanguageJa) {
                if ($null -ne $item.JapaneseName) {
                    $actressName = ($item.JapaneseName)
                }

                if ($null -eq $actressName) {
                    if ($null -ne $item.FirstName -or $null -ne $item.LastName) {
                        if ($NameOrder) {
                            $actressName = ("$($item.FirstName) $($item.LastName)").Trim()
                        } else {
                            $actressName = ("$($item.LastName) $($item.FirstName)").Trim()
                        }
                    }
                }
            } else {
                if ($null -ne $item.FirstName -or $null -ne $item.LastName) {
                    if ($NameOrder) {
                        $actressName = ("$($item.FirstName) $($item.LastName)").Trim()
                    } else {
                        $actressName = ("$($item.LastName) $($item.FirstName)").Trim()
                    }
                }

                if ($null -eq $actressName) {
                    if ($null -ne $item.JapaneseName) {
                        $actressName = ($item.JapaneseName).Trim()
                    }
                }
            }


            $actressNfoString = @"
    <actor>
        <name>$actressName</name>
        <thumb>$($item.ThumbUrl)</thumb>
        <role>Actress</role>
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
}
