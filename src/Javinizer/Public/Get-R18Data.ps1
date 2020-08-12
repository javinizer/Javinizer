function Get-R18Data {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url,
        [Parameter( Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('en', 'zh')]
        [String]$Language = 'en'
    )

    process {
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
            'R****g'                         = 'Raping'
            'M****t'                         = 'Molest'
            'A*****ted'                      = 'Assaulted'
            'A*****t'                        = 'Assault'
            'D**gged'                        = 'Drugged'
            'D**g'                           = 'Drug'
            'SK**ls'                         = 'Skills'
            'B***d'                          = 'Blood'
            'S******g'                       = 'Sleeping'
            'S***p'                          = 'Sleep'
            'P****hment'                     = 'Punishment'
            'P****h'                         = 'Punish'
            'StepB****************r'         = 'StepBrother'
            'K****p'                         = 'Kidnap'
            'S********n'                     = 'Subjugation'
            'K**ler'                         = 'Killer'
            'K**l'                           = 'Kill'
            'A***e'                          = 'Abuse'
        }

        try {
            Write-JLog -Level Debug -Message "Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -Verbose:$false
        } catch {
            Write-JLog -Level Error -Message "Error [GET] on URL [$Url]: $PSItem"
        }

        $movieDataObject = [pscustomobject]@{
            Source        = if ($Language -eq 'en') { 'r18' } elseif ($Language -eq 'zh') { 'r18zh' }
            Url           = $Url
            ContentId     = Get-R18ContentId -WebRequest $webRequest
            Id            = Get-R18Id -WebRequest $webRequest
            Title         = Get-R18Title -WebRequest $webRequest -Replace $replaceHashTable
            Description   = Get-R18Description -WebRequest $webRequest
            Date          = Get-R18ReleaseDate -WebRequest $webRequest
            Year          = Get-R18ReleaseYear -WebRequest $webRequest
            Runtime       = Get-R18Runtime -WebRequest $webRequest
            Director      = Get-R18Director -WebRequest $webRequest
            Maker         = Get-R18Maker -WebRequest $webRequest
            Label         = Get-R18Label -WebRequest $webRequest
            Series        = Get-R18Series -WebRequest $webRequest -Replace $replaceHashTable
            Rating        = Get-R18Rating -WebRequest $webRequest
            Actress       = Get-R18Actress -WebRequest $webRequest
            Genre         = Get-R18Genre -WebRequest $webRequest -Replace $replaceHashTable
            CoverUrl      = Get-R18CoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-R18ScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-R18TrailerUrl -WebRequest $webRequest
        }

        Write-JLog -Level Debug -Message "R18 data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}

function Get-R18ContentId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $contentId = (((($WebRequest.Content -split 'ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
        $contentId = Convert-HtmlCharacter -String $contentId

        if ($contentId -eq '----') {
            $contentId = $null
        }

        Write-Output $contentId
    }
}

function Get-R18Id {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $id = (((($WebRequest.Content -split '<dt>DVD ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
        $id = Convert-HtmlCharacter -String $id

        if ($id -eq '----') {
            $id = $null
        }

        Write-Output $Id
    }
}

function Get-R18Title {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest,
        [Parameter()]
        [object]$Replace
    )

    process {
        $title = (($WebRequest.Content -split '<cite itemprop=\"name\">')[1] -split '<\/cite>')[0]
        $title = Convert-HtmlCharacter -String $title
        if ($Replace) {
            foreach ($string in $Replace.GetEnumerator()) {
                $title = $title -replace [regex]::Escape($string.Name), $string.Value
                $title = $title -replace '  ', ' '
            }
        }

        Write-Output $Title
    }
}

function Get-R18Description {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
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
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $releaseDate = (($WebRequest.Content -split '<dd itemprop=\"dateCreated\">')[1] -split '<br>')[0]
        $releaseDate = ($releaseDate.Trim() -replace '\.', '') -replace ',', ''

        if ($releaseDate -match '/') {
            $year, $month, $day = $releaseDate -split '/'
        } else {
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
        }

        # Convert the month name to a numeric value to conform with CMS datetime standards
        # $month = [array]::indexof([cultureinfo]::CurrentCulture.DateTimeFormat.AbbreviatedMonthNames, "$month") + 1
        $releaseDate = Get-Date -Year $year -Month $month -Day $day -Format "yyyy-MM-dd"
        Write-Output $releaseDate
    }
}

function Get-R18ReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $releaseYear = Get-R18ReleaseDate -WebRequest $WebRequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-R18Runtime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $length = (((($WebRequest.Content -split '<dd itemprop="duration">')[1] -split '<br>')[0] -split 'min')[0] -split '分鐘')[0]
        $length = $length.Trim()
        Write-Output $length
    }
}

function Get-R18Director {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $director = (($WebRequest.Content -split '<dd itemprop="director">')[1] -split '<br>')[0]
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
        [object]$WebRequest
    )

    process {
        $maker = ((($WebRequest.Content -split '<dd itemprop="productionCompany" itemscope itemtype="http:\/\/schema.org\/Organization\">')[1] -split '<\/a>')[0] -split '>')[1]
        $maker = Convert-HtmlCharacter -String $maker

        if ($maker -eq '----') {
            $maker = $null
        }

        Write-Output $maker
    }
}

function Get-R18Label {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $label = (((($WebRequest.Content -split '<dd itemprop="productionCompany" itemscope itemtype="http:\/\/schema.org\/Organization\">')[1] -split '<\/dl>')[0] -split '<dd>')[1] -split '<br>')[0]
        $label = Convert-HtmlCharacter -String $label

        if ($label -eq '----') {
            $label = $null
        }

        Write-Output $label
    }
}

function Get-R18Series {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest,
        [Parameter()]
        [object]$Replace
    )

    process {
        $series = ((($WebRequest.Content -split 'type=series')[1] -split '<\/a><br>')[0] -split '>')[1]
        if ($null -ne $series) {
            $series = Convert-HtmlCharacter -String $series | Out-Null
            $series = $series -replace '\n', ' ' -replace "`t", ''

            $lang = ((($Webrequest.Content -split '\n')[1] -split '"')[1] -split '"')[0]
            $seriesUrl = ($WebRequest.links.href | Where-Object { $_ -like '*type=series*' }[0]) + '?lg=' + $lang

            if ($series -like '*...') {
                try {
                    Write-JLog -Level Debug -Message "Performing [GET] on URL [$seriesUrl]"
                    $seriesSearch = Invoke-WebRequest -Uri $seriesUrl -Method Get -Verbose:$false
                } catch {
                    Write-JLog -Level ERROR -Message "Error [GET] on URL [$seriesUrl]: $PSItem"
                }
                $series = (Convert-HtmlCharacter -String ((((($seriesSearch.Content -split '<div class="breadcrumbs">')[1]) -split '<\/span>')[0]) -split '<span>')[1]) -replace "`t", ''
            }

            if ($Replace) {
                foreach ($string in $Replace.GetEnumerator()) {
                    $series = $series -replace [regex]::Escape($string.Name), $string.Value
                }
            }

            if ($series -like '</dd*') {
                $series = $null
            }
        }

        Write-Output $series
    }
}

function Get-R18Rating {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $rating = ''
        Write-Output $rating
    }
}

function Get-R18Genre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest,
        [Parameter()]
        [object]$Replace
    )

    process {
        $genreArray = @()
        $genreHtml = ((($WebRequest.Content -split '<div class="pop-list">')[1] -split '<\/div>')[0] -split '<\/a>') -split '>'

        foreach ($genre in $genreHtml) {
            $genre = $genre.trim()
            if ($genre -notmatch 'https:\/\/www\.r18\.com\/videos\/vod\/movies\/list\/id=(.*)' -and $genre -ne '') {
                $genre = Convert-HtmlCharacter -String $genre
                if ($Replace) {
                    foreach ($string in $Replace.GetEnumerator()) {
                        $genre = $genre -replace [regex]::Escape($string.Name), $string.Value
                    }
                }
                $genreArray += $genre
            }
        }

        if ($genreArray.Count -eq 0) {
            $genreArray = $null
        }

        Write-Output $genreArray
    }
}

function Get-R18Actress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $movieActressObject = @()

        try {
            $movieActress = ($WebRequest.Content | Select-String -AllMatches -Pattern '<p><img alt="(.*)" src="https:\/\/pics\.r18\.com\/mono\/actjpgs\/(.*)" width="(?:.*)" height="(?:.*)"><\/p>').Matches
        } catch {
            return
        }

        foreach ($actress in $movieActress) {
            $actressName = $actress.Groups[1].Value
            Write-Debug "ActressName: $actressName"
            $thumbUrl = 'https://pics.r18.com/mono/actjpgs/' + ($actress.Groups[2].Value)
            Write-Debug "thumbUrl: $thumbUrl"
            if ($thumbUrl -like '*nowprinting*' -or $thumbUrl -like '*now_printing*') {
                $thumbUrl = $null
            }

            # Match if the name contains Japanese characters
            if ($actressName -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                $movieActressObject += [pscustomobject]@{
                    LastName     = $null
                    FirstName    = $null
                    JapaneseName = $actressName
                    ThumbUrl     = $thumbUrl
                }
            } else {
                $movieActressObject += [pscustomobject]@{
                    LastName     = ($actressName -split ' ')[1]
                    FirstName    = ($actressName -split ' ')[0]
                    JapaneseName = $null
                    ThumbUrl     = $thumbUrl
                }
            }
        }

        Write-Output $movieActressObject
    }
}

function Get-R18CoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $coverUrl = (($WebRequest.Content -split '<div class="box01 mb10 detail-view detail-single-picture">')[1] -split '<\/div>')[0]
        $coverUrl = (($coverUrl -split 'src="')[1] -split '">')[0]
        Write-Output $coverUrl
    }
}

function Get-R18ScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $screenshotUrl = @()
        $screenshotHtml = (($WebRequest.Content -split '<ul class="js-owl-carousel clearfix">')[1] -split '<\/ul>')[0]
        $screenshotHtml = $screenshotHtml -split '<li>'
        foreach ($screenshot in $screenshotHtml) {
            $screenshot = $screenshot -replace '<p><img class="lazyOwl" ', ''
            $screenshot = (($screenshot -split 'data-src="')[1] -split '"')[0]
            if ($screenshot -ne '') {
                $screenshotUrl += $screenshot
            }
        }

        Write-Output $screenshotUrl
    }
}

function Get-R18TrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $trailerUrl = @()

        if ($trailerUrl[0] -eq '') {
            $trailerUrl = $null
        } else {
            $trailerUrl = [pscustomobject]@{
                Low  = (($WebRequest.Content -split 'data-video-low="')[1] -split '"')[0]
                Med  = (($WebRequest.Content -split 'data-video-med="')[1] -split '"')[0]
                High = (($WebRequest.Content -split 'data-video-high="')[1] -split '"')[0]
            }
        }

        Write-Output $trailerUrl
    }
}
