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
                $html = $webRequest.Content
            } catch {
                throw $_
            }

            $movieDataObject = [pscustomobject]@{
                contentId     = Get-R18ContentId -Html $html
                movieId       = Get-R18MovieId -Html $html
                movieTitle    = Get-R18MovieTitle -Html $html
                movieDate     = Get-R18MovieReleaseDate -Html $html
                movieYear     = Get-R18MovieReleaseYear -Html $html
                movieLength   = Get-R18MovieLength -Html $html
                movieDirector = Get-R18MovieDirector -Html $html
                movieMaker    = Get-R18MovieMaker -Html $html
                movieLabel    = Get-R18MovieLabel -Html $html
                movieSeries   = Get-R18MovieSeries -Html $html
                movieRating   = Get-R18MovieRating -Html $html
                movieActress  = Get-R18MovieActress -Html $html
                movieGenre    = Get-R18MovieGenre -Html $html
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
        [string]$Html
    )

    $movieContentId = (((($Html -split '<dt>Content ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
    $movieContentId = Convert-HTMLCharacter -String $movieContentId
    Write-Output $movieContentId
}

function Get-R18MovieId {
    param (
        [string]$Html
    )

    $movieId = (((($Html -split '<dt>DVD ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
    $movieId = Convert-HTMLCharacter -String $movieId
    Write-Output $movieId
}

function Get-R18MovieTitle {
    param (
        [string]$Html
    )

    $movieTitle = (($Html -split '<cite itemprop=\"name\">')[1] -split '<\/cite>')[0]
    $movieTitle = Convert-HTMLCharacter -String $movieTitle
    Write-Output $movieTitle
}

function Get-R18MovieReleaseDate {
    param (
        [string]$Html
    )

    $movieReleaseDate = (($Html -split '<dd itemprop=\"dateCreated\">')[1] -split '<br>')[0]
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
        [string]$Html
    )

    $movieReleaseYear = Get-R18MovieReleaseDate -Html $Html
    $movieReleaseYear = ($movieReleaseYear -split '-')[0]
    Write-Output $movieReleaseYear
}

function Get-R18MovieLength {
    param (
        [string]$Html
    )

    $movieLength = ((($Html -split '<dd itemprop="duration">')[1] -split '\.')[0]) -replace 'min', ''
    $movieLength = Convert-HTMLCharacter -String $movieLength
    Write-Output $movieLength
}

function Get-R18MovieDirector {
    param (
        [string]$Html
    )

    $movieDirector = (($Html -split '<dd itemprop="director">')[1] -split '<br>')[0]
    $movieDirector = Convert-HTMLCharacter -String $movieDirector

    if ($movieDirector -eq '----') {
        $movieDirector = $null
    }

    Write-Output $movieDirector
}

function Get-R18MovieMaker {
    param (
        [string]$Html
    )

    $movieMaker = ((($Html -split '<dd itemprop="productionCompany" itemscope itemtype="http:\/\/schema.org\/Organization\">')[1] -split '<\/a>')[0] -split '>')[1]
    $movieMaker = Convert-HTMLCharacter -String $movieMaker
    Write-Output $movieMaker
}

function Get-R18MovieLabel {
    param (
        [string]$Html
    )

    $movieLabel = ((($Html -split '<dt>Label:<\/dt>')[1] -split '<br>')[0] -split '<dd>')[1]
    $movieLabel = Convert-HTMLCharacter -String $movieLabel
    Write-Output $movieLabel
}

function Get-R18MovieSeries {
    param (
        [string]$Html
    )

    $movieSeries = (((($Html -split '<dt>Series:</dt>')[1] -split '<\/a><br>')[0] -split '<dd>')[1] -split '>')[1]
    $movieSeries = Convert-HTMLCharacter -String $movieSeries
    Write-Output $movieSeries
}

function Get-R18MovieRating {
    param (
        [string]$Html
    )

    $movieRating = ''
    Write-Output $movieRating
}

function Get-R18MovieGenre {
    param (
        [string]$Html
    )

    $movieGenre = @()
    $movieGenreHtml = ((($Html -split '<div class="pop-list">')[1] -split '<\/div>')[0] -split '<\/a>') -split '>'

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
        [string]$Html
    )

    $movieActress = @()
    $movieActressHtml = (($Html -split '<div itemprop="actors" data-type="actress-list" class="pop-list">')[1] -split '<div class="product-categories-list product-box-list">')[0]
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

    Write-Output $movieActress
}
