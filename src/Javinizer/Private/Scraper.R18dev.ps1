function Get-R18DevContentId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $contentId = $Webrequest.content_id

        Write-Output $contentId
    }
}

function Get-R18DevId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $id = $Webrequest.dvd_id

        Write-Output $Id
    }
}

function Get-R18DevTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Switch]$Ja,

        [Parameter()]
        [Object]$Replace
    )

    process {
        $title = if ($Ja) {
            $Webrequest.title_ja
        } elseif ($Webrequest.title_en) {
            $Webrequest.title_en
        } else { $Webrequest.title }

        $title = Convert-HtmlCharacter -String $title
        if ($Replace) {
            foreach ($string in $Replace.GetEnumerator()) {
                $title = $title -replace [regex]::Escape($string.Original), $string.Replacement
                $title = $title -replace '  ', ' '
            }
        }

        Write-Output $Title
    }
}

function Get-R18DevDescription {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Switch]$Ja
    )

    process {
        $description = if ($Ja) { '' } else { $Webrequest.comment_en }

        Write-Output $description
    }
}

function Get-R18DevReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseDate = ($Webrequest.release_date -split ' ')[0]

        Write-Output $releaseDate
    }
}

function Get-R18DevReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseYear = Get-R18DevReleaseDate -WebRequest $Webrequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-R18DevRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $length = $Webrequest.runtime_mins
        Write-Output $length
    }
}

function Get-R18DevDirector {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Switch]$Ja
    )

    process {
        if ($Webrequest.directors.count -gt 0) {
            if ($Ja) {
                $director = $Webrequest.directors[0].name_kanji
            } else {
                $director = $Webrequest.directors[0].name_romaji
            }
        }

        Write-Output $director
    }
}

function Get-R18DevMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Switch]$Ja
    )

    process {
        $maker = if ($Ja) { $Webrequest.maker_name_ja } else { $Webrequest.maker_name_en }
        $maker = Convert-HtmlCharacter -String ($maker -replace '\n', ' ')

        Write-Output $maker
    }
}

function Get-R18DevLabel {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Switch]$Ja,

        [Parameter()]
        [Object]$Replace
    )

    process {
        try {
            $label = if ($Ja) { $Webrequest.label_name_ja } else { $Webrequest.label_name_en }
        } catch {
            return
        }

        if ($Replace) {
            foreach ($string in $Replace.GetEnumerator()) {
                if (($label -split ' ') -eq $string.Original) {
                    $label = $label -replace [regex]::Escape($string.Original), $string.Replacement
                }
            }
        }

        $label = Convert-HtmlCharacter -String ($label -replace '\n', ' ')

        Write-Output $label
    }
}

function Get-R18DevSeries {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Switch]$Ja,

        [Parameter()]
        [Object]$Replace
    )

    process {
        $series = if ($Ja) { $Webrequest.series_name_ja } else { $Webrequest.series_name_en }

        if ($Replace) {
            foreach ($string in $Replace.GetEnumerator()) {
                $series = $series -replace [regex]::Escape($string.Original), $string.Replacement
            }
        }

        Write-Output $series
    }
}

function Get-R18DevGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Switch]$Ja,

        [Parameter()]
        [Object]$Replace
    )

    process {
        $genreArray = @()
        $genres = if ($Ja) { $Webrequest.categories.name_ja } else { $Webrequest.categories.name_en }

        foreach ($genre in $genres) {
            $genre = Convert-HtmlCharacter -String $genre
            if ($Replace) {
                foreach ($string in $Replace.GetEnumerator()) {
                    if (($genre -split ' ') -eq $string.Original) {
                        $genre = $genre -replace [regex]::Escape($string.Original), $string.Replacement
                    }
                }
            }
            $genreArray += $genre
        }

        if ($genreArray.Count -eq 0) {
            $genreArray = $null
        }

        Write-Output $genreArray
    }
}

function Get-R18DevActress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [String]$Url
    )

    process {

        $movieActressObject = @()

        if ($Webrequest.actresses) {
            for ($x = 0; $x -lt $Webrequest.actresses.count; $x++) {
                $ThumbUrl = $Webrequest.actresses[$x].image_url
                if ($null -ne $ThumbUrl -and !$ThumbUrl.StartsWith('http')) {
                    $ThumbUrl = 'https://pics.dmm.co.jp/mono/actjpgs/' + $Webrequest.actresses[$x].image_url
                }

                $movieActressObject += [PSCustomObject]@{
                    LastName     = ($Webrequest.actresses[$x].name_romaji -split ' ')[1] -replace '\\', ''
                    FirstName    = ($Webrequest.actresses[$x].name_romaji -split ' ')[0] -replace '\\', ''
                    JapaneseName = $Webrequest.actresses[$x].name_kanji -replace '（.*）', '' -replace '&amp;', '&'
                    ThumbUrl     = $ThumbUrl
                }
            }
        }

        if ($movieActressObject.count -lt 1) {
            $movieActressObject = $null
        }

        Write-Output $movieActressObject
    }
}

function Get-R18DevCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $coverUrl = $Webrequest.jacket_full_url

        Write-Output $coverUrl
    }
}

function Get-R18DevScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $images = $Webrequest.gallery

        if ($images.count -gt 0) {
            if ($null -ne $images.image_full[0]) {
                $screenshotUrl = $images.image_full
            } elseif ($null -ne $images.image_thumb[0]) {
                $screenshotUrl = $images.image_thumb
            } else {
                $screenshotUrl = $null
            }
        } else {
            return
        }

        Write-Output $screenshotUrl
    }
}

function Get-R18DevTrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $trailerUrl = $Webrequest.sample_url

        Write-Output $trailerUrl
    }
}
