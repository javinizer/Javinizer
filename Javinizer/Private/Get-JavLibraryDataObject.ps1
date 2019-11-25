function Get-JavLibraryDataObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Id
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        $movieDataObject = @()
    }

    process {
        try {
            $javlibraryUrl = Get-JavLibraryUrl -Id $Id
            if ($null -ne $javlibraryUrl) {
                try {
                    $webRequest = Invoke-WebRequest -Uri $javlibraryUrl -WebSession $Session -UserAgent $Session.UserAgent
                } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
                    Write-Warning "Session to JAVLibrary is unsuccessful (possible CloudFlare session expired)"
                    Write-Warning "Attempting to start a new session..."
                    try {
                        New-CFSession
                    } catch {
                        throw $_
                    }
                    $webRequest = Invoke-WebRequest -Uri $javlibraryUrl -WebSession $Session -UserAgent $Session.UserAgent
                }

                $movieDataObject = [pscustomobject]@{
                    Url           = $javlibraryUrl
                    Id            = Get-JLMovieId -WebRequest $webRequest
                    Title         = Get-JLMovieTitle -WebRequest $webRequest
                    Date          = Get-JLMovieReleaseDate -WebRequest $webRequest
                    Year          = Get-JLMovieReleaseYear -WebRequest $webRequest
                    Length        = Get-JLMovieLength -WebRequest $webRequest
                    Director      = Get-JLMovieDirector -WebRequest $webRequest
                    Maker         = Get-JLMovieMaker -WebRequest $webRequest
                    Label         = Get-JLMovieLabel -WebRequest $webRequest
                    Rating        = Get-JLMovieRating -WebRequest $webRequest
                    Actress       = Get-JLMovieActress -WebRequest $webRequest
                    Genre         = Get-JLMovieGenre -WebRequest $webRequest
                    CoverUrl      = Get-JLMovieCoverUrl -WebRequest $webRequest
                    ScreenshotUrl = Get-JLMovieScreenshotUrl -WebRequest $webRequest
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        $movieDataObject | Format-List | Out-String | Write-Debug
        Write-Output $movieDataObject
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

function Get-JLMovieId {
    param (
        [object]$WebRequest
    )

    $movieId = ((($WebRequest.Content -split '<td class="header">ID:<\/td>')[1] -split '<\/td>')[0] -split '>')[1]
    Write-Output $movieId
}

function Get-JLMovieTitle {
    param (
        [object]$WebRequest
    )

    $fullTitle = ((($WebRequest.Content -split '<title>')[1] -split ' - JAVLibrary<\/title>')[0] -split '[a-zA-Z]{1,8}-[0-9]{1,8}')[1]
    $movieTitle = Convert-HtmlCharacter -String $fullTitle
    Write-Output $movieTitle
}

function Get-JLMovieReleaseDate {
    param (
        [object]$WebRequest
    )

    $movieReleaseDate = ((($WebRequest.Content -split '<td class="header">Release Date:<\/td>')[1] -split '<\/td>')[0] -split '>')[1]
    Write-Output $movieReleaseDate
}

function Get-JLMovieReleaseYear {
    param (
        [object]$WebRequest
    )

    $movieReleaseYear = Get-JLMovieReleaseDate -Html $WebRequest
    $movieReleaseYear = ($movieReleaseYear -split '-')[0]
    Write-Output $movieReleaseYear
}

function Get-JLMovieLength {
    param (
        [object]$WebRequest
    )

    $movieLength = ((($WebRequest.Content -split '<td class="header">Length:<\/td>')[1] -split '<\/span>')[0] -split '"text">')[1]
    Write-Output $movieLength
}

function Get-JLMovieDirector {
    param (
        [object]$WebRequest
    )

    $movieDirector = (((($WebRequest.Content -split '<td class="header">Director:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
    $movieDirector = Convert-HtmlCharacter -String $movieDirector
    Write-Output $movieDirector
}

function Get-JLMovieMaker {
    param (
        [object]$WebRequest
    )

    $movieMaker = (((($WebRequest.Content -split '<td class="header">Maker:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
    $movieMaker = Convert-HtmlCharacter -String $movieMaker
    Write-Output $movieMaker
}

function Get-JLMovieLabel {
    param (
        [object]$WebRequest
    )

    $movieLabel = (((($WebRequest.Content -split '<td class="header">Label:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
    $movieLabel = Convert-HtmlCharacter -String $movieLabel
    Write-Output $movieLabel
}

function Get-JLMovieRating {
    param (
        [object]$WebRequest
    )

    $movieRating = (((($WebRequest.Content -split '<td class="header">User Rating:</td>')[1]) -split '<\/span>')[0] -split '<span class="score">')[1]
    $movieRating = ($movieRating -replace '\(', '') -replace '\)', ''
    Write-Output $movieRating
}

function Get-JLMovieGenre {
    param (
        [object]$WebRequest
    )

    $movieGenre = @()
    $movieGenreHtml = ($WebRequest.Content -split '<td class="header">Genre\(s\):<\/td>')[1]
    $movieGenreHtml = ($movieGenreHtml -split '<\/td>')[0]
    $movieGenreHtml = $movieGenreHtml -split 'rel="category tag">'

    foreach ($genre in $movieGenreHtml[1..($movieGenreHtml.Length - 1)]) {
        $genre = ($genre -split '<')[0]
        $genre = Convert-HtmlCharacter -String $genre
        $movieGenre += $genre
    }

    Write-Output $movieGenre
}

function Get-JLMovieActress {
    param (
        [object]$WebRequest
    )

    $movieActress = @()
    $actressSplitString = '<span class="star">'
    $actressSplitHtml = $WebRequest.Content -split $actressSplitString

    foreach ($section in $actressSplitHtml) {
        $fullName = (($section -split "rel=`"tag`">")[1] -split "<\/a><\/span>")[0]
        if ($fullName -ne '') {
            if ($fullName.Length -lt 25) {
                $movieActress += $fullName
            }
        }
    }

    Write-Output $movieActress
}

function Get-JLMovieCoverUrl {
    param (
        [object]$WebRequest
    )

    $movieCoverUrl = $WebRequest.Images | Where-Object { $_.src -match 'pics.dmm.co.jp\/mono\/movie\/adult' }
    $movieCoverUrl = 'https:' + $movieCoverUrl.src
    Write-Output $movieCoverUrl
}

function Get-JLMovieScreenshotUrl {
    param (
        [object]$WebRequest
    )

    $movieScreenshotUrl = @()
    $movieScreenshotHtml = $WebRequest.Images | Where-Object { $_.src -match 'pics.dmm.co.jp\/digital\/video' }
    $movieScreenshotHtml = $movieScreenshotHtml.src
    $movieScreenshotHtml = $moviescreenshotHtml -split ' '
    foreach ($screenshot in $movieScreenshotHtml) {
        $url = 'https:' + $screenshot
        $movieScreenshotUrl += $url
    }
    Write-Output $movieScreenshotUrl
}
