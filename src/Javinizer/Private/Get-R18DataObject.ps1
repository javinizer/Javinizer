function Get-R18DataObject {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Position = 0)]
        [string]$Name,
        [Parameter(Position = 1)]
        [string]$Url,
        [string]$AltName
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $movieDataObject = @()
        $replaceHashTable = @{
            'S********l'                     = 'Schoolgirl'
            'S*********l'                    = 'School girl'
            'S**t'                           = 'Shit'
            'H*********n'                    = 'Humiliation'
            'G*******g'                      = 'Gang bang'
            'G******g'                       = 'Gangbang'
            'H*******m'                      = 'Hypnotism'
            'S*****t'                        = 'Student'
            'C***d'                          = 'Child'
            'D***king'                       = 'Drinking'
            'D***k'                          = 'Drunk'
            'V*****t'                        = 'Violent'
            'M******r'                       = 'Molester'
            'M****ter'                       = 'Molester'
            'Sch**lgirl'                     = 'Schoolgirl'
            'Sch**l'                         = 'School'
            '[Recommended For Smartphones] ' = ''
            'F***'                           = 'Fuck'
            'U**verse'                       = 'Universe'
            'V*****ed'                       = 'Violated'
            'V*****es'                       = 'Violates'
            'V*****e'                        = 'Violate'
            'Y********l'                     = 'Young Girl'
            'I****t'                         = 'Incest'
            'S***e'                          = 'Slave'
            'T*****e'                        = 'Torture'
            'R**e'                           = 'Rape'
            'R**ed'                          = 'Raped'
            'M****t'                         = 'Molest'
            'A*****ted'                      = 'Assaulted'
            'A*****t'                        = 'Assault'
            'D**gged'                        = 'Drugged'
            'D**g'                           = 'Drug'
            'SK**ls'                         = 'Skills'
            'B***d'                          = 'Blood'
        }
    }

    process {
        if ($Url) {
            $r18Url = $Url
        } else {
            $r18Url = Get-R18Url -Name $Name -AltName $AltName
        }

        if ($null -ne $r18Url) {
            try {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Performing GET on Uri [$r18Url]"
                $webRequest = Invoke-WebRequest -Uri $r18Url -Method Get -Verbose:$false
                Write-Debug "URL IS $r18Url"

                $movieDataObject = [pscustomobject]@{
                    Source          = 'r18'
                    Url             = $r18Url
                    ContentId       = Get-R18ContentId -WebRequest $webRequest
                    Id              = Get-R18Id -WebRequest $webRequest
                    Title           = Get-R18Title -WebRequest $webRequest
                    Description     = Get-R18Description -WebRequest $webRequest
                    Date            = Get-R18ReleaseDate -WebRequest $webRequest
                    Year            = Get-R18ReleaseYear -WebRequest $webRequest
                    Runtime         = Get-R18Runtime -WebRequest $webRequest
                    Director        = Get-R18Director -WebRequest $webRequest
                    Maker           = Get-R18Maker -WebRequest $webRequest
                    Label           = Get-R18Label -WebRequest $webRequest
                    Series          = Get-R18Series -WebRequest $webRequest
                    Rating          = Get-R18Rating -WebRequest $webRequest
                    Actress         = (Get-R18Actress -WebRequest $webRequest).Name
                    Genre           = Get-R18Genre -WebRequest $webRequest
                    ActressThumbUrl = (Get-R18Actress -WebRequest $webRequest).ThumbUrl
                    CoverUrl        = Get-R18CoverUrl -WebRequest $webRequest
                    ScreenshotUrl   = Get-R18ScreenshotUrl -WebRequest $webRequest
                    TrailerUrl      = Get-R18TrailerUrl -WebRequest $webRequest
                }
            } catch {
                throw $_
            }
        }

        Write-Debug "[$($MyInvocation.MyCommand.Name)] R18 data object:"
        $movieDataObject | Format-List | Out-String | Write-Debug
        Write-Output $movieDataObject
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

function Get-R18ContentId {
    param (
        [object]$WebRequest
    )

    process {
        $contentId = (((($WebRequest.Content -split '<dt>Content ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
        $contentId = Convert-HtmlCharacter -String $contentId
        #Write-Debug "Content ID is $contentId"

        if ($contentId -eq '----') {
            $contentId = $null
        }

        Write-Output $contentId
    }
}

function Get-R18Id {
    param (
        [object]$WebRequest
    )

    process {
        $id = (((($WebRequest.Content -split '<dt>DVD ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
        $id = Convert-HtmlCharacter -String $id
        #Write-Debug "Id is $id"

        if ($id -eq '----') {
            $id = $null
        }

        Write-Output $Id
    }
}

function Get-R18Title {
    param (
        [object]$WebRequest
    )

    process {
        $title = (($WebRequest.Content -split '<cite itemprop=\"name\">')[1] -split '<\/cite>')[0]
        $title = Convert-HtmlCharacter -String $title
        foreach ($string in $replaceHashTable.GetEnumerator()) {
            $title = $title -replace [regex]::Escape($string.Name), $string.Value
            $title = $title -replace '  ', ' '
        }
        #Write-Debug "Title is $title"
        Write-Output $Title
    }
}

function Get-R18Description {
    param (
        [object]$WebRequest
    )

    process {
        if ($WebRequest.Content -match '<h1>Product Description<\/h1>') {
            $description = ((($WebRequest.Content -split '<h1>Product Description<\/h1>')[1] -split '<p>')[1] -split '<\/p>')[0]
            $description = Convert-HtmlCharacter -String $description
        } else {
            $description = $null
        }

        Write-Output $description
    }
}

function Get-R18ReleaseDate {
    param (
        [object]$WebRequest
    )

    process {
        $releaseDate = (($WebRequest.Content -split '<dd itemprop=\"dateCreated\">')[1] -split '<br>')[0]
        $releaseDate = ($releaseDate.Trim() -replace '\.', '') -replace ',', ''
        $month, $day, $year = $releaseDate -split ' '

        # Convert full month names to abbreviated values due to non-standard naming conventions on R18 website
        if ($month -eq 'Jan') {
            $month = 1
        } elseif ($month -eq 'Feb') {
            $month = 2
        } elseif ($month -eq 'Mar') {
            $month = 3
        } elseif ($month -eq 'Apr') {
            $month = 4
        } elseif ($month -eq 'May') {
            $month = 5
        } elseif ($month -eq 'June') {
            $month = 6
        } elseif ($month -eq 'July') {
            $month = 7
        } elseif ($month -eq 'Aug') {
            $month = 8
        } elseif ($month -eq 'Sept') {
            $month = 9
        } elseif ($month -eq 'Oct') {
            $month = 10
        } elseif ($month -eq 'Nov') {
            $month = 11
        } elseif ($month -eq 'Dec') {
            $month = 12
        }

        # Convert the month name to a numeric value to conform with CMS datetime standards
        # $month = [array]::indexof([cultureinfo]::CurrentCulture.DateTimeFormat.AbbreviatedMonthNames, "$month") + 1
        $releaseDate = Get-Date -Year $year -Month $month -Day $day -Format "yyyy-MM-dd"
        #Write-Debug "ReleaseDate is $releaseDate"
        Write-Output $releaseDate
    }
}

function Get-R18ReleaseYear {
    param (
        [object]$WebRequest
    )

    process {
        $releaseYear = Get-R18ReleaseDate -WebRequest $WebRequest
        $releaseYear = ($releaseYear -split '-')[0]
        #Write-Debug "ReleaseYear is $releaseYear"
        Write-Output $releaseYear
    }
}

function Get-R18Runtime {
    param (
        [object]$WebRequest
    )

    process {
        $length = ((($WebRequest.Content -split '<dd itemprop="duration">')[1] -split '\.')[0]) -replace 'min', ''
        $length = Convert-HtmlCharacter -String $length
        #Write-Debug "Runtime is $length"
        Write-Output $length
    }
}

function Get-R18Director {
    param (
        [object]$WebRequest
    )

    process {
        $director = (($WebRequest.Content -split '<dd itemprop="director">')[1] -split '<br>')[0]
        $director = Convert-HtmlCharacter -String $director

        if ($director -eq '----') {
            $director = $null
        }
        #Write-Debug "Director is $director"
        Write-Output $director
    }
}

function Get-R18Maker {
    param (
        [object]$WebRequest
    )

    process {
        $maker = ((($WebRequest.Content -split '<dd itemprop="productionCompany" itemscope itemtype="http:\/\/schema.org\/Organization\">')[1] -split '<\/a>')[0] -split '>')[1]
        $maker = Convert-HtmlCharacter -String $maker
        #Write-Debug "Maker is $Maker"
        Write-Output $maker
    }
}

function Get-R18Label {
    param (
        [object]$WebRequest
    )

    process {
        $label = ((($WebRequest.Content -split '<dt>Label:<\/dt>')[1] -split '<br>')[0] -split '<dd>')[1]
        $label = Convert-HtmlCharacter -String $label

        if ($label -eq '----') {
            $label = $null
        }

        #Write-Debug "Label is $label"
        Write-Output $label
    }
}

function Get-R18Series {
    param (
        [object]$WebRequest
    )

    process {
        $series = (((($WebRequest.Content -split '<dt>Series:</dt>')[1] -split '<\/a><br>')[0] -split '<dd>')[1] -split '>')[1]
        $seriesUrl = ((($WebRequest.Content -split '<dt>Series:</dt>')[1] -split '">')[0] -split '"')[1]
        $series = Convert-HtmlCharacter -String $series
        $series = $series -replace '\n', ' '
        foreach ($string in $replaceHashTable.GetEnumerator()) {
            $series = $series -replace [regex]::Escape($string.Name), $string.Value
        }

        if ($series -like '*...') {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Performing GET on Uri [$seriesUrl]"
            $seriesSearch = Invoke-WebRequest -Uri $seriesUrl -Method Get -Verbose:$false
            $series = Convert-HtmlCharacter -String ((((($seriesSearch.Content -split '<div class="breadcrumbs">')[1]) -split '<\/span>')[0]) -split '<span>')[1]
            foreach ($string in $replaceHashTable.GetEnumerator()) {
                $series = $series -replace [regex]::Escape($string.Name), $string.Value
            }
        }

        if ($series -like '</dd*') {
            $series = $null
        }
        #Write-Debug "Series is $series"
        Write-Output $series
    }
}

function Get-R18Rating {
    param (
        [object]$WebRequest
    )

    process {
        $rating = ''
        Write-Output $rating
    }
}

function Get-R18Genre {
    param (
        [object]$WebRequest
    )

    begin {
        $genreArray = @()
    }

    process {
        $genreHtml = ((($WebRequest.Content -split '<div class="pop-list">')[1] -split '<\/div>')[0] -split '<\/a>') -split '>'

        foreach ($genre in $genreHtml) {
            $genre = $genre.trim()
            if ($genre -notmatch 'https:\/\/www\.r18\.com\/videos\/vod\/movies\/list\/id=(.*)' -and $genre -ne '') {
                $genre = Convert-HtmlCharacter -String $genre
                foreach ($string in $replaceHashTable.GetEnumerator()) {
                    $genre = $genre -replace [regex]::Escape($string.Name), $string.Value
                }
                $genreArray += $genre
            }
        }

        if ($genreArray.Count -eq 0) {
            $genreArray = $null
        }

        #Write-Debug "genres are $genreArray"
        Write-Output $genreArray
    }
}

function Get-R18Actress {
    param (
        [object]$WebRequest
    )

    begin {
        $movieActressHtml = @()
        $movieActressExtract = @()
        $movieActress = @()
        $movieActressThumb = @()
    }

    process {
        #$movieActressHtml = ($WebRequest.Content -split '<p><img')[1]
        $movieActressHtml = $WebRequest.Content -split '\n'
        foreach ($line in $movieActressHtml) {
            if ($line -match '<p><img alt') {
                $movieActressExtract += ($line).Trim()
            }
        }

        foreach ($actress in $movieActressExtract) {
            $movieActress += ((($actress -split 'alt="')[1] -split '"')[0]).Trim()
            $movieActressThumb += (($actress -split 'src="')[1] -split '"')[0]
        }

        if ($movieActress -eq '----') {
            $movieActress = $null
        }

        if ($movieActressThumb.Count -eq 0) {
            $movieActressThumb = $null
        }

        $movieActressObject = [pscustomobject]@{
            Name     = $movieActress
            ThumbUrl = $movieActressThumb
        }

        #Write-Debug "Actresses are $movieActressObject"
        Write-Output $movieActressObject
    }
}

function Get-R18CoverUrl {
    param (
        [object]$WebRequest
    )

    process {
        $coverUrl = (($WebRequest.Content -split '<div class="box01 mb10 detail-view detail-single-picture">')[1] -split '<\/div>')[0]
        $coverUrl = (($coverUrl -split 'src="')[1] -split '">')[0]
        #Write-Debug "Coverurl is $coverUrl"
        Write-Output $coverUrl
    }
}

function Get-R18ScreenshotUrl {
    param (
        [object]$WebRequest
    )

    begin {
        $screenshotUrl = @()
    }

    process {
        $screenshotHtml = (($WebRequest.Content -split '<ul class="js-owl-carousel clearfix">')[1] -split '<\/ul>')[0]
        $screenshotHtml = $screenshotHtml -split '<li>'
        foreach ($screenshot in $screenshotHtml) {
            $screenshot = $screenshot -replace '<p><img class="lazyOwl" ', ''
            $screenshot = (($screenshot -split 'data-src="')[1] -split '"')[0]
            if ($screenshot -ne '') {
                $screenshotUrl += $screenshot
            }
        }
        #Write-Debug "Screenshoturl is $screenshotUrl"
        Write-Output $screenshotUrl
    }
}

function Get-R18TrailerUrl {
    param (
        [object]$WebRequest
    )

    begin {
        $trailerUrl = @()
    }

    process {
        # $trailerHtml = $WebRequest.Content -split '\n'
        $trailerUrl += (($WebRequest.Content -split 'data-video-low="')[1] -split '"')[0]
        $trailerUrl += (($WebRequest.Content -split 'data-video-med="')[1] -split '"')[0]
        $trailerUrl += (($WebRequest.Content -split 'data-video-high="')[1] -split '"')[0]

        <# $trailerHtml = $trailerHtml | Select-String -Pattern 'https:\/\/awscc3001\.r18\.com\/litevideo\/freepv' -AllMatches

        foreach ($trailer in $trailerHtml) {
            $trailer = (($trailer -split '"')[1] -split '"')[0]
            $trailerUrl += $trailer
        } #>

        Write-Debug "Trailer Url is $trailerUrl"
        Write-Output $trailerUrl
    }
}
