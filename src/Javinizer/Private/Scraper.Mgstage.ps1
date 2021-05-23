function Get-MgstageId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $id = (((($Webrequest.Content -split '<th>品番：<\/th>')[1] -split '<\/td>')[0]) -split '<td>')[1]

        if ($id -eq '') {
            $id = $null
        }

        Write-Output $Id
    }
}

function Get-MgstageTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $title = (($Webrequest.Content -split '<title>')[1] -split '<\/title>')[0]
        $title = Convert-HtmlCharacter -String $title

        if ($title -eq '') {
            $title = $null
        }

        Write-Output $Title
    }
}

function Get-MgstageDescription {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        if ($Webrequest.Content -match '<p class="txt introduction">') {
            $description = (($Webrequest.Content -split '<p class="txt introduction">')[1] -split '<\/p>')[0]
            $description = Convert-HtmlCharacter -String $description
        } else {
            $description = $null
        }

        Write-Output $description
    }
}

function Get-MgstageReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseDate = (((($Webrequest.Content -split '<th>配信開始日：<\/th>')[1] -split '<\/td>')[0]) -split '<td>')[1]
        $releaseDate = Get-Date $releaseDate -Format "yyyy-MM-dd"

        Write-Output $releaseDate
    }
}

function Get-MgstageReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseYear = Get-MgstageReleaseDate -WebRequest $Webrequest
        $releaseYear = ($releaseYear -split '-')[0]

        Write-Output $releaseYear
    }
}

function Get-MgstageRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $length = ((($Webrequest.Content -split '<th>収録時間：<\/th>')[1] -split '<\/td>')[0] -split '<td>')[1]
        $length = ($length -replace 'min').Trim()

        Write-Output $length
    }
}

function Get-MgstageMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $maker = (((($Webrequest.Content -split '<th>メーカー：<\/th>')[1] -split '<\/td>')[0] -split '>')[2] -split '<\/a')[0]
        $maker = Convert-HtmlCharacter -String $maker

        if ($maker -eq '') {
            $maker = $null
        }

        Write-Output $maker
    }
}

function Get-MgstageLabel {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Object]$Replace
    )

    process {
        $label = (((($Webrequest.Content -split '<th>レーベル：<\/th>')[1] -split '<\/td>')[0] -split '>')[2] -split '<\/a')[0]
        $label = Convert-HtmlCharacter -String $label

        if ($label -eq '') {
            $label = $null
        }

        Write-Output $label
    }
}

function Get-MgstageSeries {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest,

        [Parameter()]
        [Object]$Replace
    )

    process {
        $series = (((($Webrequest.Content -split '<th>シリーズ：<\/th>')[1] -split '<\/td>')[0] -split '>')[2] -split '<\/a')[0]
        $series = Convert-HtmlCharacter -String $series

        if ($series -eq '') {
            $series = $null
        }

        Write-Output $series
    }
}

function Get-MgstageRating {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $rating = ($Webrequest.Content | Select-String -Pattern '<span class="star_.*"><\/span>(.*)').Matches.Groups[1].Value
            $ratingCount = (($Webrequest.Content | Select-String -Pattern '\((\d*) 件\)').Matches.Groups[1].Value).ToString()
        } catch {
            return
        }

        # Multiply the rating value by 2 to conform to 1-10 rating standard
        $newRating = [Decimal]$rating * 2
        $newRating = [Math]::Round($newRating, 2)

        if ($newRating -eq 0) {
            $rating = $null
        } else {
            $rating = $newRating.ToString()
        }

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

function Get-MgstageGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $genreArray = @()
        $genreHtml = ((($Webrequest.Content -split '<th>ジャンル：<\/th>')[1] -split '<\/td>')[0]) -split '<a href="\/search\/csearch\.php\?genre\[\]=.*">' | ForEach-Object { ($_ -replace '<td>' -replace '<\/a>').Trim() } | Where-Object { $_ -ne '' }

        foreach ($genre in $genreHtml) {
            $genre = Convert-HtmlCharacter -String $genre
            $genreArray += $genre
        }

        if ($genreArray.Count -eq 0) {
            $genreArray = $null
        }

        Write-Output $genreArray
    }
}

function Get-MgstageActress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $movieActressObject = @()
        $movieActress = (((($Webrequest.Content -split '<th>出演：<\/th>')[1] -split '<\/td>')[0]) -replace '<td>' -replace '<\/a>' -replace '<a href="\/search\/csearch\.php\?actor\[\]=.*">') -split '\n' `
        | ForEach-Object { ($_).Trim() } | Where-Object { $_ -ne '' }

        foreach ($actress in $movieActress) {
            # Match if the name contains Japanese characters
            if ($actress -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                $movieActressObject += [PSCustomObject]@{
                    LastName     = $null
                    FirstName    = $null
                    JapaneseName = Convert-JVCleanString -String $actress
                    ThumbUrl     = $null
                }
            } else {
                $movieActressObject += [PSCustomObject]@{
                    LastName     = ($actress -split ' ')[1] -replace '\\', ''
                    FirstName    = ($actress -split ' ')[0] -replace '\\', ''
                    JapaneseName = $null
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

function Get-MgstageCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            #$coverUrl = ($Webrequest.Content | Select-String -Pattern '<img src="(.*)" width=".*" height=".*" class="enlarge_image"').Matches.Groups[1].Value
            $coverUrl = ($Webrequest.Content | Select-String -Pattern 'class="link_magnify" href="(.*\.jpg)"').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $coverUrl
    }
}

function Get-MgstageScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $screenshotUrl = ( $Webrequest.Content | Select-String -Pattern 'class="sample_image" href="(.*.jpg)"' -AllMatches ).Matches | ForEach-Object { $_.Groups[1].Value }
        } catch {
            return
        }

        Write-Output $screenshotUrl
    }
}

function Get-MgstageTrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $trailerID = ($Webrequest.Content | Select-String -Pattern '\/sampleplayer\/sampleplayer.html\/([^"]+)"').Matches.Groups[1].Value
            $traileriFrameUrl = 'https://www.mgstage.com/sampleplayer/sampleRespons.php?pid=' + $trailerID
            $trailerUrl = ((Invoke-WebRequest -Uri $traileriFrameUrl -WebSession $session -Verbose:$false).Content | Select-String -Pattern '(https.+.ism)\\/').Matches.Groups[1].Value -replace '\\', '' -replace 'ism', 'mp4'
        } catch {
            return
        }
        Write-Output $trailerUrl
    }
}
