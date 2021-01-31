function Get-JavdbId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $id = (($Webrequest.Content | Select-String -Pattern '<title>.*<\/title>').Matches.Groups[0].Value -split ' ')[1]
        } catch {
            return
        }

        Write-Output $id
    }
}

function Get-JavdbTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )
    process {
        try {
            $title = (($Webrequest.Content | Select-String -Pattern '<title>.*<\/title>').Matches.Groups[0].Value -split ' ')[2]
        } catch {
            return
        }

        $title = Convert-HtmlCharacter -String $title
        Write-Output $title
    }
}

function Get-JavdbReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $releaseDate = ($Webrequest.Content | Select-String -Pattern '<span class="value">(\d{4}-\d{2}-\d{2})<\/span>').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $releaseDate
    }
}

function Get-JavdbReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseYear = Get-JavdbReleaseDate -WebRequest $Webrequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-JavdbRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $length = ($Webrequest.Content | Select-String -Pattern '<span class="value">(\d*) (分鍾|minute\(s\))<\/span>').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $length
    }
}

function Get-JavdbDirector {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $director = ($Webrequest.Content | Select-String -Pattern '<a href="\/directors\/.*">(.*)<\/a>').Matches.Groups[1].Value
        } catch {
            return
        }

        $director = Convert-HtmlCharacter -String $director
        Write-Output $director
    }
}

function Get-JavdbMaker {
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

function Get-JavdbRating {
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

function Get-JavdbGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $genres = @()
        try {
            $rawGenres = (($Webrequest.Content | Select-String -Pattern '<a href="\/tags\?.*">(.*)<\/a>').Matches.Groups[0].Value) -split '<\/a>'
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

function Get-JavdbActress {
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
                    $thumbUrl = ((Invoke-WebRequest -Uri "https://javdb.com/actors/$($actress.Id)" -Verbose:$false).Content | Select-String -Pattern '<span class="avatar" style="background-image: url\((.*)\)"><\/span>').Matches.Groups[1].Value
                } catch {
                    return
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

function Get-JavdbCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $coverUrl = ($Webrequest.Content | Select-String -Pattern '<img src="(.*)" class="video-cover"').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $coverUrl
    }
}

function Get-JavdbScreenshotUrl {
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

function Get-JavdbTrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $trailerUrl = "https:" + ($Webrequest.Content | Select-String -Pattern 'src="(.*)" type="video\/mp4"').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $trailerUrl
    }
}
