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
                    $script:html = Invoke-WebRequest -Uri $javlibraryUrl -WebSession $Session -UserAgent $Session.UserAgent
                } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
                    Write-Warning "Session to JAVLibrary is unsuccessful (possible CloudFlare session expired)"
                    Write-Warning "Attempting to start a new session..."
                    try {
                        New-CFSession
                    } catch {
                        throw $_
                    }
                    $script:html = Invoke-WebRequest -Uri $javlibraryUrl -WebSession $Session -UserAgent $Session.UserAgent
                }

                $movieDataObject = [pscustomobject]@{
                    movieTitle    = Get-Title
                    movieId       = Get-MovieId
                    movieDate     = Get-MovieReleaseDate
                    movieYear     = Get-MovieReleaseYear
                    movieLength   = Get-MovieLength
                    movieDirector = Get-MovieDirector
                    movieMaker    = Get-MovieMaker
                    movieLabel    = Get-MovieLabel
                    movieRating   = Get-MovieRating
                    movieActress  = Get-MovieActress
                    movieGenre    = Get-MovieGenre
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

function Get-MovieId {
    $movieId = ((($html.content -split '<td class="header">ID:<\/td>')[1] -split '<\/td>')[0] -split '>')[1]
    Write-Output $movieId
}

function Get-MovieTitle {
    $fullTitle = ((($html.content -split '<title>')[1] -split ' - JAVLibrary<\/title>')[0] -split '[a-zA-Z]{1,8}-[0-9]{1,8}')[1]
    $movieTitle = $fullTitle.Trim()
    Write-Output $movieTitle
}

function Get-MovieReleaseDate {
    $movieReleaseDate = ((($html.content -split '<td class="header">Release Date:<\/td>')[1] -split '<\/td>')[0] -split '>')[1]
    Write-Output $movieReleaseDate
}

function Get-MovieReleaseYear {
    $movieReleaseYear = Get-MovieReleaseDate
    $movieReleaseYear = ($movieReleaseYear -split '-')[0]
    Write-Output $movieReleaseYear
}

function Get-MovieLength {
    $movieLength = ((($html.content -split '<td class="header">Length:<\/td>')[1] -split '<\/span>')[0] -split '"text">')[1]
    Write-Output $movieLength
}

function Get-MovieDirector {
    $movieDirector = (((($html.content -split '<td class="header">Director:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
    Write-Output $movieDirector
}

function Get-MovieMaker {
    $movieMaker = (((($html.content -split '<td class="header">Maker:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
    Write-Output $movieMaker
}

function Get-MovieLabel {
    $movieLabel = (((($html.content -split '<td class="header">Label:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
    Write-Output $movieLabel
}

function Get-MovieRating {
    $movieRating = (((($html.content -split '<td class="header">User Rating:</td>')[1]) -split '<\/span>')[0] -split '<span class="score">')[1]
    $movieRating = ($movieRating -replace '\(', '') -replace '\)', ''
    Write-Output $movieRating
}

function Get-MovieGenre {
    $movieGenre = (($html.content -match 'rel="category tag">(.*)<\/a><\/span><\/td>') -Split 'rel="category tag">')
    Write-Output $movieGenre
}

function Get-MovieActress {
    $actressSplitString = '<span class="star">'
    $actressSplitHtml = $html.content -split $actressSplitString
    $actressObject = @()
    foreach ($section in $actressSplitHtml) {
        $fullName = (($section -split "rel=`"tag`">")[1] -split "<\/a><\/span>")[0]
        if ($fullName -ne '') {
            if ($fullName.Length -lt 25) {
                $actressObject += $fullName
            }
        }
    }
    Write-Output $actressObject
}

