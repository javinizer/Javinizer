function Get-JavbusId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $id = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<title>(.*?) (.*?) - JavBus<\/title>').Matches.Groups[1].Value
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
            return
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
                Select-String -Pattern '<p><span class="header">(.*)<\/span> <a href="https:\/\/www\.javbus\.(com|org)\/(.*)\/director\/(.*)">(.*)<\/a><\/p>').Matches.Groups[5].Value
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
                Select-String -Pattern '<p><span class="header">(.*)<\/span> <a href="https:\/\/www\.javbus\.(com|org)\/(.*)\/label\/(.*)">(.*)<\/a>').Matches.Groups[5].Value
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
                Select-String -Pattern '<p><span class="header">(.*)<\/span> <a href="https:\/\/www.javbus.(com|org)/(.*)/series/(.*)">(.*)<\/a>').Matches.Groups[5].Value
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
                Select-String '<span class="genre"><a href="(.*)\/genre\/(.*)">(.*)<\/a><\/span>').Matches |
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
            try {
                $actresses = ($Webrequest | Select-String -AllMatches -Pattern '<a href="https:\/\/www\.javbus\.com\/(?:.*)\/star\/(?:.*)"><img src="(.*)" title="(.*)"><\/a>').Matches
            } catch {
                return
            }

            foreach ($actress in $actresses) {
                $thumbUrl = $actress.Groups[1].Value
                if ($thumbUrl -like '*nowprinting*' -or $thumbUrl -like '*now_printing*') {
                    $thumbUrl = $null
                }

                # Match if the name contains Japanese characters
                if ($actress.Groups[2].Value -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                    $movieActressObject += [PSCustomObject]@{
                        LastName     = $null
                        FirstName    = $null
                        JapaneseName = $actress.Groups[2].Value
                        ThumbUrl     = $thumbUrl
                    }
                } else {
                    $firstName = ($actress.Groups[2].Value -split ' ')[1]
                    if ($null -ne $firstName) {
                        $firstName = $textInfo.ToTitleCase($firstName.ToLower())
                    }

                    $lastName = ($actress.Groups[2].Value -split ' ')[0]
                    if ($null -ne $lastName) {
                        $lastName = $textInfo.ToTitleCase($lastName.ToLower())
                    }

                    $movieActressObject += [PSCustomObject]@{
                        LastName     = $lastName
                        FirstName    = $firstName
                        JapaneseName = $null
                        ThumbUrl     = $thumbUrl
                    }
                }
            }
        } catch {
            Write-Error $_
            return
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
            $screenshotUrl = (($Webrequest | ForEach-Object { $_ -split '\n' } |
                    Select-String -Pattern 'href="(https:\/\/images\.javbus\.(com|org)\/bigsample\/(.*))">') -split '<a class="sample-box"' |
                Select-String -Pattern '(https:\/\/images\.javbus\.(com|org)\/bigsample\/(.*).jpg)">').Matches |
            ForEach-Object { $_.Groups[1].Value }
        } catch {
            return
        }

        Write-Output $screenshotUrl
    }
}
