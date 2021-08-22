function Get-DmmContentId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Url
    )

    process {
        try {
            $contentId = (($Url | Select-String -Pattern 'cid=(.*)(\/)?').Matches.Groups[1].Value -split '/')[0]
        } catch {
            return
        }
        Write-Output $contentId
    }
}

function Get-DmmId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Url
    )

    process {
        try {
            # Expects ###ID##### or ID#####
            $contentId = Get-DmmContentId -Url $Url

            try {
                $m = ($contentId | Select-String -Pattern '\d*([a-z]+)(\d+)(.*)$' -AllMatches).Matches
            } catch {
                return
            }

            if ($m.Groups.Count -gt 2 -and $m.Groups[1] -and $m.Groups[2]) {
                $id = $m.Groups[1].Value.ToUpper() + "-" + ($m.Groups[2].Value -replace '^0{1,5}', '').PadLeft(3, '0') + $m.Groups[3].Value.ToUpper()
            }

        } catch {
            return
        }
        Write-Output $id
    }
}

function Get-DmmTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $title = ($Webrequest.Content | Select-String -Pattern '<h1 id="title" class="item fn">(.*)<\/h1><\/div>').Matches.Groups[1].Value
        } catch {
            return
        }
        Write-Output $title
    }
}

function Get-DmmDescription {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $description = ($Webrequest.Content -split '<div class="mg-b20 lh4">')[1]
            $description = ($Webrequest.Content | Select-String -Pattern '<p class="mg-b20">\n(.*)').Matches.Groups[1].Value
        } catch {
            $description = $null
        }

        if ($null -eq $description -or $description -eq '') {
            $description = (((($Webrequest.Content -join "`r`n") -split '<div class="mg-b20 lh4">')[1]) -split '\n')[6]
            $description = ($description -replace '<p class=".*">.*<\/p>', '' -replace '<br>', '').Trim()
        }

        Write-Output $description
    }
}

function Get-DmmReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $releaseDate = ($Webrequest.Content | Select-String -Pattern '\d{4}\/\d{2}\/\d{2}').Matches.Groups[0].Value
        } catch {
            return
        }
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
        try {
            $length = ($Webrequest.Content | Select-String -Pattern '(\d{2,3})\s?(?:minutes|分)').Matches.Groups[1].Value
        } catch {
            return
        }
        Write-Output $length
    }
}

function Get-DmmDirector {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $director = ($Webrequest.Content | Select-String -Pattern '\/article=director\/id=\d*\/"[^>]*?>(.*)<\/a>').Matches.Groups[1].Value
        } catch {
            return
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
        try {
            $maker = ($Webrequest.Content | Select-String -Pattern '<a href="(\/digital\/videoa\/|(?:\/en)?\/mono\/dvd\/)-\/list\/=\/article=maker\/id=\d*\/"[^>]*?>(.*)<\/a>').Matches.Groups[2].Value
        } catch {
            return
        }
        Write-Output $maker
    }
}

function Get-DmmLabel {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $label = ($Webrequest.Content | Select-String -Pattern '<a href="(\/digital\/videoa\/|(?:\/en)?\/mono\/dvd\/)-\/list\/=\/article=label\/id=\d*\/"[^>]*?>(.*)<\/a>').Matches.Groups[2].Value
        } catch {
            return
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
        try {
            $series = ($Webrequest.Content | Select-String -Pattern '<a href="(\/digital\/videoa\/|(?:\/en)?\/mono\/dvd\/)-\/list\/=\/article=series\/id=\d*\/"[^>]*?>(.*)<\/a><\/td>').Matches.Groups[2].Value
        } catch {
            return
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
        try {
            $rating = ($Webrequest.Content | Select-String -Pattern '<strong>(.*)\s?(points|点)<\/strong>').Matches.Groups[1].Value
        } catch {
            return
        }

        if ($rating -match 'One') {
            $rating = 1
        }

        if ($rating -match 'Two') {
            $rating = 2
        }

        if ($rating -match 'Three') {
            $rating = 3
        }

        if ($rating -match 'Four') {
            $rating = 4
        }

        if ($rating -match 'Five') {
            $rating = 5
        }

        # Multiply the rating value by 2 to conform to 1-10 rating standard
        $newRating = [Decimal]$rating * 2
        $integer = [Math]::Round($newRating, 2)

        if ($integer -eq 0) {
            $integer = $null
        } else {
            $rating = $integer.ToString()
        }

        $ratingCount = (($Webrequest.Content -split '<p class="d-review__evaluates">')[1] -split '<\/p>')[0]
        $ratingCount = (($ratingCount -split '<strong>')[1] -split '<\/strong>')[0]

        if ($ratingCount -eq 0) {
            $ratingObject = $null
        } else {
            $ratingObject = [PSCustomObject]@{
                Rating = $rating
                Votes  = $ratingCount
            }
        }

        Write-Output $ratingObject
    }
}

function Get-DmmActress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Boolean]$ScrapeActress
    )

    process {
        $movieActressObject = @()
        if ($Webrequest.Content -match '\/digital\/videoa\/-\/detail\/ajax-performer\/') {
            try {
                $fullActressUrl = "https://www.dmm.co.jp" + ($Webrequest.Content | Select-String -Pattern '\/digital\/videoa\/-\/detail\/ajax-performer\/=\/data=.*\/').Matches.Groups[0].Value
                $movieActress = ((Invoke-WebRequest -Uri $fullActressUrl -Verbose:$false).Content | Select-String -Pattern '\/article=actress\/id=(\d*)\/">(.*)<\/a>' -AllMatches).Matches
            } catch {
                return
            }
        } else {
            try {
                $actressBlock = (($Webrequest.Content -split '<td align="right" valign="top" class="nw">(出演者：|Performers:)<\/td>')[2] -split '<\/td>')[0]
                $movieActress = ($actressBlock | Select-String -Pattern ' >(.*)</a>' -AllMatches).Matches
            } catch {
                return
            }
        }

        foreach ($actress in $movieActress) {
            $lastName = $null
            $firstName = $null
            $engActressUrl = "https://www.dmm.co.jp/en/mono/dvd/-/list/=/article=actress/id=$($actress.Groups[1].Value)/"
            $jaActressUrl = "https://www.dmm.co.jp/mono/dvd/-/list/=/article=actress/id=$($actress.Groups[1].Value)/"
            $actressName = $actress.Groups[1].Value
            if ($actressName -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                if ($ScrapeActress) {
                    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
                    $cookie = New-Object System.Net.Cookie
                    $cookie.Name = 'ckcy'
                    $cookie.Value = '2'
                    $cookie.Domain = 'dmm.co.jp'
                    $session.Cookies.Add($cookie)
                    $cookie = New-Object System.Net.Cookie
                    $cookie.Name = 'cklg'
                    $cookie.Value = 'en'
                    $cookie.Domain = 'dmm.co.jp'
                    $session.Cookies.Add($cookie)
                    $cookie = New-Object System.Net.Cookie
                    $cookie.Name = 'age_check_done'
                    $cookie.Value = '1'
                    $cookie.Domain = 'dmm.co.jp'
                    $session.Cookies.Add($cookie)

                    try {
                        $engActressName = ((((Invoke-WebRequest -Uri $engActressUrl -WebSession $session -Verbose:$false).Content | Select-String -Pattern '<title>(.*)</title>').Matches.Groups[1].Value -split '-')[0] -replace '\(.*\)', '').Trim()
                    } catch {
                        $engActressName = $null
                    }

                    $TextInfo = (Get-Culture).TextInfo
                    $engActressName = $TextInfo.ToTitleCase($engActressName)
                    $nameParts = ($engActressName -split ' ').Count
                    if ($nameParts -eq 1) {
                        $lastName = $null
                        $firstName = $engActressName
                    } else {
                        $lastName = ($engActressName -split ' ')[0]
                        $firstName = ($engActressName -split ' ')[1]
                    }
                }

                $movieActressObject += [PSCustomObject]@{
                    LastName     = $lastName
                    FirstName    = $firstName
                    JapaneseName = ($actressName -replace '（.*）', '').Trim()
                    ThumbUrl     = $null
                }
            } else {
                if ($ScrapeActress) {
                    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
                    $cookie = New-Object System.Net.Cookie
                    $cookie.Name = 'age_check_done'
                    $cookie.Value = '1'
                    $cookie.Domain = 'dmm.co.jp'
                    $session.Cookies.Add($cookie)
                    try {
                        $jaActressName = ((((Invoke-WebRequest -Uri $jaActressUrl -WebSession $session -Verbose:$false).Content | Select-String -Pattern '<title>(.*)</title>').Matches.Groups[1].Value -split '-')[0] -replace '\(.*\)', '' -replace '（.*）', '').Trim()
                    } catch {
                        $jaActressName = $null
                    }
                }

                $TextInfo = (Get-Culture).TextInfo
                $actressName = $TextInfo.ToTitleCase($actressName)
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

function Get-DmmGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $genreArray = @()
        try {
            $genre = ($Webrequest.Content | Select-String -Pattern '>(Genre:|ジャンル：)<\/td>\n(.*)').Matches.Groups[1].Value
        } catch {
            $genre = $null
        }

        try {
            if ($null -ne $genre -or $genre -ne '') {
                $genre = ((($Webrequest.Content -join "`r`n") -split '>(Genre:|ジャンル：)')[2] -split '<\/tr>')[0]
                $genre = ($genre -split '\/a>' | ForEach-Object { $_ | Select-String -Pattern '>(.*)<' }).Matches
            }
        } catch {
            return
        }

        if ($null -ne $genre -and $genre -ne '') {
            $genre = $genre | ForEach-Object { $genreArray += $_.Groups[1].Value -replace '<.*>', '' }
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
        try {
            $coverUrl = ($Webrequest.Content | Select-String -Pattern '(https:\/\/pics\.dmm\.co\.jp\/(mono\/movie\/adult|digital\/(?:video|amateur))\/(.*)\/(.*)\.jpg)').Matches.Groups[1].Value -replace 'ps.jpg', 'pl.jpg'
        } catch {
            return
        }
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

function Get-DmmTrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Object]$Session
    )

    process {
        $trailerUrl = @()
        try {
            $iFrameUrl = 'https://www.dmm.co.jp' + ($Webrequest.Content | Select-String -Pattern "onclick.+sampleplay\('([^']+)'\)").Matches.Groups[1].Value
            $trailerPageUrl = ((Invoke-WebRequest -Uri $iFrameUrl -WebSession $session -Verbose:$false).Content | Select-String -Pattern 'src="([^"]+)"').Matches.Groups[1].Value -replace '/en', ''
            $trailerUrl = ((Invoke-WebRequest -Uri $trailerPageUrl -Verbose:$false).Content | Select-String -Pattern '\\/\\/cc3001\.dmm\.co\.jp\\/litevideo\\/freepv[^"]+').Matches.Groups[0].Value -replace '\\', ''
            if ($trailerUrl -match '^//') {
                $trailerUrl = "https:$trailerUrl"
            }
        } catch {
            return
        }

        Write-Output $trailerUrl
    }
}
