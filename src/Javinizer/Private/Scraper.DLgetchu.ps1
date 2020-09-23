function Get-DLgetchuId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $id = ($Webrequest.Content | Select-String -Pattern '作品ID：(\d*)').Matches.Groups[1].Value
        } catch {
            return
        }
        Write-Output $id
    }
}

function Get-DLgetchuTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )
    process {
        try {
            $title = ($Webrequest.Content -split '\n' | Select-String -Pattern '<meta property="og:title" content="(.*)" />').Matches.Groups[1].Value
        } catch {
            return
        }
        Write-Output $title
    }
}

function Get-DLgetchuDescription {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $descriptionBlock = ((($Webrequest.Content -split '作品内容<\/td>')[1] -split '<\/td>')[0] -replace '<[^>]*>', '').Trim()
        } catch {
            return
        }

        $description = $descriptionBlock -split '\n' -join ' '
        Write-Output $description
    }
}

function Get-DLgetchuReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $releaseDate = ($Webrequest.Content | Select-String -Pattern '<td bgcolor="white" width="449">(\d{4}\/\d{2}\/\d{2})<\/td>').Matches.Groups[1].Value
        } catch {
            return
        }
        Write-Output $releaseDate
    }
}

function Get-DLgetchuReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseYear = Get-DLgetchuReleaseDate -WebRequest $Webrequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-DLgetchuRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $unicodeReplace = @{
            '０' = '0'
            '１' = '1'
            '２' = '2'
            '３' = '3'
            '４' = '4'
            '５' = '5'
            '６' = '6'
            '７' = '7'
            '８' = '8'
            '９' = '9'
        }

        try {
            $length = ($WebRequest.Content | Select-String -Pattern '([０１２３４５６７８９]?\s?[０１２３４５６７８９]?\s?[０１２３４５６７８９]?)分').Matches.Groups[1].Value
        } catch {
            return
        }

        foreach ($unicode in $unicodeReplace.GetEnumerator()) {
            $length = $length -replace $unicode.Name, $unicode.Value
        }

        Write-Output $length
    }
}

function Get-DLgetchuMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $maker = ($Webrequest.Content | Select-String -Pattern '<a href=".*dojin_circle_detail.php\?id=\d*.*">(.*)<\/a><\/td>').Matches.Groups[1].Value
        Write-Output $maker
    }
}


function Get-DLgetchuGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $genreHtml = (($Webrequest.Content -split '<td class="bluetext" align="center" bgcolor="#f0f8ff" width="100">趣向</td>')[1] -split '<\/tr>')[0]
            $genre = ($genreHtml | Select-String -Pattern '<a href=".*genre_id=(\d*).*">(.*)<\/a>' -AllMatches).Matches | ForEach-Object { $_.Groups[2].Value }
        } catch {
            return
        }

        if ($genre.Count -eq 0) {
            $genre = $null
        }

        Write-Output $genre
    }
}

function Get-DLgetchuCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $coverUrl = "http://dl.getchu.com" + ($Webrequest.Content | Select-String -Pattern '\/data\/item_img\/.*\/.*\/\d*top\.jpg').Matches.Groups[0].Value
        } catch {
            return
        }

        Write-Output $coverUrl
    }
}

function Get-DLgetchuScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $screenshotUrl = ($Webrequest.Content | Select-String -Pattern '"(\/data\/item_img\/.*\/.*\/.*\.jpg)" class="highslide"' -AllMatches).Matches | ForEach-Object { "http://dl.getchu.com" + $_.Groups[1].Value }
        } catch {
            return
        }
        Write-Output $screenshotUrl
    }
}
