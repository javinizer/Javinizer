function Get-JavlibraryDataObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Url
    )

    process {
        $movieDataObject = @()

        try {
            Write-JLog -Level Debug -Message "Performing [GET] on URL [$Url] with Session: [$Session] and UserAgent: [$($Session.UserAgent)]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -WebSession $Session -UserAgent $Session.UserAgent -Verbose:$false
        } catch {
            Write-JLog -Level Error -Message "Error [GET] on URL [$Url]: $PSItem"
        }

        $movieDataObject = [pscustomobject]@{
            Source        = 'javlibrary'
            Url           = $Url
            Id            = Get-JLId -WebRequest $webRequest
            AjaxId        = Get-JLAjaxId -WebRequest $webRequest
            Title         = Get-JLTitle -WebRequest $webRequest
            Date          = Get-JLReleaseDate -WebRequest $webRequest
            Year          = Get-JLReleaseYear -WebRequest $webRequest
            Runtime       = Get-JLRuntime -WebRequest $webRequest
            Director      = Get-JLDirector -WebRequest $webRequest
            Maker         = Get-JLMaker -WebRequest $webRequest
            Label         = Get-JLLabel -WebRequest $webRequest
            Rating        = Get-JLRating -WebRequest $webRequest
            Actress       = Get-JLActress -WebRequest $webRequest
            Genre         = Get-JLGenre -WebRequest $webRequest
            CoverUrl      = Get-JLCoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-JLScreenshotUrl -WebRequest $webRequest
        }

        Write-JLog -Level Debug -Message "JAVLibrary data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
function Get-JLId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $id = ((($WebRequest.Content -split '<div id="video_id" class="item">')[1] -split '<\/td>')[1] -split '>')[1]
        Write-Output $id
    }
}

function Get-JLAjaxId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $ajaxId = ((($WebRequest | ForEach-Object { $_ -split '\n' } |
                        Select-String 'var \$ajaxid = "(.*)";').Matches.Groups[1].Value))
        } catch {
            return
        }

        Write-Output $ajaxId
    }
}

function Get-JLTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )
    process {
        $fullTitle = ((($WebRequest.Content -split '<title>')[1] -split ' - JAVLibrary<\/title>')[0] -split ' ')
        $joinedTitle = $fullTitle[1..$fullTitle.length] -join ' '
        $title = Convert-HtmlCharacter -String $joinedTitle
        Write-Output $title
    }
}

function Get-JLReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $releaseDate = ((($WebRequest.Content -split '<div id="video_date" class="item">')[1] -split '<\/td>')[1] -split '>')[1]
        Write-Output $releaseDate
    }
}

function Get-JLReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $releaseYear = Get-JLReleaseDate -WebRequest $WebRequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-JLRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $length = ((($WebRequest.Content -split '<div id="video_length" class="item">')[1] -split '<\/span>')[0] -split '"text">')[1]
        Write-Output $length
    }
}

function Get-JLDirector {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $director = ((($WebRequest.Content -split '<div id="video_director" class="item">')[1]) -split '<\/td>')[1]
        if ($director -match '<\/a>') {
            $director = (($director -split 'rel="tag">')[1] -split '<\/a')[0]
        } else {
            $director = $null
        }
        $director = Convert-HtmlCharacter -String $director
        Write-Output $director
    }
}

function Get-JLMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $maker = (((($WebRequest.Content -split '<div id="video_maker" class="item">')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-JLLabel {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $label = (((($WebRequest.Content -split '<div id="video_label" class="item">')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
        $label = Convert-HtmlCharacter -String $label
        Write-Output $label
    }
}

function Get-JLRating {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $rating = (((($WebRequest.Content -split '<div id="video_review" class="item">')[1]) -split '<\/span>')[0] -split '<span class="score">')[1]
        $rating = ($rating -replace '\(', '') -replace '\)', ''
        Write-Output $rating
    }
}

function Get-JLGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $genre = @()
        $genreHtml = ($WebRequest.Content -split '<div id="video_genres" class="item">')[1]
        $genreHtml = ($genreHtml -split '<\/td>')[1]
        $genreHtml = $genreHtml -split 'rel="category tag">'

        foreach ($genres in $genreHtml[1..($genreHtml.Length - 1)]) {
            $genres = ($genres -split '<')[0]
            $genres = Convert-HtmlCharacter -String $genres
            $genre += $genres
        }

        if ($genre.Count -eq 0) {
            $genre = $null
        }

        Write-Output $genre
    }
}

function Get-JLActress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $actress = @()
        $actressSplitString = '<span class="star">'
        $actressSplitHtml = $WebRequest.Content -split $actressSplitString

        foreach ($section in $actressSplitHtml) {
            $fullName = (($section -split "rel=`"tag`">")[1] -split "<\/a><\/span>")[0]
            if ($fullName -ne '') {
                if ($fullName.Length -lt 25) {
                    $actress += $fullName
                }
            }
        }

        if ($actress.Count -eq 0) {
            $actress = $null
        }

        Write-Output $actress
    }
}

function Get-JLCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $coverUrl = (($WebRequest.Content -split '<img id="video_jacket_img" src="')[1] -split '"')[0]
        if ($coverUrl -like '*pixhost*') {
            $coverUrl = 'http:' + $coverUrl
        } else {
            $coverUrl = 'https:' + $coverUrl
        }
        Write-Output $coverUrl
    }
}

function Get-JLScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $screenshotUrl = @()
        $screenshotHtml = (($WebRequest.Content -split '<div class="previewthumbs" style="display:block; margin:10px auto;">')[1] -split '<\/div>')[0]
        $screenshotHtml = $screenshotHtml -split '<img src="'
        foreach ($screenshot in $screenshotHtml) {
            if ($screenshot -ne '') {
                $screenshot = 'https:' + ($screenshot -split '"')[0]
                $screenshot = $screenshot -replace '-', 'jp-'
                if ($screenshot -match 'pics.dmm') {
                    $screenshotUrl += $screenshot
                }
            }
        }

        Write-Output $screenshotUrl
    }
}
