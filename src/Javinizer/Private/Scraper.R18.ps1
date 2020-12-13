function Get-R18ContentId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $contentId = (((($Webrequest.Content -split 'ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
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
        [Object]$Webrequest
    )

    process {
        $id = (((($Webrequest.Content -split '<dt>DVD ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
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
        [Object]$Webrequest,

        [Parameter()]
        [Object]$Replace
    )

    process {
        $title = (($Webrequest.Content -split '<cite itemprop=\"name\">')[1] -split '<\/cite>')[0]
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
        if ($Webrequest.Content -match '<h1>Product Description<\/h1>') {
            $description = ((($Webrequest.Content -split '<h1>Product Description<\/h1>')[1] -split '<p>')[1] -split '<\/p>')[0]
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
        [Object]$Webrequest
    )

    process {
        $releaseDate = (($Webrequest.Content -split '<dd itemprop=\"dateCreated\">')[1] -split '<br>')[0]
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
        $length = (((($Webrequest.Content -split '<dd itemprop="duration">')[1] -split '<br>')[0] -split 'min')[0] -split '分鐘')[0]
        $length = $length.Trim()
        Write-Output $length
    }
}

function Get-R18Director {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $director = (($Webrequest.Content -split '<dd itemprop="director">')[1] -split '<br>')[0]
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
        $maker = ((($Webrequest.Content -split '<dd itemprop="productionCompany" itemscope itemtype="http:\/\/schema.org\/Organization\">')[1] -split '<\/a>')[0] -split '>')[1]
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
            $label = ((($Webrequest.Content -split '<dt>(Label:|廠牌:)<\/dt>')[2] -split '</dd>')[0] -replace '<[^>]*>' , '').Trim()
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
        $series = ((($Webrequest.Content -split 'type=series')[1] -split '<\/a><br>')[0] -split '>')[1]
        if ($null -ne $series) {
            $series = Convert-HtmlCharacter -String $series
            $series = $series -replace '\n', ' ' -replace "`t", ''

            $lang = ((($Webrequest.Content -split '\n')[1] -split '"')[1] -split '"')[0]
            $seriesUrl = ($Webrequest.links.href | Where-Object { $_ -like '*type=series*' }[0]) + '?lg=' + $lang

            if ($series -like '*...') {
                try {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "Performing [GET] on URL [$seriesUrl]"
                    $seriesSearch = Invoke-WebRequest -Uri $seriesUrl -Method Get -Verbose:$false
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level ERROR -Message "Error [GET] on URL [$seriesUrl]: $PSItem"
                }
                $series = (Convert-HtmlCharacter -String ((((($seriesSearch.Content -split '<div class="breadcrumbs">')[1]) -split '<\/span>')[0]) -split '<span>')[1]) -replace "`t", ''
            }

            if ($Replace) {
                foreach ($string in $Replace.GetEnumerator()) {
                    $series = $series -replace [regex]::Escape($string.Original), $string.Replacement
                }
            }

            if ($series -like '</dd*') {
                $series = $null
            }
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
        $genreHtml = ((($Webrequest.Content -split '<div class="pop-list">')[1] -split '<\/div>')[0] -split '<\/a>') -split '>'

        foreach ($genre in $genreHtml) {
            $genre = $genre.trim()
            if ($genre -notmatch 'https:\/\/www\.r18\.com\/videos\/vod\/(movies|amateur)\/list\/id=(.*)' -and $genre -ne '') {
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

        [Parameter()]
        [String]$Url
    )

    process {
        function Get-Actress {
            param (
                [Parameter()]
                [Object]$Webrequest
            )

            process {
                $thumbUrl = @()
                $pattern = '<a href="https:\/\/www\.r18\.com\/videos\/vod\/movies\/list\/id=(\d*)\/(?:.*)\/">\n.*<p><img alt="(.*)" src="https:\/\/pics\.r18\.com\/mono\/actjpgs\/(.*)" width="(?:.*)" height="(?:.*)"><\/p>'
                try {
                    $movieActress = ($Webrequest.Content | Select-String -Pattern $pattern -AllMatches).Matches | ForEach-Object { ($_.Groups[2].Value).Trim() }
                    $thumbs = ($Webrequest.Content | Select-String -Pattern $pattern -AllMatches).Matches | ForEach-Object { $_.Groups[3].Value }
                } catch {
                    return
                }

                foreach ($thumb in $thumbs) {
                    $thumbUrl += 'https://pics.r18.com/mono/actjpgs/' + $thumb
                }

                $actresses = [PSCustomObject]@{
                    Actress = $movieActress
                    Thumbs  = $thumbUrl
                }

                Write-Output $actresses
            }
        }

        $movieActressObject = @()
        if ($Url -notmatch 'lg=(en|zh)') {
            $Url += '&?lg=en'
        }

        $enActressUrl = $Url -replace 'lg=(en|zh)', 'lg=en'
        $jaActressUrl = $Url -replace 'lg=(en|zh)', 'lg=zh'

        if ($Url -match 'lg=en') {
            # Create zh language cookie
            $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'lg'
            $cookie.Value = 'zh'
            $cookie.Domain = '.r18.com'
            $session.Cookies.Add($cookie)

            $jaWebrequest = Invoke-WebRequest -Uri $jaActressUrl -Method Get -WebSession $session -Verbose:$false
            $enActress = Get-Actress -Webrequest $Webrequest
            $jaActress = Get-Actress -Webrequest $jaWebrequest
        } else {
            # Create en language cookie
            $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            $cookie = New-Object System.Net.Cookie
            $cookie.Name = 'lg'
            $cookie.Value = 'en'
            $cookie.Domain = '.r18.com'
            $session.Cookies.Add($cookie)

            $enWebrequest = Invoke-WebRequest -Uri $enActressUrl -Method Get -WebSession $session -Verbose:$false
            $enActress = Get-Actress -Webrequest $enWebrequest
            $jaActress = Get-Actress -Webrequest $Webrequest
        }

        for ($x = 0; $x -lt $enActress.Actress.Count; $x++) {
            if ($enActress.Actress.Count -eq 1) {
                $thumbUrl = $enActress.Thumbs
                if ($enActress.Thumbs -like '*nowprinting*' -or $enActress.Thumbs -like '*now_printing*') {
                    $thumbUrl = $null
                }

                if ($jaActress.Actress -notmatch '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                    $jaActress.Actress = $null
                }

                $movieActressObject += [PSCustomObject]@{
                    LastName     = ($enActress.Actress -split ' ')[1] -replace '\\', ''
                    FirstName    = ($enActress.Actress -split ' ')[0] -replace '\\', ''
                    JapaneseName = $jaActress.Actress -replace '（.*）', '' -replace '&amp;', '&'
                    ThumbUrl     = $thumbUrl
                }
            } else {
                $thumbUrl = $enActress.Thumbs[$x]
                if ($enActress.Thumbs[$x] -like '*nowprinting*' -or $enActress.Thumbs[$x] -like '*now_printing*') {
                    $thumbUrl = $null
                }

                if ($jaActress.Actress[$x] -notmatch '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                    $jaActress.Actress[$x] = $null
                }
                $movieActressObject += [PSCustomObject]@{
                    LastName     = ($enActress.Actress[$x] -split ' ')[1] -replace '\\', ''
                    FirstName    = ($enActress.Actress[$x] -split ' ')[0] -replace '\\', ''
                    JapaneseName = $jaActress.Actress[$x] -replace '（.*）', '' -replace '&amp;', '&'
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
        [Object]$Webrequest
    )

    process {
        $coverUrl = (($Webrequest.Content -split '<div class="box01 mb10 detail-view detail-single-picture">')[1] -split '<\/div>')[0]
        $coverUrl = (($coverUrl -split 'src="')[1] -split '">')[0]
        Write-Output $coverUrl
    }
}

function Get-R18ScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $screenshotUrl = @()
        $screenshotHtml = (($Webrequest.Content -split '<ul class="js-owl-carousel clearfix">')[1] -split '<\/ul>')[0]
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
        [Object]$Webrequest
    )

    process {
        $trailerUrl = @()

        if ($trailerUrl[0] -eq '') {
            $trailerUrl = $null
        } else {
            $trailerUrlObject = [PSCustomObject]@{
                Low  = (($Webrequest.Content -split 'data-video-low="')[1] -split '"')[0]
                Med  = (($Webrequest.Content -split 'data-video-med="')[1] -split '"')[0]
                High = (($Webrequest.Content -split 'data-video-high="')[1] -split '"')[0]
            }
        }

        if ($trailerUrlObject.High) {
            $trailerUrl = $trailerUrlObject.High
        } elseif ($trailerUrlObject.Med) {
            $trailerUrl = $trailerUrlObject.Med
        } else {
            $trailerUrl = $trailerUrlObject.Low
        }

        Write-Output $trailerUrl
    }
}
