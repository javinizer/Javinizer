function Get-JavbusId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $id = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<title>(.*?) (.*?)').Matches.Groups[1].Value
        } catch {
            return
        }

        Write-Output $id
    }
}

function Get-JavbusTitle {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )
    process {
        try {
            $title = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<title>(.*?) (.*?) - JavBus<\/title>').Matches.Groups[2].Value
        } catch {
            try {
                $titleStart = ($Webrequest | ForEach-Object { $_ -split '\n' } | Select-String '<title>(.*?) (.*)').Matches.Groups[2].Value
                $titleEnd = ($Webrequest | ForEach-Object { $_ -split '\n' } | Select-String '(.*?) - JavBus<\/title>').Matches.Groups[1].Value
                $title = $titleStart + $titleEnd
            } catch {
                return
            }
        }

        $title = Convert-HtmlCharacter -String $title
        Write-Output $title
    }
}

function Get-JavbusReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $releaseDate = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<p><span class="header">(.*):<\/span> (\d{4}-\d{2}-\d{2})<\/p>').Matches.Groups[2].Value
        } catch {
            return
        }

        Write-Output $releaseDate
    }
}

function Get-JavbusReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $releaseYear = Get-JavbusReleaseDate -WebRequest $Webrequest
            $releaseYear = ($releaseYear -split '-')[0]
        } catch {
            return
        }

        Write-Output $releaseYear
    }
}

function Get-JavbusRuntime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $length = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<p><span class="header">(.*):<\/span> (\d{1,3})(.*)<\/p>').Matches[1].Groups[2].Value
        } catch {
            return
        }

        Write-Output $length
    }
}

function Get-JavbusDirector {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $director = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String -Pattern '<p><span class="header">(.*)<\/span> <a href="https:\/\/www\.javbus\.(com|org)\/?(.*)?\/director\/(.*)">(.*)<\/a><\/p>').Matches.Groups[5].Value
        } catch {
            return
        }

        if ($null -ne $director) {
            $director = Convert-HtmlCharacter -String $director
            Write-Output $director
        }
    }
}

function Get-JavbusMaker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $maker = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<p><span class="header">(.*)<\/span> <a href="https:\/\/www\.javbus\.(com|org)\/(.*)">(.*)<\/a>').Matches.Groups[4].Value
        } catch {
            return
        }

        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-JavbusLabel {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $label = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String -Pattern '<p><span class="header">(.*)<\/span> <a href="https:\/\/www\.javbus\.(com|org)\/?(.*)?\/label\/(.*)">(.*)<\/a>').Matches.Groups[5].Value
        } catch {
            return
        }

        $label = Convert-HtmlCharacter -String $label
        Write-Output $label
    }
}

function Get-JavbusSeries {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $series = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String -Pattern '<p><span class="header">(.*)<\/span> <a href="https:\/\/www.javbus.(com|org)/?(.*)?/series/(.*)">(.*)<\/a>').Matches.Groups[5].Value
        } catch {
            return
        }

        $series = Convert-HtmlCharacter -String $series
        Write-Output $series
    }
}

function Get-JavbusRating {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        # Write-Output $rating
    }
}

function Get-JavbusGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $genre = @()
        try {
            $genre = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<a href="(.*)\/genre\/(.*)">(.*)<\/a><\/label><\/span>').Matches |
            ForEach-Object { $_.Groups[3].Value }
        } catch {
            return
        }

        Write-Output $genre
    }
}

function Get-JavbusActress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $actresses = @()
        $movieActressObject = @()
        $textInfo = (Get-Culture).TextInfo

        try {
            $actresses = ($Webrequest | Select-String -AllMatches -Pattern '<a href="(.*)\/star\/(.*)"><img src="(.*)" title="(.*)"><\/a>').Matches
        } catch {
            return
        }

        foreach ($actress in $actresses) {
            $baseUrl = ($actress.Groups[1].Value) -replace '/ja', '' -replace '/en', ''
            if ($baseUrl -match '/uncensored') {
                $enActressUrl = "https://www.javbus.com/en/uncensored/star/$($actress.Groups[2].Value)"
                $jaActressUrl = "https://www.javbus.com/ja/uncensored/star/$($actress.Groups[2].Value)"
            } else {
                $enActressUrl = "$baseUrl/en/star/$($actress.Groups[2].Value)"
                $jaActressUrl = "$baseUrl/ja/star/$($actress.Groups[2].Value)"
            }

            $actressName = $actress.Groups[4].Value
            $thumbUrl = $actress.Groups[3].Value
            if ($thumbUrl -like '*nowprinting*' -or $thumbUrl -like '*now_printing*') {
                $thumbUrl = $null
            }

            # Match if the name contains Japanese characters
            if ($actressName -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                try {
                    $wr = Invoke-RestMethod -Uri $enActressUrl | Out-Null
                    $enActressName = (($wr | Select-String -Pattern '<title>(.*)<\/title>').Matches.Groups[1].Value -split '-')[0].Trim()
                } catch {
                    $enActressName = $null
                }

                if ($enActressName -notmatch '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                    $nameParts = ($enActressName -split ' ').Count
                    if ($nameParts -eq 1) {
                        $lastName = $null
                        $firstName = $enActressName
                    } else {
                        if ($wr -match 'D\.O\.B:') {
                            $lastName = ($enActressName -split ' ')[0]
                            $firstName = ($enActressName -split ' ')[1]
                        } else {
                            $lastName = ($enActressName -split ' ')[1]
                            $firstName = ($enActressName -split ' ')[0]
                        }
                    }

                    if ($null -ne $firstName) {
                        $firstName = $textInfo.ToTitleCase($firstName.ToLower())
                    }

                    if ($null -ne $lastName) {
                        $lastName = $textInfo.ToTitleCase($lastName.ToLower())
                    }
                } else {
                    $lastName = $null
                    $firstName = $null
                }

                $movieActressObject += [PSCustomObject]@{
                    LastName     = $lastName
                    FirstName    = $firstName
                    JapaneseName = $actressName
                    ThumbUrl     = $thumbUrl
                }
            } else {
                try {
                    $jaActressName = ((Invoke-RestMethod -Uri $jaActressUrl | Select-String -Pattern '<title>(.*)<\/title>').Matches.Groups[1].Value -split '-')[0].Trim()
                } catch {
                    $jaActressName = $null
                }

                $nameParts = ($actressName -split ' ').Count
                if ($nameParts -eq 1) {
                    $lastName = $null
                    $firstName = $actressName
                } else {
                    if ($wr -match 'D\.O\.B:') {
                        $lastName = ($actressName -split ' ')[0]
                        $firstName = ($actressName -split ' ')[1]
                    } else {
                        $lastName = ($actressName -split ' ')[1]
                        $firstName = ($actressName -split ' ')[0]
                    }
                }

                if ($null -ne $firstName) {
                    $firstName = $textInfo.ToTitleCase($firstName.ToLower())
                }

                if ($null -ne $lastName) {
                    $lastName = $textInfo.ToTitleCase($lastName.ToLower())
                }

                $movieActressObject += [PSCustomObject]@{
                    LastName     = $lastName
                    FirstName    = $firstName
                    JapaneseName = $jaActressName
                    ThumbUrl     = 'https://www.javbus.com' + $thumbUrl
                }
            }
        }

        Write-Output $movieActressObject
    }
}

function Get-JavbusCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $coverUrl = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String -Pattern "var img = '(.*)';").Matches.Groups[1].Value

            $coverUrl = 'https://www.javbus.com' + $coverUrl
        } catch {
            return
        }

        Write-Output $coverUrl
    }
}

function Get-JavbusScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        $screenshotUrl = @()

        try {
            $screenshots = ($Webrequest -split '<a class="sample-box"')
            $screenshots = $screenshots[1..$screenshots.Count] | ForEach-Object { ($_ | Select-String -Pattern 'href="(.*)"><div class=').Matches }
            $screenshotUrl += ($screenshots | ForEach-Object { if ($_.Groups[1].Value -match '"') { ($_.Groups[1].Value -split '"')[0] } else { $_.Groups[1].Value } })
        } catch {
            return
        }

        Write-Output $screenshotUrl
    }
}
