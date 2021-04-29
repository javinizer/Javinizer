
# TODO: Nothing works in here yet !!

function Get-TokyoHotInfo {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    $infoWrapper = ((($Webrequest.Content -split '<dl class="info">')[1] -split '<\/dl>')[0]) -split '<dt>.*<\/dt>'
    Write-Output $infoWrapper
}

function Get-TokyoHotId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    # TokyoHot HTML src
    # for - https://www.tokyo-hot.com/product/5484/
    # <meta name="keywords" content="黒田やよい,n0487">

    process {
        try {
            $info = Get-TokyoHotInfo -Webrequest $Webrequest
            $id = ($info[8] | Select-String -Pattern '<dd>(.*)<\/dd>').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $id
    }
}

function Get-TokyoHotTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )
    process {
        try {
            $title = ((($Webrequest.Content | Select-String -Pattern '<title>(.*)<\/title>').Matches.Groups[1].Value -split '\|')[0]).Trim()
        } catch {
            return
        }

        Write-Output $title
    }
}

function Get-TokyoHotReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $info = Get-TokyoHotInfo -Webrequest $Webrequest
            $releaseDate = ($info[6] | Select-String -Pattern '<dd>(.*)<\/dd>').Matches.Groups[1].Value -replace '/', '-'
        } catch {
            return
        }

        Write-Output $releaseDate
    }
}

function Get-TokyoHotReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseYear = Get-TokyoHotReleaseDate -WebRequest $Webrequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-TokyoHotRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $info = Get-TokyoHotInfo -Webrequest $Webrequest
        $rawLength = ($info[7] | Select-String -Pattern '<dd>(.*)<\/dd>').Matches.Groups[1].Value
        $hours, $minutes, $seconds = $rawLength -split ':'
        $length = (New-TimeSpan -Hours $hours -Minutes $minutes -Seconds $seconds).TotalMinutes

        Write-Output $length
    }
}

function Get-TokyoHotMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $maker = ($Webrequest.Content | Select-String -Pattern '<a href="\/makers\/.*">(.*)<\/a>').Matches.Groups[1].Value
        } catch {
            return
        }

        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-TokyoHotSeries {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $series = ($Webrequest.Content | Select-String -Pattern '<a href=".*\/series\/.*">(.*)<\/a>').Matches.Groups[1].Value
        } catch {
            return
        }

        $series = Convert-HtmlCharacter -String $series
        Write-Output $series
    }
}

function Get-TokyoHotRating {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $ratingLine = ($Webrequest.Content | Select-String -Pattern '(\d*\.\d*)分?, \D*(\d*)\D*')
            $rating = $ratingLine.Matches.Groups[1].Value
            $votes = $ratingLine.Matches.Groups[2].Value
        } catch {
            return
        }

        if ($rating -eq 0) {
            $ratingObject = $null
        } else {
            $ratingObject = [PSCustomObject]@{
                Rating = [math]::round([double]$rating * 2, 2)
                Votes  = $votes
            }
        }

        Write-Output $ratingObject
    }
}

function Get-TokyoHotGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $genres = @()
        try {
            $rawGenres = (($Webrequest.Content | Select-String -Pattern '<a href="(?:https:\/\/TokyoHot\.com)?\/tags\/?.*">(.*)<\/a>').Matches.Groups[0].Value) -split '<\/a>'
            $rawGenres = ($rawGenres | Select-String -Pattern '>(.*)' -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value }
        } catch {
            return
        }

        foreach ($genre in $rawGenres) {
            $genres += Convert-HtmlCharacter -String $genre
        }

        if ($genres.Count -eq 0) {
            $genres = $null
        }

        Write-Output $genres
    }
}

function Get-TokyoHotActress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $actressObject = @()
            $actress = (($Webrequest.Content | Select-String -Pattern '<a href="\/actors\/(.*)">(.*)<\/a>').Matches.Groups[0].Value) -split '<\/a>'
            ($actress | Select-String -Pattern '\/actors\/(.*)">(.*)' -AllMatches).Matches | ForEach-Object { if ($_ -ne '') {
                    $actressObject += [PSCustomObject]@{
                        Id       = $_.Groups[1].Value
                        Name     = $_.Groups[2].Value
                        ThumbUrl = $null
                    }
                }
            }

            $index = 0
            foreach ($actress in $actressObject) {
                $thumbUrl = $null
                try {
                    $thumbUrl = ((Invoke-WebRequest -Uri "https://TokyoHot.com/actors/$($actress.Id)" -Verbose:$false).Content | Select-String -Pattern '<span class="avatar" style="background-image: url\((.*)\)"><\/span>').Matches.Groups[1].Value
                } catch {
                    # Do nothing
                }

                if ($thumbUrl) {
                    $actressObject[$index].ThumbUrl = $thumbUrl
                }

                $index++
            }
        } catch {
            return
        }

        $movieActressObject = @()
        foreach ($actress in $actressObject) {
            $movieActressObject += [PSCustomObject]@{
                LastName     = $null
                FirstName    = $null
                JapaneseName = $actress.Name
                ThumbUrl     = $actress.ThumbUrl
            }
        }

        Write-Output $movieActressObject
    }
}

function Get-TokyoHotCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    # HTML src
    # <li class="package">
    # <a href="https://my.cdn.tokyo-hot.com/media/5484/jacket/n0487.jpg"><img src="https://my.cdn.tokyo-hot.com/static/images/package.png" alt="Jacket" width="48" height="43"><br>Jacket</a>
    # <a href="https://my.cdn.tokyo-hot.com/media/5484/package/_v.jpg"></a>
    # <a href="https://my.cdn.tokyo-hot.com/media/5484/package/_vb.jpg"></a>
    # </li>

    process {
        try {
            $coverUrl = ($Webrequest.Content | Select-String -Pattern '<img src="(.*)" class="video-cover"').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $coverUrl
    }
}

function Get-TokyoHotScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $screenshotUrl = @()
            $screenshotUrl = ($Webrequest.Content | Select-String -Pattern '<a class="tile-item" href="(.*)" data-fancybox="gallery"' -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value }
        } catch {
            return
        }

        Write-Output $screenshotUrl
    }
}

function Get-TokyoHotTrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $rawTrailerUrl = ($Webrequest.Content | Select-String -Pattern 'src="(.*)" type="video\/mp4"').Matches.Groups[1].Value
            if ($rawTrailerUrl -notlike "https*" -and $rawTrailerUrl -ne '') {
                $trailerUrl = 'https:' + $rawtrailerUrl
            } else {
                $trailerUrl = $rawTrailerUrl
            }
        } catch {
            return
        }

        Write-Output $trailerUrl
    }
}

function Get-TokyoHotDescription {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $description = ($Webrequest.Content | Select-String -Pattern '<div class="sentence">(.*)<\/div>').Matches.Groups[1].Value
        } catch {
            $description = $null
        }

        Write-Output $description
    }
}
