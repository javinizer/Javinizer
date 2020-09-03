function Get-DmmContentId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $contentId = ((($Webrequest.Content -split '<td align="right" valign="top" class="nw">品番：<\/td>')[1] -split '<\/td>')[0] -split '<td>')[1]
        $contentId = Convert-HtmlCharacter -String $contentId
        Write-Output $contentId
    }
}

function Get-DmmTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $title = (($Webrequest.Content -split '<h1 id="title" class="item fn">')[1] -split '<\/h1>')[0]
        $title = Convert-HtmlCharacter -String $title
        Write-Output $title
    }
}

function Get-DmmDescription {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $description = (($Webrequest.Content -split '<meta name="description" content=')[1] -split '\/>')[0]
        # Remove the first 14 characters of the description string
        # This will remove the 'Fanza' string prepending the description in the html
        $description = $description.Substring(14)
        # Remove the last 2 characters of the description string
        # This will remove the extra quotation mark at the end of the description
        $description = $description.Substring(0, $description.Length - 2)
        $description = Convert-HtmlCharacter -String $description
        $description = $description -replace '<([^>]+)>', ''
        $description = (($description -split '\.\*\.')[0]).Trim()
        Write-Output $description
    }
}

function Get-DmmReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseDate = ((($Webrequest.Content -split '<td align="right" valign="top" class="nw">配信開始日：<\/td>')[1] -split '<\/td>')[0] -split '<td>')[1]
        $releaseDate = Convert-HtmlCharacter -String $releaseDate
        $year, $month, $day = $releaseDate -split '/'
        $releaseDate = Get-Date -Year $year -Month $month -Day $day -Format "yyyy-MM-dd"
        Write-Output $releaseDate
    }
}

function Get-DmmReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseYear = Get-DmmReleaseDate -WebRequest $Webrequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-DmmRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $length = ((($Webrequest.Content -split '<td align="right" valign="top" class="nw">収録時間：<\/td>')[1] -split '<\/td>')[0] -split '<td>')[1]
        $length = ($length -split '分')[0]
        Write-Output $length
    }
}

function Get-DmmDirector {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $director = ((($Webrequest.Content -split '監督：<\/td>')[1] -split '<\/a>')[0] -split '>')[2]
        $director = Convert-HtmlCharacter -String $director

        if ($director -eq '</tr') {
            $director = $null
        }

        Write-Output $director
    }
}

function Get-DmmMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $maker = ((($Webrequest.Content -split '<td align="right" valign="top" class="nw">メーカー：<\/td>')[1] -split '<\/a>')[0] -split '>')[2]
        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-DmmLabel {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $label = ((($Webrequest.Content -split '<td align="right" valign="top" class="nw">レーベル：<\/td>')[1] -split '<\/a>')[0] -split '>')[2]
        $label = Convert-HtmlCharacter -String $label

        if ($label -eq '</tr') {
            $label = $null
        }

        Write-Output $label
    }
}

function Get-DmmSeries {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $series = ((($Webrequest.Content -split '<td align="right" valign="top" class="nw">シリーズ：<\/td>')[1] -split '<\/a>')[0] -split '>')[2]
        $series = Convert-HtmlCharacter -String $series

        if ($series -eq '</tr') {
            $series = $null
        }

        Write-Output $series
    }
}

function Get-DmmRating {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $rating = (((($Webrequest.Content -split '<p class="d-review__average">')[1] -split '<\/strong>')[0] -split '<strong>')[1] -split '点')[0]
        # Multiply the rating value by 2 to conform to 1-10 rating standard
        $integer = [int]$rating * 2
        if ($integer -eq 0) {
            $integer = $null
        } else {
            $rating = $integer.Tostring()
        }

        Write-Output $rating
    }
}

function Get-DmmRatingCount {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $ratingCount = (($Webrequest.Content -split '<p class="d-review__evaluates">')[1] -split '<\/p>')[0]
        $ratingCount = (($ratingCount -split '<strong>')[1] -split '<\/strong>')[0]
        Write-Output $ratingCount
    }
}

function Get-DmmActress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $movieActressObject = @()
        $actressHtml = ((($Webrequest.Content -split '出演者：<\/td>')[1] -split '<\/td>')[0] -split '<span id="performer">')[1]
        $actressHtml = $actressHtml -replace '<a href="\/digital\/videoa\/-\/list\/=\/article=actress\/id=(.*)\/">', ''
        $actressHtml = $actressHtml -split '<\/a>', ''

        if ($actressHtml[0] -ne '') {
            foreach ($actress in $actressHtml) {
                $actress = Convert-HtmlCharacter -String $actress
                if ($actress -ne '') {
                    $movieActressObject += [PSCustomObject]@{
                        LastName     = $null
                        FirstName    = $null
                        JapaneseName = $actress -replace '<\/a>', ''
                        ThumbUrl     = $null
                    }
                }
            }
        } else {
            $movieActressObject = $null
        }
        Write-Output $movieActressObject

    }
}

function Get-DmmGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $genreArray = @()
        $genre = (((($Webrequest.Content -split 'ジャンル：<\/td>')[1] -split '<\/td>')[0] -split '<td>')[1] -split '">')
        $genre = ($genre -replace '<\/a>', '') -replace '&nbsp;&nbsp;', ''
        $genre = $genre -replace '<a href="\/digital\/videoa\/-\/list\/=\/article=keyword\/id=(.*)\/'

        foreach ($entry in $genre) {
            $entry = Convert-HtmlCharacter -String $entry
            if ($entry -ne '') {
                $genreArray += $entry
            }
        }

        if ($genreArray.Count -eq 0) {
            $genreArray = $null
        }

        Write-Output $genreArray
    }
}

function Get-DmmCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $coverUrl = ((($Webrequest.Content -split '<div class="center" id="sample-video">')[1] -split '" target')[0] -split '<a href="')[1]
        $coverUrl = Convert-HtmlCharacter -String $coverUrl
        Write-Output $coverUrl
    }
}
function Get-DmmScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $screenshotUrl = @()
        $screenshotHtml = $Webrequest.Links | Where-Object { $_.name -eq 'sample-image' }
        $screenshotHtml = $screenshotHtml.'outerHTML'

        foreach ($screenshot in $screenshotHtml) {
            $screenshot = (($screenshot -split '<img src="')[1] -split '"')[0]
            $screenshotUrl += $screenshot -replace '-', 'jp-'
        }

        Write-Output $screenshotUrl
    }
}

# ! Unable to get trailer url from HTTP from main DMM video page
<# function Get-DmmTrailerUrl {
    param (
        [Object]$Webrequest
    )

    begin {
        $trailerUrl = @()
    }

    process {
        $trailerHtml = $Webrequest.Content -split '\n'
        $trailerHtml = $trailerHtml | Select-String -Pattern 'https:\/\/cc3001\.dmm\.co\.jp\/litevideo\/freepv' -AllMatches

        foreach ($trailer in $trailerHtml) {
            $trailer = (($trailer -split '"')[1] -split '"')[0]
            $trailerUrl += $trailer
        }

        Write-Output $trailerUrl
    }
} #>
