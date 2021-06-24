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

    process {
        try {
            $info = Get-TokyoHotInfo -Webrequest $Webrequest
            $id = (($info[-1] | Select-String -Pattern '<dd>(.*)<\/dd>').Matches.Groups[1].Value).Trim()
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
            $releaseDate = ($info | Select-String -Pattern '<dd>(\d*\/\d*\/\d*)<\/dd>').Matches.Groups[1].Value -replace '/', '-'
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
        try {
            $info = Get-TokyoHotInfo -Webrequest $Webrequest
            $rawLength = ($info | Select-String -Pattern '<dd>(\d*:\d*:\d*)<\/dd>').Matches.Groups[1].Value
            $hours, $minutes, $seconds = $rawLength -split ':'
            $length = [Math]::Round((New-TimeSpan -Hours $hours -Minutes $minutes -Seconds $seconds).TotalMinutes)
        } catch {
            return
        }

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
            $info = Get-TokyohotInfo -Webrequest $Webrequest
            $maker = ($info | Select-String -Pattern '<a href="\/product\/\?vendor=(?:.*)">(.*)<\/a>').Matches.Groups[1].Value
        } catch {
            return
        }

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
            $info = Get-TokyoHotInfo -Webrequest $Webrequest
            $series = ($info | Select-String -Pattern '<a href="\/product\/\?type=genre&filter=.*>(.*)<\/a>').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $series
    }
}

function Get-TokyoHotGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $genres = New-Object System.Collections.ArrayList

        try {
            $genreLine = (($Webrequest.Content -split '<dt>(Play|プレイ内容|玩法內容)<\/dt>')[2] -split '<dt>')[0] -replace '<dd>', '' -split '<a href'
            ($genreLine | Select-String -Pattern '>(.*)<\/a>' -AllMatches).Matches | ForEach-Object { $genres.Add($_.Groups[1].Value) } | Out-Null
        } catch {
            return
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
            $actresses = @()
            $actressLine = (($Webrequest.Content -split '<dt>(Model|出演者)<\/dt>')[2] -split '<\/dd>')[0] -replace '<dd>', ''
            $actresses = ($actressLine -split '<a' | Select-String -Pattern '>(.*)<\/a>' -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value } #ForEach-Object { (($_ -split '>')[1] -split '<')[0] | Where-Object { $_.trim() -ne '' } }
            $movieActressObject = @()
            foreach ($actress in $actresses) {
                if ($actress -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                    $movieActressObject += [PSCustomObject]@{
                        LastName     = $null
                        FirstName    = $null
                        JapaneseName = $actress
                        ThumbUrl     = $null
                    }
                } else {
                    $movieActressObject += [PSCustomObject]@{
                        LastName     = ($actress -split ' ')[1]
                        FirstName    = ($actress -split ' ')[0]
                        JapaneseName = $null
                        ThumbUrl     = $null
                    }
                }
            }
        } catch {
            return
        }

        Write-Output $movieActressObject
    }
}

function Get-TokyoHotCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $coverUrl = ($Webrequest.Content | Select-String -Pattern '(https:\/\/my\.cdn\.tokyo-hot\.com\/media\/.*\/jacket\/.*\.jpg)">').Matches.Groups[1].Value
        } catch {
            try {
                $coverUrl = ($Webrequest.Content | Select-String -Pattern '"(https:.*list_image.*\.jpg)"').Matches.Groups[1].Value
            } catch {
                try {
                    $coverUrl = ($Webrequest.Content | Select-String -Pattern '<video poster="(.*)">').Matches.Groups[1].Value
                } catch {
                    try {
                        $coverUrl = ($Webrequest.Content | Select-String -Pattern '<dl8-video.*poster="(.*\.jpg)"').Matches.Groups[1].Value
                    } catch {
                        return
                    }
                }
            }
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
            $screenshots = New-Object System.Collections.ArrayList
            try {
                ((($Webrequest.Content -split '<div class="scap">')[1] -split '<\/div>')[0] | Select-String -Pattern '<a href="(.*)" rel="cap">' -AllMatches).Matches | ForEach-Object { $screenshots.Add($_.Groups[1].Value) } | Out-Null
            } catch {
                # Do nothing
            }
            ($Webrequest.Content | Select-String -Pattern '"(https:.*vcap.*wlimited\.jpg)"' -AllMatches).Matches | ForEach-Object { $screenshots.Add($_.Groups[1].Value) } | Out-Null
        } catch {
            return
        }

        Write-Output $screenshots
    }
}

function Get-TokyoHotTrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $trailerUrl = ($Webrequest.Content | Select-String -Pattern 'src="(.*\.mp4)"').Matches.Groups[1].Value
            if ($trailerUrl -notcontains "http") {
                $trailerUrl = "https://www.tokyo-hot.com/product/$(Get-TokyoHotId -Webrequest $Webrequest)$trailerUrl"
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
            $description = Convert-HTMLCharacter ((($Webrequest.Content -split '<div class="sentence">')[1] -split '<\/div>')[0] -replace '<br \/?>', '')
        } catch {
            return
        }

        Write-Output $description
    }
}
