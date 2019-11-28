function Get-JavLibraryDataObject {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        $movieDataObject = @()
    }

    process {
        $javlibraryUrl = Get-JavLibraryUrl -Name $Name
        if ($null -ne $javlibraryUrl) {
            try {
                $webRequest = Invoke-WebRequest -Uri $javlibraryUrl -WebSession $Session -UserAgent $Session.UserAgent
            } catch [Microsoft.PowerShell.Commands.HttpResponseException] {
                Write-Warning "Session to JAVLibrary is unsuccessful (possible CloudFlare session expired)"
                Write-Warning "Attempting to start a new session..."
                try {
                    New-CloudflareSession
                } catch {
                    throw $_
                }

                $webRequest = Invoke-WebRequest -Uri $javlibraryUrl -WebSession $Session -UserAgent $Session.UserAgent
            }

            $movieDataObject = [pscustomobject]@{
                Url           = $javlibraryUrl
                Id            = Get-JLId -WebRequest $webRequest
                Title         = Get-JLTitle -WebRequest $webRequest
                Date          = Get-JLReleaseDate -WebRequest $webRequest
                Year          = Get-JLReleaseYear -WebRequest $webRequest
                Length        = Get-JLLength -WebRequest $webRequest
                Director      = Get-JLDirector -WebRequest $webRequest
                Maker         = Get-JLMaker -WebRequest $webRequest
                Label         = Get-JLLabel -WebRequest $webRequest
                Rating        = Get-JLRating -WebRequest $webRequest
                Actress       = Get-JLActress -WebRequest $webRequest
                Genre         = Get-JLGenre -WebRequest $webRequest
                CoverUrl      = Get-JLCoverUrl -WebRequest $webRequest
                ScreenshotUrl = Get-JLScreenshotUrl -WebRequest $webRequest
            }
        }

        $movieDataObject | Format-List | Out-String | Write-Debug
        Write-Output $movieDataObject
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

function Get-JLId {
    param (
        [object]$WebRequest
    )

    process {
        $id = ((($WebRequest.Content -split '<td class="header">ID:<\/td>')[1] -split '<\/td>')[0] -split '>')[1]
        Write-Output $id
    }
}

function Get-JLTitle {
    param (
        [object]$WebRequest
    )
    process {
        $fullTitle = ((($WebRequest.Content -split '<title>')[1] -split ' - JAVLibrary<\/title>')[0] -split '[a-zA-Z]{1,8}-[0-9]{1,8}')[1]
        $title = Convert-HtmlCharacter -String $fullTitle
        Write-Output $title
    }
}

function Get-JLReleaseDate {
    param (
        [object]$WebRequest
    )

    process {
        $releaseDate = ((($WebRequest.Content -split '<td class="header">Release Date:<\/td>')[1] -split '<\/td>')[0] -split '>')[1]
        Write-Output $releaseDate
    }
}

function Get-JLReleaseYear {
    param (
        [object]$WebRequest
    )

    process {
        $releaseYear = Get-JLReleaseDate -WebRequest $WebRequest
        $releaseYear = ($releaseYear -split '-')[0]
        Write-Output $releaseYear
    }
}

function Get-JLLength {
    param (
        [object]$WebRequest
    )

    process {
        $length = ((($WebRequest.Content -split '<td class="header">Length:<\/td>')[1] -split '<\/span>')[0] -split '"text">')[1]
        Write-Output $length
    }
}

function Get-JLDirector {
    param (
        [object]$WebRequest
    )

    process {
        $director = (((($WebRequest.Content -split '<td class="header">Director:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
        $director = Convert-HtmlCharacter -String $director
        Write-Output $director
    }
}

function Get-JLMaker {
    param (
        [object]$WebRequest
    )

    process {
        $maker = (((($WebRequest.Content -split '<td class="header">Maker:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-JLLabel {
    param (
        [object]$WebRequest
    )

    process {
        $label = (((($WebRequest.Content -split '<td class="header">Label:</td>')[1]) -split '<\/a>')[0] -split 'rel="tag">')[1]
        $label = Convert-HtmlCharacter -String $label
        Write-Output $label
    }
}

function Get-JLRating {
    param (
        [object]$WebRequest
    )

    process {
        $rating = (((($WebRequest.Content -split '<td class="header">User Rating:</td>')[1]) -split '<\/span>')[0] -split '<span class="score">')[1]
        $rating = ($rating -replace '\(', '') -replace '\)', ''
        Write-Output $rating
    }
}

function Get-JLGenre {
    param (
        [object]$WebRequest
    )

    begin {
        $genre = @()
    }

    process {
        $genreHtml = ($WebRequest.Content -split '<td class="header">Genre\(s\):<\/td>')[1]
        $genreHtml = ($genreHtml -split '<\/td>')[0]
        $genreHtml = $genreHtml -split 'rel="category tag">'

        foreach ($genres in $genreHtml[1..($genreHtml.Length - 1)]) {
            $genres = ($genres -split '<')[0]
            $genres = Convert-HtmlCharacter -String $genres
            $genre += $genres
        }

        Write-Output $genre
    }
}

function Get-JLActress {
    param (
        [object]$WebRequest
    )

    begin {
        $actress = @()
    }

    process {
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

        Write-Output $actress
    }
}

function Get-JLCoverUrl {
    param (
        [object]$WebRequest
    )

    process {
        $coverUrl = $WebRequest.Images | Where-Object { $_.src -match 'pics.dmm.co.jp\/mono\/movie\/adult' }
        $coverUrl = 'https:' + $coverUrl.src
        Write-Output $coverUrl
    }
}

function Get-JLScreenshotUrl {
    param (
        [object]$WebRequest
    )

    begin {
        $screenshotUrl = @()
    }

    process {
        $screenshotHtml = $WebRequest.Images | Where-Object { $_.src -match 'pics.dmm.co.jp\/digital\/video' }
        $screenshotHtml = $screenshotHtml.src
        if ($null -ne $screenshotHtml) {
            $screenshotHtml = $screenshotHtml -split ' '
            foreach ($screenshot in $screenshotHtml) {
                $url = 'https:' + $screenshot
                $screenshotUrl += $url
            }
        } else {
            $screenshotUrl = $null
        }

        Write-Output $screenshotUrl
    }
}
