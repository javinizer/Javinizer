function Get-JavbusDataObject {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Position = 0)]
        [string]$Name,
        [Parameter(Position = 1)]
        [string]$Url
    )

    begin {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        $movieDataObject = @()
    }

    process {
        if ($Url) {
            $javbusUrl = $Url
        } else {
            $javbusUrl = Get-JavbusUrl -Name $Name

        }

        if ($null -ne $javbusUrl) {
            try {
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [GET] on Uri [$javbusUrl]"
                $webRequest = Invoke-RestMethod -Uri $javbusUrl
                $movieDataObject = [pscustomobject]@{
                    Source        = 'javbus'
                    Url           = $javbusUrl
                    Id            = Get-JavbusId -WebRequest $webRequest
                    Title         = Get-JavbusTitle -WebRequest $webRequest
                    Date          = Get-JavbusReleaseDate -WebRequest $webRequest
                    Year          = Get-JavbusReleaseYear -WebRequest $webRequest
                    Runtime       = Get-JavbusRuntime -WebRequest $webRequest
                    Director      = Get-JavbusDirector -WebRequest $webRequest
                    Maker         = Get-JavbusMaker -WebRequest $webRequest
                    Label         = Get-JavbusLabel -WebRequest $webRequest
                    Rating        = Get-JavbusRating -WebRequest $webRequest
                    Actress       = Get-JavbusActress -WebRequest $webRequest
                    Genre         = Get-JavbusGenre -WebRequest $webRequest
                    CoverUrl      = Get-JavbusCoverUrl -WebRequest $webRequest
                    ScreenshotUrl = Get-JavbusScreenshotUrl -WebRequest $webRequest
                }
            } catch {
                throw $_
            }
        } else {
            Write-Verbose "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Search [$Name] not matched on Javbus"
            return
        }

        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] JavBus data object:"
        $movieDataObject | Format-List | Out-String | Write-Debug
        Write-Output $movieDataObject
    }

    end {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

function Get-JavbusId {
    param (
        [object]$WebRequest
    )

    process {
        $id = ($WebRequest | ForEach-Object { $_ -split '\n' } |
            Select-String '<title>(.*?) (.*?) - JavBus<\/title>').Matches.Groups[1].Value

        Write-Output $id
    }
}

function Get-JavbusTitle {
    param (
        [object]$WebRequest
    )
    process {
        $title = ($WebRequest | ForEach-Object { $_ -split '\n' } |
            Select-String '<title>(.*?) (.*?) - JavBus<\/title>').Matches.Groups[2].Value

        $title = Convert-HtmlCharacter -String $title
        Write-Output $title
    }
}

function Get-JavbusReleaseDate {
    param (
        [object]$WebRequest
    )

    process {
        $releaseDate = ($WebRequest | ForEach-Object { $_ -split '\n' } |
            Select-String '<p><span class="header">(.*):<\/span> (\d{4}-\d{2}-\d{2})<\/p>').Matches.Groups[2].Value

        Write-Output $releaseDate
    }
}

function Get-JavbusReleaseYear {
    param (
        [object]$WebRequest
    )

    process {
        $releaseYear = Get-JavbusReleaseDate -WebRequest $WebRequest
        $releaseYear = ($releaseYear -split '-')[0]

        Write-Output $releaseYear
    }
}

function Get-JavbusRuntime {
    param (
        [object]$WebRequest
    )

    process {
        $length = ($WebRequest | ForEach-Object { $_ -split '\n' } |
            Select-String '<p><span class="header">(.*):<\/span> (\d{1,3})(.*)<\/p>').Matches[1].Groups[2].Value

        Write-Output $length
    }
}

function Get-JavbusDirector {
    param (
        [object]$WebRequest
    )

    process {
        $director = ($WebRequest | ForEach-Object { $_ -split '\n' } |
            Select-String -Pattern '<p><span class="header">(.*)<\/span> <a href="https:\/\/www\.javbus\.com\/(.*)\/director\/(.*)">(.*)<\/a><\/p>').Matches.Groups[4].Value

        $director = Convert-HtmlCharacter -String $director
        Write-Output $director
    }
}

function Get-JavbusMaker {
    param (
        [object]$WebRequest
    )

    process {
        $maker = ($WebRequest | ForEach-Object { $_ -split '\n' } |
            Select-String '<p><span class="header">(.*)<\/span> <a href="https:\/\/www\.javbus\.com\/(.*)">(.*)<\/a>').Matches.Groups[3].Value

        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-JavbusLabel {
    param (
        [object]$WebRequest
    )

    process {
        $label = ($WebRequest | ForEach-Object { $_ -split '\n' } |
            Select-String -Pattern '<p><span class="header">(.*)<\/span> <a href="https:\/\/www\.javbus\.com\/(.*)\/label\/(.*)">(.*)<\/a>').Matches.Groups[4].Value

        $label = Convert-HtmlCharacter -String $label
        Write-Output $label
    }
}

function Get-JavbusRating {
    param (
        [object]$WebRequest
    )

    process {
        # Write-Output $rating
    }
}

function Get-JavbusGenre {
    param (
        [object]$WebRequest
    )

    begin {
        $genre = @()
    }

    process {
        $genre = ($WebRequest | ForEach-Object { $_ -split '\n' } |
            Select-String '<span class="genre"><a href="(.*)\/genre\/(.*)">(.*)<\/a><\/span>').Matches |
        ForEach-Object { $_.Groups[3].Value }

        Write-Output $genre
    }
}

function Get-JavbusActress {
    param (
        [object]$WebRequest
    )

    begin {
        $actress = @()
    }

    process {
        $actress = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                    Select-String '<a href="(.*)\/star\/(.*)">(.*)<\/a>').Matches |
                ForEach-Object { $_.Groups[3].Value } |
            Where-Object { $_ -ne '' } |
        Select-Object -Unique

        Write-Output $actress
    }
}

function Get-JavbusCoverUrl {
    param (
        [object]$WebRequest
    )

    process {
        $coverUrl = ($WebRequest | ForEach-Object { $_ -split '\n' } |
            Select-String -Pattern "var img = '(.*)';").Matches.Groups[1].Value

        Write-Output $coverUrl
    }
}

function Get-JavbusScreenshotUrl {
    param (
        [object]$WebRequest
    )

    begin {
        $screenshotUrl = @()
    }

    process {
        $screenshotUrl = (($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String -Pattern 'href="(https:\/\/images\.javbus\.com\/bigsample\/(.*))">') -split '<a class="sample-box"' |
            Select-String -Pattern '(https:\/\/images\.javbus\.com\/bigsample\/(.*).jpg)">').Matches |
        ForEach-Object { $_.Groups[1].Value }

        Write-Output $screenshotUrl
    }
}
