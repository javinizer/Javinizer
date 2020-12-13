function Get-JavlibraryId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $id = ((($Webrequest.Content -split '<div id="video_id" class="item">')[1] -split '<\/td>')[1] -split '>')[1]
        Write-Output $id
    }
}

function Get-JavlibraryAjaxId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $ajaxId = ((($Webrequest | ForEach-Object { $_ -split '\n' } |
                        Select-String 'var \$ajaxid = "(.*)";').Matches.Groups[1].Value))
        } catch {
            return
        }

        Write-Output $ajaxId
    }
}

function Get-JavlibraryTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )
    process {
        $fullTitle = ((($Webrequest.Content -split '<title>')[1] -split ' - JAVLibrary<\/title>')[0] -split ' ')
        $joinedTitle = $fullTitle[1..$fullTitle.length] -join ' '
        $title = Convert-HtmlCharacter -String $joinedTitle
        Write-Output $title
    }
}

function Get-JavlibraryReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseDate = ((($Webrequest.Content -split '<div id="video_date" class="item">')[1] -split '<\/td>')[1] -split '>')[1]
        Write-Output $releaseDate
    }
}

function Get-JavlibraryReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseYear = Get-JavlibraryReleaseDate -WebRequest $Webrequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-JavlibraryRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $length = ((($Webrequest.Content -split '<div id="video_length" class="item">')[1] -split '<\/span>')[0] -split '"text">')[1]
        Write-Output $length
    }
}

function Get-JavlibraryDirector {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $director = ((($Webrequest.Content -split '<div id="video_director" class="item">')[1]) -split '<\/td>')[1]
        if ($director -match '<\/a>') {
            $director = (($director -split 'rel="tag">')[1] -split '<\/a')[0]
        } else {
            $director = $null
        }

        $director = Convert-HtmlCharacter -String $director
        Write-Output $director
    }
}

function Get-JavlibraryMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $maker = (((($Webrequest.Content -split '<div id="video_maker" class="item">')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-JavlibraryLabel {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $label = (((($Webrequest.Content -split '<div id="video_label" class="item">')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
        $label = Convert-HtmlCharacter -String $label
        Write-Output $label
    }
}

function Get-JavlibraryRating {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $rating = (((($Webrequest.Content -split '<div id="video_review" class="item">')[1]) -split '<\/span>')[0] -split '<span class="score">')[1]
        $rating = ($rating -replace '\(', '') -replace '\)', ''

        if ($rating -eq 0) {
            $ratingObject = $null
        } else {
            $ratingObject = [PSCustomObject]@{
                Rating = $rating
                Votes  = $null
            }
        }

        Write-Output $ratingObject
    }
}

function Get-JavlibraryGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $genre = @()
        $genreHtml = ($Webrequest.Content -split '<div id="video_genres" class="item">')[1]
        $genreHtml = ($genreHtml -split '<\/td>')[1]
        $genreHtml = $genreHtml -split 'rel="category tag">'

        foreach ($genres in $genreHtml[1..($genreHtml.Length - 1)]) {
            $genres = ($genres -split '<')[0]
            $genres = Convert-HtmlCharacter -String $genres
            $genre += $genres
        }

        if ($genre.Count -eq 0) {
            $genre = $null
        }

        Write-Output $genre
    }
}

function Get-JavlibraryActress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [String]$JavlibraryBaseUrl = 'http://www.javlibrary.com',

        [Parameter()]
        [PSObject]$Session
    )

    process {
        $movieActressObject = @()
        $movieActress = @()

        try {
            $movieActress = ($Webrequest.Content | Select-String -Pattern '<a href="vl_star\.php\?s=(?:.*)" rel="tag">(.*)<\/a><\/span>').Matches.Groups[0].Value `
                -split '<span class="star">' | ForEach-Object { ($_ | Select-String -Pattern '<a href="vl_star\.php\?s=(.*)" rel="tag">(.*)<\/a><\/span>').Matches }
        } catch {
            return
        }

        foreach ($actress in $movieActress) {
            $engActressUrl = "$JavlibraryBaseUrl/en/vl_star.php?s=$($actress.Groups[1].Value)"
            $jaActressUrl = "$JavlibraryBaseUrl/ja/vl_star.php?s=$($actress.Groups[1].Value)"
            $actressName = $actress.Groups[2].Value
            if ($actress -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                try {
                    $engActressName = ((Invoke-WebRequest -Uri $engActressUrl -WebSession:$Session -UserAgent:$Session.UserAgent -Verbose:$false).Content | Select-String -Pattern '<div class="boxtitle">Videos starring (.*)<\/div>').Matches.Groups[1].Value
                } catch {
                    $engActressName = $null
                }

                $nameParts = ($engActressName -split ' ').Count
                if ($nameParts -eq 1) {
                    $lastName = $null
                    $firstName = $engActressName
                } else {
                    $lastName = ($engActressName -split ' ')[0]
                    $firstName = ($engActressName -split ' ')[1]
                }

                $movieActressObject += [PSCustomObject]@{
                    LastName     = $lastName
                    FirstName    = $firstName
                    JapaneseName = $actressName
                    ThumbUrl     = $null
                }
            } else {
                try {
                    $jaActressName = ((Invoke-WebRequest -Uri $jaActressUrl -WebSession:$Session -UserAgent:$Session.UserAgent -Verbose:$false).Content | Select-String -Pattern '<div class="boxtitle">(.*)のビデオ<\/div>').Matches.Groups[1].Value
                } catch {
                    $jaActressName = $null
                }

                $nameParts = ($ActressName -split ' ').Count
                if ($nameParts -eq 1) {
                    $lastName = $null
                    $firstName = $actressName
                } else {
                    $lastName = ($actressName -split ' ')[0]
                    $firstName = ($actressName -split ' ')[1]
                }

                $movieActressObject += [PSCustomObject]@{
                    LastName     = $lastName
                    FirstName    = $firstName
                    JapaneseName = $jaActressName
                    ThumbUrl     = $null
                }
            }
        }

        Write-Output $movieActressObject
    }
}

function Get-JavlibraryCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $coverUrl = (($Webrequest.Content -split '<img id="video_jacket_img" src="')[1] -split '"')[0]
        if ($coverUrl -like '*pixhost*') {
            try {
                $testConnection = Invoke-WebRequest -Uri "http:$coverUrl" -ErrorAction 'SilentlyContinue' -Verbose:$false
            } catch {
                $coverUrl = $null
            }
            if ($null -ne $testConnection) {
                $coverUrl = 'http:' + $coverUrl
            }
        } else {
            $coverUrl = 'https:' + $coverUrl
        }
        Write-Output $coverUrl
    }
}

function Get-JavlibraryScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $screenshotUrl = @()
        $screenshotHtml = (($Webrequest.Content -split '<div class="previewthumbs" style="display:block; margin:10px auto;">')[1] -split '<\/div>')[0]
        $screenshotHtml = $screenshotHtml -split '<img src="'
        foreach ($screenshot in $screenshotHtml) {
            if ($screenshot -ne '') {
                $screenshot = 'https:' + ($screenshot -split '"')[0]
                $screenshot = $screenshot -replace '-', 'jp-'
                if ($screenshot -match 'pics.dmm') {
                    $screenshotUrl += $screenshot
                }
            }
        }

        Write-Output $screenshotUrl
    }
}
