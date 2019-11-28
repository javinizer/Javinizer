function Get-R18DataObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        $movieDataObject = @()
    }

    process {
        $r18Url = Get-R18Url -Name $Name
        if ($null -ne $R18Url) {
            try {
                $webRequest = Invoke-WebRequest -Uri $r18Url
            } catch {
                throw $_
            }

            $movieDataObject = [pscustomobject]@{
                Url           = $r18Url
                ContentId     = Get-R18ContentId -WebRequest $webRequest
                Id            = Get-R18Id -WebRequest $webRequest
                Title         = Get-R18Title -WebRequest $webRequest
                Date          = Get-R18ReleaseDate -WebRequest $webRequest
                Year          = Get-R18ReleaseYear -WebRequest $webRequest
                Length        = Get-R18Length -WebRequest $webRequest
                Director      = Get-R18Director -WebRequest $webRequest
                Maker         = Get-R18Maker -WebRequest $webRequest
                Label         = Get-R18Label -WebRequest $webRequest
                Series        = Get-R18Series -WebRequest $webRequest
                Rating        = Get-R18Rating -WebRequest $webRequest
                Actress       = Get-R18Actress -WebRequest $webRequest
                Genre         = Get-R18Genre -WebRequest $webRequest
                CoverUrl      = Get-R18CoverUrl -WebRequest $webRequest
                ScreenshotUrl = Get-R18ScreenshotUrl -WebRequest $webRequest
            }
        }

        $movieDataObject | Format-List | Out-String | Write-Debug
        Write-Output $movieDataObject
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

function Get-R18ContentId {
    param (
        [object]$WebRequest
    )

    process {
        $contentId = (((($WebRequest.Content -split '<dt>Content ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
        $contentId = Convert-HtmlCharacter -String $contentId
        Write-Output $contentId
    }
}

function Get-R18Id {
    param (
        [object]$WebRequest
    )

    process {
        $id = (((($WebRequest.Content -split '<dt>DVD ID:<\/dt>')[1] -split '<br>')[0]) -split '<dd>')[1]
        $id = Convert-HtmlCharacter -String $id
        Write-Output $Id
    }
}

function Get-R18Title {
    param (
        [object]$WebRequest
    )

    process {
        $title = (($WebRequest.Content -split '<cite itemprop=\"name\">')[1] -split '<\/cite>')[0]
        $title = Convert-HtmlCharacter -String $title
        Write-Output $Title
    }
}

function Get-R18ReleaseDate {
    param (
        [object]$WebRequest
    )

    process {
        $releaseDate = (($WebRequest.Content -split '<dd itemprop=\"dateCreated\">')[1] -split '<br>')[0]
        $releaseDate = ($releaseDate.Trim() -replace '\.', '') -replace ',', ''
        $month, $day, $year = $releaseDate -split ' '

        # Convert full month names to abbreviated values due to non-standard naming conventions on R18 website
        if ($month -eq 'June') {
            $month = 'Jun'
        } elseif ($month -eq 'July') {
            $month = 'Jul'
        }

        # Convert the month name to a numeric value to conform with CMS datetime standards
        $month = [array]::indexof([cultureinfo]::CurrentCulture.DateTimeFormat.AbbreviatedMonthNames, "$month") + 1
        $releaseDate = Get-Date -Year $year -Month $month -Day $day -Format "yyyy-MM-dd"
        Write-Output $releaseDate
    }
}

function Get-R18ReleaseYear {
    param (
        [object]$WebRequest
    )

    process {
        $releaseYear = Get-R18ReleaseDate -WebRequest $WebRequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-R18Length {
    param (
        [object]$WebRequest
    )

    process {
        $length = ((($WebRequest.Content -split '<dd itemprop="duration">')[1] -split '\.')[0]) -replace 'min', ''
        $length = Convert-HtmlCharacter -String $length
        Write-Output $length
    }
}

function Get-R18Director {
    param (
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
        [object]$WebRequest
    )

    process {
        $maker = ((($WebRequest.Content -split '<dd itemprop="productionCompany" itemscope itemtype="http:\/\/schema.org\/Organization\">')[1] -split '<\/a>')[0] -split '>')[1]
        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-R18Label {
    param (
        [object]$WebRequest
    )

    process {
        $label = ((($WebRequest.Content -split '<dt>Label:<\/dt>')[1] -split '<br>')[0] -split '<dd>')[1]
        $label = Convert-HtmlCharacter -String $label
        Write-Output $label
    }
}

function Get-R18Series {
    param (
        [object]$WebRequest
    )

    process {
        $series = (((($WebRequest.Content -split '<dt>Series:</dt>')[1] -split '<\/a><br>')[0] -split '<dd>')[1] -split '>')[1]
        $series = Convert-HtmlCharacter -String $series

        if ($series -like '</dd*') {
            $series = $null
        }

        Write-Output $series
    }
}

function Get-R18Rating {
    param (
        [object]$WebRequest
    )

    process {
        $rating = ''
        Write-Output $rating
    }
}

function Get-R18Genre {
    param (
        [object]$WebRequest
    )

    begin {
        $genreArray = @()
    }

    process {
        $genreHtml = ((($WebRequest.Content -split '<div class="pop-list">')[1] -split '<\/div>')[0] -split '<\/a>') -split '>'

        foreach ($genre in $genreHtml) {
            $genre = $genre.trim()
            if ($genre -notmatch 'https:\/\/www\.r18\.com\/videos\/vod\/movies\/list\/id=(.*)' -and $genre -ne '') {
                $genre = Convert-HtmlCharacter -String $genre
                $genreArray += $genre
            }
        }

        Write-Output $genreArray
    }
}

function Get-R18Actress {
    param (
        [object]$WebRequest
    )

    begin {
        $movieActress = @()
        $movieActressThumb = @()
    }

    process {
        $movieActressHtml = (($WebRequest.Content -split '<div itemprop="actors" data-type="actress-list" class="pop-list">')[1] -split '<div class="product-categories-list product-box-list">')[0]
        $movieActressHtml = $movieActressHtml -replace '<a itemprop="url" href="https:\/\/www\.r18\.com\/videos\/vod\/movies\/list\/id=(.*)\/pagesize=(.*)\/price=all\/sort=popular\/type=actress\/page=(.*)\/">', ''
        $movieActressHtml = $movieActressHtml -replace '<span itemscope itemtype="http:\/\/schema.org\/Person">', ''
        $movieActressHtml = $movieActressHtml -split '<\/a>'

        foreach ($actress in $movieActressHtml) {
            if ($actress -match '<span itemprop="name">') {
                $movieActress += (($actress -split '<span itemprop="name">')[1] -split '<\/span>')[0]
            }
        }

        if ($movieActress -eq '----') {
            $movieActress = $null
        }

        foreach ($actress in $movieActress) {
            $movieActressThumb += ($WebRequest.Images | Where-Object { $_.alt -eq "$actress" }).src
        }

        $movieActressObject = [pscustomobject]@{
            Name     = $movieActress
            ThumbUrl = $movieActressThumb
        }

        Write-Output $movieActressObject
    }
}

function Get-R18CoverUrl {
    param (
        [object]$WebRequest
    )

    process {
        $coverUrl = $WebRequest.Images | Where-Object { $_.alt -like '*cover*' }
        $coverUrl = $coverUrl.src
        Write-Output $coverUrl
    }
}

function Get-R18ScreenshotUrl {
    param (
        [object]$WebRequest
    )

    begin {
        $screenshotUrl = @()
    }

    process {
        $screenshotUrl = $WebRequest.Images | Where-Object { $_.alt -like '*screenshot*' }
        $screenshotUrl = $screenshotUrl.'data-src'
        Write-Output $screenshotUrl
    }
}
