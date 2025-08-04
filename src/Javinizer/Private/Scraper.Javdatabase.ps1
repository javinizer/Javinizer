function Get-JavadatabaseId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $id = ($Webrequest.Content | Select-String '<b>DVD ID: </b>\s*([^<]+)').Matches[0].Groups[1].Value.Trim()
        } catch {
            return
        }

        Write-Output $id
    }
}

function Get-JavadatabaseContentId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $contentId = ($Webrequest.Content | Select-String '<b>Content ID: </b>\s*([^<]+)').Matches[0].Groups[1].Value.Trim()
        } catch {
            return
        }

        Write-Output $contentId
    }
}

function Get-JavadatabaseTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $title = ($Webrequest.Content | Select-String '<b>Title: </b>\s*([^<]+)').Matches[0].Groups[1].Value.Trim()
        } catch {
            return
        }

        $title = Convert-HtmlCharacter -String $title
        Write-Output $title
    }
}

function Get-JavadatabaseReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $releaseDate = ($Webrequest.Content | Select-String -Pattern '<b>Release Date: </b>\s*([^<]+)').Matches[0].Groups[1].Value.Trim()
        } catch {
            return
        }

        Write-Output $releaseDate
    }
}

function Get-JavadatabaseReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $releaseDate = Get-JavadatabaseReleaseDate -WebRequest $Webrequest
        if ($releaseDate) {
            $releaseYear = ($releaseDate -split '-')[0]
            Write-Output $releaseYear
        }
    }
}

function Get-JavadatabaseRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $runtime = ($Webrequest.Content | Select-String -Pattern 'Runtime:.*?(\d+)\s*min').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $runtime
    }
}

function Get-JavadatabaseDirector {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $director = ($Webrequest.Content | Select-String -Pattern 'Director:.*?<a[^>]*>([^<]*)</a>').Matches.Groups[1].Value
        } catch {
            return
        }

        $director = Convert-HtmlCharacter -String $director
        Write-Output $director
    }
}

function Get-JavadatabaseMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $maker = ($Webrequest.Content | Select-String -Pattern 'Studio:.*?<a[^>]*>([^<]*)</a>').Matches.Groups[1].Value
        } catch {
            return
        }

        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-JavadatabaseLabel {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $label = ($Webrequest.Content | Select-String -Pattern 'Label:.*?<a[^>]*>([^<]*)</a>').Matches.Groups[1].Value
        } catch {
            return
        }

        $label = Convert-HtmlCharacter -String $label
        Write-Output $label
    }
}

function Get-JavadatabaseSeries {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $series = ($Webrequest.Content | Select-String -Pattern 'JAV Series:.*?<a[^>]*>([^<]*)</a>').Matches.Groups[1].Value
        } catch {
            return
        }

        $series = Convert-HtmlCharacter -String $series
        Write-Output $series
    }
}

function Get-JavadatabaseActress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $html = $Webrequest.Content
            $actressMatches = [regex]::Matches($html, '<p class="display-6"><a[^>]*href="(?<url>[^"]+/idols/[^"]+/)">(.*?)</a></p>.*?<img[^>]*src="(?<thumb>[^"]+)"[^>]*alt="(?<name>[^"]+)"', 'IgnoreCase')
            $actressArray = @()

            foreach ($match in $actressMatches) {
                $fullName = $match.Groups['name'].Value.Trim()
                $thumb = $match.Groups['thumb'].Value.Trim()
                $url = $match.Groups['url'].Value.Trim()

                # Split name into First & Last
                $nameParts = $fullName -split ' '
                if ($nameParts.Length -eq 2) {
                    $first = $nameParts[0]
                    $last = $nameParts[1]
                } elseif ($nameParts.Length -eq 1) {
                    $first = ''
                    $last = $nameParts[0]
                } else {
                    $first = $nameParts[0]
                    $last = $nameParts[-1]
                }

                $actress = [PSCustomObject]@{
                    FirstName     = $first
                    LastName      = $last
                    JapaneseName  = ""
                    ThumbUrl      = $thumb
                }
                $actressArray += $actress
            }
        } catch {
            return
        }

        Write-Output $actressArray
    }
}

function Get-JavadatabaseGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $genreMatches = ($Webrequest.Content | Select-String -Pattern '<a[^>]*href="[^"]*/genres/[^"]*"[^>]*>([^<]*)</a>' -AllMatches).Matches
            $genreArray = @()
            foreach ($match in $genreMatches) {
                $genre = $match.Groups[1].Value
                $genreArray += $genre
            }
        } catch {
            return
        }

        Write-Output $genreArray
    }
}

function Get-JavadatabaseCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $coverUrl = ($Webrequest.Content | Select-String -Pattern 'id="poster-container"[\s\S]*?<img[^>]*src="([^"]*)"').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $coverUrl
    }
}

function Get-JavadatabaseScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $screenshotMatches = ($Webrequest.Content | Select-String -Pattern '<img[^>]*class="screenshot"[^>]*src="([^"]*)"' -AllMatches).Matches
            $screenshotArray = @()
            foreach ($match in $screenshotMatches) {
                $screenshot = $match.Groups[1].Value
                if ($screenshot -match '^//') {
                    $screenshot = "https:" + $screenshot
                } elseif ($screenshot -match '^/') {
                    $screenshot = "https://javdatabase.com" + $screenshot
                }
                $screenshotArray += $screenshot
            }
        } catch {
            return
        }

        Write-Output $screenshotArray
    }
}

function Get-JavadatabaseTrailerUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $trailerUrl = ($Webrequest.Content | Select-String -Pattern '<video[^>]*><source[^>]*src="([^"]*)"').Matches.Groups[1].Value
            if ($trailerUrl -match '^//') {
                $trailerUrl = "https:" + $trailerUrl
            } elseif ($trailerUrl -match '^/') {
                $trailerUrl = "https://javdatabase.com" + $trailerUrl
            }
        } catch {
            return
        }

        Write-Output $trailerUrl
    }
}

function Get-JavadatabaseRating {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $ratingMatch = ($Webrequest.Content | Select-String -Pattern 'votes, average:.*?(\d+\.?\d*)/10.*?\((\d+)\s*votes?\)')
            $rating = $ratingMatch.Matches.Groups[1].Value
            $votes = $ratingMatch.Matches.Groups[2].Value
        } catch {
            return
        }

        if ($rating -eq 0 -or $rating -eq '') {
            $ratingObject = $null
        } else {
            $ratingObject = [PSCustomObject]@{
                Rating = [math]::round([double]$rating * 2, 2)
                Votes  = $votes
            }
        }

        Write-Output $ratingObject
    }
}
