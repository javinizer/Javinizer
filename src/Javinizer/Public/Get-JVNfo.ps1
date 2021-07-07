function Get-JVNfo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$DisplayName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$Title,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$AlternateTitle,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PSObject]$Rating,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$ReleaseDate,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$Runtime,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$Director,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$Maker,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String]$Label,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
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
        [AllowEmptyString()]
        [String]$TrailerUrl,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Array]$Tag,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Tagline,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Array]$Credits,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PSObject]$MediaInfo,

        [Parameter()]
        [Boolean]$ActressLanguageJa,

        [Parameter()]
        [Boolean]$NameOrder,

        [Parameter()]
        [String]$OriginalPath,

        [Parameter()]
        [Boolean]$AltNameRole,

        [Parameter()]
        [Boolean]$AddGenericRole
    )

    process {
        function Convert-NfoChar {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
                [AllowEmptyString()]
                [PSObject]$String
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
        $Tagline = Convert-NfoChar -String $Tagline -ErrorAction SilentlyContinue
        $releaseYear = ($ReleaseDate -split '-')[0]

        $nfoString = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<movie>
    <title>$DisplayName</title>
    <originaltitle>$AlternateTitle</originaltitle>
    <id>$Id</id>
    <premiered>$ReleaseDate</premiered>
    <year>$releaseYear</year>
    <director>$Director</director>
    <studio>$Maker</studio>
    <rating>$($Rating.Rating)</rating>
    <votes>$($Rating.Votes)</votes>
    <plot>$Description</plot>
    <runtime>$Runtime</runtime>
    <trailer>$TrailerUrl</trailer>
    <mpaa>XXX</mpaa>
    <tagline>$Tagline</tagline>
    <set>$Series</set>
    <thumb>$CoverUrl</thumb>

"@

        if ($OriginalPath) {
            $originalPathNfoString = @"
    <originalpath>$OriginalPath</originalpath>

"@
            $nfoString = $nfoString + $originalPathNfoString

        }

        foreach ($item in $Tag) {
            $item = Convert-NfoChar -String $item -ErrorAction SilentlyContinue
            $tagNfoString = @"
    <tag>$item</tag>

"@
            $nfoString = $nfoString + $tagNfoString
        }

        foreach ($item in $Credits) {
            $item = Convert-NfoChar -String $item -ErrorAction SilentlyContinue
            $tagNfoString = @"
    <credits>$item</credits>

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
                if ($null -ne $item.JapaneseName -and $item.JapaneseName -ne '') {
                    $actressName = ($item.JapaneseName)
                    if ($null -ne $item.FirstName -or $null -ne $item.LastName) {
                        if ($NameOrder) {
                            $altName = ("$($item.FirstName) $($item.LastName)").Trim()
                        } else {
                            $altName = ("$($item.LastName) $($item.FirstName)").Trim()
                        }
                    }
                }

                if ($null -eq $actressName -or $actressName -eq '') {
                    if ($null -ne $item.FirstName -or $null -ne $item.LastName) {
                        if ($NameOrder) {
                            $actressName = ("$($item.FirstName) $($item.LastName)").Trim()
                        } else {
                            $actressName = ("$($item.LastName) $($item.FirstName)").Trim()
                        }
                        $altName = $null
                    }
                }
            } else {
                if (($null -ne $item.FirstName -and $item.FirstName -ne '') -or ($null -ne $item.LastName -and $item.LastName -ne '')) {
                    if ($NameOrder) {
                        $actressName = ("$($item.FirstName) $($item.LastName)").Trim()
                    } else {
                        $actressName = ("$($item.LastName) $($item.FirstName)").Trim()
                    }

                    if ($null -ne $item.JapaneseName) {
                        $altName = ($item.JapaneseName)
                    }
                }

                if ($null -eq $actressName) {
                    if ($null -ne $item.JapaneseName) {
                        $actressName = ($item.JapaneseName).Trim()
                    }
                    $altName = $null
                }
            }

            if ($AltNameRole) {
                $actressNfoString = @"
    <actor>
        <name>$actressName</name>
        <altname>$altName</altname>
        <thumb>$($item.ThumbUrl)</thumb>
        <role>$altName</role>
    </actor>

"@
            } elseif ($AddGenericRole) {
                $actressNfoString = @"
    <actor>
        <name>$actressName</name>
        <altname>$altName</altname>
        <thumb>$($item.ThumbUrl)</thumb>
        <role>Actress</role>
    </actor>

"@
            } else {
                $actressNfoString = @"
    <actor>
        <name>$actressName</name>
        <altname>$altName</altname>
        <thumb>$($item.ThumbUrl)</thumb>
    </actor>

"@
            }

            $nfoString = $nfoString + $actressNfoString
        }

        if ($MediaInfo) {
            $mediaNfoString = @"
    <fileinfo>
        <streamdetails>
            <video>
                <codec>$($MediaInfo.VideoCodec)</codec>
                <aspect>$($MediaInfo.VideoAspect)</aspect>
                <width>$($MediaInfo.VideoWidth)</width>
                <height>$($MediaInfo.VideoHeight)</height>
                <durationinseconds>$($MediaInfo.VideoDuration)</durationinseconds>
            </video>
            <audio>
                <codec>$($MediaInfo.AudioCodec)</codec>
                <language>$($MediaInfo.AudioLanguage)</language>
                <channels>$($MediaInfo.AudioChannels)</channels>
            </audio>
        </streamdetails>
    </fileinfo>

"@
            $nfoString = $nfoString + $mediaNfoString
        }

        $endNfoString = @"
</movie>
"@
        $nfoString = $nfoString + $endNfoString

        Write-Output $nfoString
    }
}
