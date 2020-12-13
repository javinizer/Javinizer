function Get-AventertainmentId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $id = ($Webrequest.Content | Select-String -Pattern '<span class="tag-title">(.*)<\/span>').Matches.Groups[1].Value
        } catch {
            return
        }

        if ($id -eq '') {
            $id = $null
        }

        Write-Output $Id
    }
}

function Get-AventertainmentTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $title = ($Webrequest.Content | Select-String -Pattern '<title>(.*)\s?(\| AVentertainments\.com)<\/title>').Matches.Groups[1].Value
        } catch {
            return
        }

        $title = Convert-HtmlCharacter -String $title

        if ($title -eq '') {
            $title = $null
        }

        Write-Output $Title
    }
}

function Get-AventertainmentReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $releaseDate = ($Webrequest.Content | Select-String -Pattern '<span class="value">(\d*\/\d*\/\d*)\s*<span class="text-warning">').Matches.Groups[1].Value
        } catch {
            return
        }

        $releaseDate = Get-Date $releaseDate -Format "yyyy-MM-dd"

        Write-Output $releaseDate
    }
}

function Get-AventertainmentReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseYear = Get-AventertainmentReleaseDate -WebRequest $Webrequest
        $releaseYear = ($releaseYear -split '-')[0]

        Write-Output $releaseYear
    }
}

function Get-AventertainmentRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $length = ($Webrequest.Content | Select-String -Pattern '<span class="value">(\d*:\d*:.*)<\/span>').Matches.Groups[1].Value
            [Int]$hours, [Int]$minutes, [Int]$seconds = $length -split ':'
            $length = ($hours * 60 + $minutes).ToString()
        } catch {
            try {
                $length = ($Webrequest.Content | Select-String -Pattern 'Apx\. (\d*) Min\.').Matches.Groups[1].Value
            } catch {
                return
            }
        }

        Write-Output $length
    }
}

function Get-AventertainmentMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $maker = ($Webrequest.Content | Select-String -Pattern '<a href=".*\/studio_products\.aspx\?StudioID=.*">(.*)<\/a><\/span>').Matches.Groups[1].Value
        } catch {
            try {
                $maker = ($Webrequest.Content | Select-String -Pattern '<a href=.*\/ppv_studioproducts.*>(.*)<\/a><\/span>').Matches.Groups[1].Value
            } catch {
                return
            }
        }

        $maker = Convert-HtmlCharacter -String $maker

        if ($maker -eq '') {
            $maker = $null
        }

        Write-Output $maker
    }
}

function Get-AventertainmentGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $genreArray = @()

        try {
            $genres = (((($Webrequest.Content -split '<span class="value-category">')[1]) -split '<\/span>')[0] | Select-String -Pattern '<a href=".*subdept_products.*>(.*)<\/a>' -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value }
        } catch {
            try {
                $genres = (((($Webrequest.Content -split '<span class="value-category">')[1]) -split '<\/span>')[0] | Select-String -Pattern '<a href=".*cat_id.*>(.*)<\/a>' -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value }
            } catch {
                return
            }
        }

        foreach ($genre in $genres) {
            $genre = Convert-HtmlCharacter -String $genre
            $genreArray += $genre
        }

        if ($genreArray.Count -eq 0) {
            $genreArray = $null
        }

        Write-Output $genreArray
    }
}

function Get-AventertainmentActress {
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
                try {
                    $actress = (($Webrequest.Content | Select-String -Pattern "<a href=.*\/ActressDetail\.aspx\?languageID=\d&actressname=(.*)>(.*)<\/a>").Matches.Value -split '<\/a>') | ForEach-Object { (($_ -split '>')[1]) }
                    $actress = $actress | Where-Object { $null -ne $_ -and $_ -ne '' } | ForEach-Object { ($_).Trim() }
                } catch {
                    try {
                        $actress = (($Webrequest.Content | Select-String -Pattern "<a href=.*\/ppv_ActressDetail\.aspx\?languageID=\d&actressname=(.*)>(.*)<\/a>").Matches.Value -split '<\/a>') | ForEach-Object { (($_ -split '>')[1]) }
                        $actress = $actress | Where-Object { $null -ne $_ -and $_ -ne '' } | ForEach-Object { ($_).Trim() }
                    } catch {
                        return
                    }
                }

                Write-Output $actress
            }
        }

        $movieActressObject = @()
        $enActressUrl = $Url -replace 'languageID=\d', 'languageID=1'
        $jaActressUrl = $Url -replace 'languageID=\d', 'languageID=2'

        if ($Url -match 'languageID=1') {
            $jaWebrequest = Invoke-WebRequest -Uri $jaActressUrl -Method Get -Verbose:$false
            $enActress = Get-Actress -Webrequest $Webrequest
            $jaActress = Get-Actress -Webrequest $jaWebrequest
        } else {
            $enWebrequest = Invoke-WebRequest -Uri $enActressUrl -Method Get -Verbose:$false
            $enActress = Get-Actress -Webrequest $enWebrequest
            $jaActress = Get-Actress -Webrequest $Webrequest
        }

        for ($x = 0; $x -lt $enActress.Count; $x++) {
            if ($enActress.Count -eq 1) {
                if ($jaActress -notmatch '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                    $jaActress = $null
                }
                $movieActressObject += [PSCustomObject]@{
                    LastName     = ($enActress -split ' ')[1] -replace '\\', ''
                    FirstName    = ($enActress -split ' ')[0] -replace '\\', ''
                    JapaneseName = $jaActress
                    ThumbUrl     = $null
                }
            } else {
                if ($jaActress[$x] -notmatch '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                    $jaActress[$x] = $null
                }
                $movieActressObject += [PSCustomObject]@{
                    LastName     = ($enActress[$x] -split ' ')[1] -replace '\\', ''
                    FirstName    = ($enActress[$x] -split ' ')[0] -replace '\\', ''
                    JapaneseName = $jaActress[$x]
                    ThumbUrl     = $null
                }
            }
        }

        if ($movieActressObject.Count -eq 0) {
            $movieActressObject = $null
        }

        Write-Output $movieActressObject
    }
}

function Get-AventertainmentCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $coverUrl = ($Webrequest.Content | Select-String -Pattern 'href="(.*\/bigcover\/.*\.jpg)" role="button">(ジャケット画像|Cover\sJacket)<\/a>').Matches.Groups[1].Value
        } catch {
            try {
                $coverUrl = ($Webrequest.Content | Select-String -Pattern "<a class='lightbox' href='(.*\/vodimages\/gallery\/large\/.*\.jpg)'>").Matches.Groups[1].Value
            } catch {
                return
            }
        }

        Write-Output $coverUrl
    }
}

function Get-AventertainmentScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $screenshotUrl = ($Webrequest.Content | Select-String -Pattern "<a class='lightbox' href='(.*\/vodimages\/screenshot\/large\/.*\.jpg)'>").Matches.Groups[1].Value
            $screenshotUrl = (($screenshotUrl -split '<img src=' -split 'href=') | Select-String -Pattern "'(.*\/vodimages\/screenshot\/large\/.*\.jpg)" -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value }
        } catch {
            return
        }

        Write-Output $screenshotUrl
    }
}

function Get-AventertainmentTrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        Write-Output $trailerUrl
    }
}
