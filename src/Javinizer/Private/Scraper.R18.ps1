function Get-R18ContentId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $contentId = $Webrequest.data.content_id

        if ($contentId -eq '----') {
            $contentId = $null
        }

        Write-Output $contentId
    }
}

function Get-R18Id {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $id = $Webrequest.data.dvd_id

        if ($id -eq '----') {
            $id = $null
        }

        Write-Output $Id
    }
}

function Get-R18Title {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Object]$Replace
    )

    process {
        $title = $Webrequest.data.title
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

function Get-R18Description {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $description = $Webrequest.data.comment

        Write-Output $description
    }
}

function Get-R18ReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseDate = ($Webrequest.data.release_date -split ' ')[0]

        Write-Output $releaseDate
    }
}

function Get-R18ReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseYear = Get-R18ReleaseDate -WebRequest $Webrequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-R18Runtime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $length = $Webrequest.data.runtime_minutes
        Write-Output $length
    }
}

function Get-R18Director {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $director = $Webrequest.data.director
        $director = Convert-HtmlCharacter -String $director

        if ($director -eq '----') {
            $director = $null
        }
        Write-Output $director
    }
}

function Get-R18Maker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $maker = $Webrequest.data.maker.name
        $maker = Convert-HtmlCharacter -String ($maker -replace '\n', ' ')

        if ($maker -eq '----') {
            $maker = $null
        }

        Write-Output $maker
    }
}

function Get-R18Label {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Object]$Replace
    )

    process {
        try {
            $label = $Webrequest.data.label.name
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

        if ($label -eq '----') {
            $label = $null
        }

        Write-Output $label
    }
}

function Get-R18Series {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Object]$Replace
    )

    process {
        if ($Webrequest.data.series) {
            $series = $Webrequest.data.series.name

            if ($Replace) {
                foreach ($string in $Replace.GetEnumerator()) {
                    $series = $series -replace [regex]::Escape($string.Original), $string.Replacement
                }
            }
        } else {
            $series = $null
        }

        Write-Output $series
    }
}

function Get-R18Genre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Object]$Replace
    )

    process {
        $genreArray = @()
        $genres = $Webrequest.data.categories.name

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

function Get-R18Actress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter(Position = 1, ValueFromPipeline = $true)]
        [Object]$AltWebrequest,

        [Parameter()]
        [Switch]$Zh,

        [Parameter()]
        [String]$Url
    )

    process {

        $movieActressObject = @()

        if ($Webrequest.data.actresses) {
            for ($x = 0; $x -lt $Webrequest.data.actresses.count; $x++) {
                if ($Zh) {
                    $movieActressObject += [PSCustomObject]@{
                        LastName     = ($AltWebrequest.data.actresses[$x].name -split ' ')[1] -replace '\\', ''
                        FirstName    = ($AltWebrequest.data.actresses[$x].name -split ' ')[0] -replace '\\', ''
                        JapaneseName = $Webrequest.data.actresses[$x].name -replace '（.*）', '' -replace '&amp;', '&'
                        ThumbUrl     = $Webrequest.data.actresses[$x].image_url
                    }
                } else {
                    $movieActressObject += [PSCustomObject]@{
                        LastName     = ($Webrequest.data.actresses[$x].name -split ' ')[1] -replace '\\', ''
                        FirstName    = ($Webrequest.data.actresses[$x].name -split ' ')[0] -replace '\\', ''
                        JapaneseName = $AltWebrequest.data.actresses[$x].name -replace '（.*）', '' -replace '&amp;', '&'
                        ThumbUrl     = $Webrequest.data.actresses[$x].image_url
                    }
                }
            }
        }

        if ($movieActressObject.count -lt 1) {
            $movieActressObject = $null
        }

        Write-Output $movieActressObject
    }
}

function Get-R18CoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $images = $Webrequest.data.images.jacket_image

        if ($images.large) {
            $coverUrl = $images.large
        } elseif ($images.medium) {
            $coverUrl = $images.medium
        } elseif ($images.small) {
            $coverUrl = $images.small
        } else {
            $coverUrl = $null
        }

        Write-Output $coverUrl
    }
}

function Get-R18ScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $images = $Webrequest.data.gallery

        if ($null -ne $images.large[0]) {
            $screenshotUrl = $images.large
        } elseif ($null -ne $images.medium[0]) {
            $screenshotUrl = $images.medium
        } elseif ($null -ne $images.small[0]) {
            $screenshotUrl = $images.small
        } else {
            $screenshotUrl = $null
        }

        Write-Output $screenshotUrl
    }
}

function Get-R18TrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $trailerUrlObject = $Webrequest.data.sample

        if ($null -ne $trailerUrlObject.high) {
            $trailerUrl = $trailerUrlObject.high
        } elseif ($null -ne $trailerUrlObject.medium) {
            $trailerUrl = $trailerUrlObject.medium
        } elseif ($null -ne $trailerUrlObject.low) {
            $trailerUrl = $trailerUrlObject.low
        } else {
            $trailerUrl = $null
        }

        Write-Output $trailerUrl
    }
}
