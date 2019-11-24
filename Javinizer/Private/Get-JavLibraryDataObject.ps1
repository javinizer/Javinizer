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
                    $html = $webRequest.Content
                } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
                    Write-Warning "Session to JAVLibrary is unsuccessful (possible CloudFlare session expired)"
                    Write-Warning "Attempting to start a new session..."
                    try {
                        New-CFSession
                    } catch {
                        throw $_
                    }
                    $webRequest = Invoke-WebRequest -Uri $javlibraryUrl -WebSession $Session -UserAgent $Session.UserAgent
                    $html = $webRequest.Content
                }

                $movieDataObject = [pscustomobject]@{
                    movieId       = Get-JLMovieId -Html $html
                    movieTitle    = Get-JLMovieTitle -Html $html
                    movieDate     = Get-JLMovieReleaseDate -Html $html
                    movieYear     = Get-JLMovieReleaseYear -Html $html
                    movieLength   = Get-JLMovieLength -Html $html
                    movieDirector = Get-JLMovieDirector -Html $html
                    movieMaker    = Get-JLMovieMaker -Html $html
                    movieLabel    = Get-JLMovieLabel -Html $html
                    movieRating   = Get-JLMovieRating -Html $html
                    movieActress  = Get-JLMovieActress -Html $html
                    movieGenre    = Get-JLMovieGenre -Html $html
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
        [string]$Html
    )

    $movieId = ((($Html -split '<td class="header">ID:<\/td>')[1] -split '<\/td>')[0] -split '>')[1]
    Write-Output $movieId
}

function Get-JLMovieTitle {
    param (
        [string]$Html
    )

    $fullTitle = ((($Html -split '<title>')[1] -split ' - JAVLibrary<\/title>')[0] -split '[a-zA-Z]{1,8}-[0-9]{1,8}')[1]
    $movieTitle = Convert-HtmlCharacter -String $fullTitle
    Write-Output $movieTitle
}

function Get-JLMovieReleaseDate {
    param (
        [string]$Html
    )

    $movieReleaseDate = ((($Html -split '<td class="header">Release Date:<\/td>')[1] -split '<\/td>')[0] -split '>')[1]
    Write-Output $movieReleaseDate
}

function Get-JLMovieReleaseYear {
    param (
        [string]$Html
    )

    $movieReleaseYear = Get-JLMovieReleaseDate -Html $Html
    $movieReleaseYear = ($movieReleaseYear -split '-')[0]
    Write-Output $movieReleaseYear
}

function Get-JLMovieLength {
    param (
        [string]$Html
    )

    $movieLength = ((($Html -split '<td class="header">Length:<\/td>')[1] -split '<\/span>')[0] -split '"text">')[1]
    Write-Output $movieLength
}

function Get-JLMovieDirector {
    param (
        [string]$Html
    )

    $movieDirector = (((($Html -split '<td class="header">Director:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
    $movieDirector = Convert-HtmlCharacter -String $movieDirector
    Write-Output $movieDirector
}

function Get-JLMovieMaker {
    param (
        [string]$Html
    )

    $movieMaker = (((($Html -split '<td class="header">Maker:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
    $movieMaker = Convert-HtmlCharacter -String $movieMaker
    Write-Output $movieMaker
}

function Get-JLMovieLabel {
    param (
        [string]$Html
    )

    $movieLabel = (((($Html -split '<td class="header">Label:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
    $movieLabel = Convert-HtmlCharacter -String $movieLabel
    Write-Output $movieLabel
}

function Get-JLMovieRating {
    param (
        [string]$Html
    )

    $movieRating = (((($Html -split '<td class="header">User Rating:</td>')[1]) -split '<\/span>')[0] -split '<span class="score">')[1]
    $movieRating = ($movieRating -replace '\(', '') -replace '\)', ''
    Write-Output $movieRating
}

function Get-JLMovieGenre {
    param (
        [string]$Html
    )

    $movieGenre = @()
    $movieGenreHtml = ($Html -split '<td class="header">Genre\(s\):<\/td>')[1]
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
        [string]$Html
    )

    $movieActress = @()
    $actressSplitString = '<span class="star">'
    $actressSplitHtml = $Html -split $actressSplitString

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

