function Get-R18DataObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Id
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        $movieDataObject = @()
    }

    process {
        $r18Url = Get-R18Url -Id $Id
        if ($null -ne $R18Url) {
            try {
                $webRequest = Invoke-WebRequest -Uri $r18Url
            } catch {
                throw $_
            }

            $movieDataObject = [pscustomobject]@{
                Url           = $r18Url
                ContentId     = Get-R18ContentId -WebRequest $webRequest
                Id            = Get-R18MovieId -WebRequest $webRequest
                Title         = Get-R18MovieTitle -WebRequest $webRequest
                Date          = Get-R18MovieReleaseDate -WebRequest $webRequest
                Year          = Get-R18MovieReleaseYear -WebRequest $webRequest
                Length        = Get-R18MovieLength -WebRequest $webRequest
                Director      = Get-R18MovieDirector -WebRequest $webRequest
                Maker         = Get-R18MovieMaker -WebRequest $webRequest
                Label         = Get-R18MovieLabel -WebRequest $webRequest
                Series        = Get-R18MovieSeries -WebRequest $webRequest
                Rating        = Get-R18MovieRating -WebRequest $webRequest
                Actress       = Get-R18MovieActress -WebRequest $webRequest
                Genre         = Get-R18MovieGenre -WebRequest $webRequest
                CoverUrl      = Get-R18MovieCoverUrl -WebRequest $webRequest
                ScreenshotUrl = Get-R18MovieScreenshotUrl -WebRequest $webRequest
            }
        }

    }

    end {
        $movieDataObject | Format-List | Out-String | Write-Debug
        Write-Output $movieDataObject
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

function Get-R18ContentId {
    param (
        [object]$WebRequest
    )

    $movieContentId = (((($WebRequest.Content -split '<dt>Content ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
    $movieContentId = Convert-HTMLCharacter -String $movieContentId
    Write-Output $movieContentId
}

function Get-R18MovieId {
    param (
        [object]$WebRequest
    )

    $movieId = (((($WebRequest.Content -split '<dt>DVD ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
    $movieId = Convert-HTMLCharacter -String $movieId
    Write-Output $movieId
}

function Get-R18MovieTitle {
    param (
        [object]$WebRequest
    )

    $movieTitle = (($WebRequest.Content -split '<cite itemprop=\"name\">')[1] -split '<\/cite>')[0]
    $movieTitle = Convert-HTMLCharacter -String $movieTitle
    Write-Output $movieTitle
}

function Get-R18MovieReleaseDate {
    param (
        [object]$WebRequest
    )

    $movieReleaseDate = (($WebRequest.Content -split '<dd itemprop=\"dateCreated\">')[1] -split '<br>')[0]
    $movieReleaseDate = ($movieReleaseDate.Trim() -replace '\.', '') -replace ',', ''
    $month, $day, $year = $movieReleaseDate -split ' '

    # Convert full month names to abbreviated values due to non-standard naming conventions on R18 website
    if ($month -eq 'June') {
        $month = 'Jun'
    } elseif ($month -eq 'July') {
        $month = 'Jul'
    }

    # Convert the month name to a numeric value to conform with CMS datetime standards
    $month = [array]::indexof([cultureinfo]::CurrentCulture.DateTimeFormat.AbbreviatedMonthNames, "$month") + 1
    $movieReleaseDate = Get-Date -Year $year -Month $month -Day $day -format "yyyy-MM-dd"
    Write-Output $movieReleaseDate
}

function Get-R18MovieReleaseYear {
    param (
        [object]$WebRequest
    )

    $movieReleaseYear = Get-R18MovieReleaseDate -WebRequest $WebRequest
    $movieReleaseYear = ($movieReleaseYear -split '-')[0]
    Write-Output $movieReleaseYear
}

function Get-R18MovieLength {
    param (
        [object]$WebRequest
    )

    $movieLength = ((($WebRequest.Content -split '<dd itemprop="duration">')[1] -split '\.')[0]) -replace 'min', ''
    $movieLength = Convert-HTMLCharacter -String $movieLength
    Write-Output $movieLength
}

function Get-R18MovieDirector {
    param (
        [object]$WebRequest
    )

    $movieDirector = (($WebRequest.Content -split '<dd itemprop="director">')[1] -split '<br>')[0]
    $movieDirector = Convert-HTMLCharacter -String $movieDirector

    if ($movieDirector -eq '----') {
        $movieDirector = $null
    }

    Write-Output $movieDirector
}

function Get-R18MovieMaker {
    param (
        [object]$WebRequest
    )

    $movieMaker = ((($WebRequest.Content -split '<dd itemprop="productionCompany" itemscope itemtype="http:\/\/schema.org\/Organization\">')[1] -split '<\/a>')[0] -split '>')[1]
    $movieMaker = Convert-HTMLCharacter -String $movieMaker
    Write-Output $movieMaker
}

function Get-R18MovieLabel {
    param (
        [object]$WebRequest
    )

    $movieLabel = ((($WebRequest.Content -split '<dt>Label:<\/dt>')[1] -split '<br>')[0] -split '<dd>')[1]
    $movieLabel = Convert-HTMLCharacter -String $movieLabel
    Write-Output $movieLabel
}

function Get-R18MovieSeries {
    param (
        [object]$WebRequest
    )

    $movieSeries = (((($WebRequest.Content -split '<dt>Series:</dt>')[1] -split '<\/a><br>')[0] -split '<dd>')[1] -split '>')[1]
    $movieSeries = Convert-HTMLCharacter -String $movieSeries

    if ($movieSeries -like '</dd*') {
        $movieSeries = $null
    }

    Write-Output $movieSeries
}

function Get-R18MovieRating {
    param (
        [object]$WebRequest
    )

    $movieRating = ''
    Write-Output $movieRating
}

function Get-R18MovieGenre {
    param (
        [object]$WebRequest
    )

    $movieGenre = @()
    $movieGenreHtml = ((($WebRequest.Content -split '<div class="pop-list">')[1] -split '<\/div>')[0] -split '<\/a>') -split '>'

    foreach ($genre in $movieGenreHtml) {
        $genre = $genre.trim()
        if ($genre -notmatch 'https:\/\/www\.r18\.com\/videos\/vod\/movies\/list\/id=(.*)' -and $genre -ne '') {
            $genre = Convert-HTMLCharacter -String $genre
            $movieGenre += $genre
        }
    }

    Write-Output $movieGenre
}

function Get-R18MovieActress {
    param (
        [object]$WebRequest
    )

    $movieActress = @()
    $movieActressThumb = @()
    $movieActressHtml = (($WebRequest.Content -split '<div itemprop="actors" data-type="actress-list" class="pop-list">')[1] -split '<div class="product-categories-list product-box-list">')[0]
    $movieActressHtml = $movieActressHtml -replace '<a itemprop="url" href="https:\/\/www\.r18\.com\/videos\/vod\/movies\/list\/id=(.*)\/pagesize=(.*)\/price=all\/sort=popular\/type=actress\/page=(.*)\/">', ''
    $movieActressHtml = $movieActressHtml -replace '<span itemscope itemtype="http:\/\/schema.org\/Person">', ''
    $movieActressHtml = $movieActressHtml -split '<\/a>'

    foreach ($actress in $movieActressHtml) {
        if ($actress -match '<span itemprop="name">') {
            $movieActress += (($actress -split '<span itemprop="name">')[1] -split '<\/span>')[0]
        }
    }

    if ($movieActress -eq '----') {
        $movieActress = $null
    }

    foreach ($actress in $movieActress) {
        $movieActressThumb += ($WebRequest.Images | Where-Object { $_.alt -eq "$actress" }).src
    }

    $movieActressObject = [pscustomobject]@{
        Name     = $movieActress
        ThumbUrl = $movieActressThumb
    }

    Write-Output $movieActressObject
}

function Get-R18MovieCoverUrl {
    param (
        [object]$WebRequest
    )

    $movieCoverUrl = $WebRequest.Images | Where-Object { $_.alt -like '*cover*' }
    $movieCoverUrl = $movieCoverUrl.src
    Write-Output $movieCoverUrl
}

function Get-R18MovieScreenshotUrl {
    param (
        [object]$WebRequest
    )

    $movieScreenshotUrl = @()
    $movieScreenshotUrl = $WebRequest.Images | Where-Object { $_.alt -like '*screenshot*' }
    $movieScreenshotUrl = $movieScreenshot.'data-src'
    Write-Output $movieScreenshotUrl
}
