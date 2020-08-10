function Get-JavbusDataObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Url
    )

    process {
        $movieDataObject = @()


        try {
            Write-JLog -Level Debug -Message "Performing [GET] on URL [$Url]"
            $webRequest = Invoke-RestMethod -Uri $Url -Verbose:$false
        } catch {
            Write-JLog -Level Error -Message "Error [GET] on URL [$Url]: $PSItem"
        }

        $movieDataObject = [pscustomobject]@{
            Source          = 'javbus'
            Url             = $Url
            Id              = Get-JavbusId -WebRequest $webRequest
            Title           = Get-JavbusTitle -WebRequest $webRequest
            Date            = Get-JavbusReleaseDate -WebRequest $webRequest
            Year            = Get-JavbusReleaseYear -WebRequest $webRequest
            Runtime         = Get-JavbusRuntime -WebRequest $webRequest
            Director        = Get-JavbusDirector -WebRequest $webRequest
            Maker           = Get-JavbusMaker -WebRequest $webRequest
            Label           = Get-JavbusLabel -WebRequest $webRequest
            Series          = Get-JavbusSeries -WebRequest $webRequest
            Rating          = Get-JavbusRating -WebRequest $webRequest
            Actress         = (Get-JavbusActress -WebRequest $webRequest).Name
            ActressThumbUrl = (Get-JavbusActress -WebRequest $webRequest).ThumbUrl
            Genre           = Get-JavbusGenre -WebRequest $webRequest
            CoverUrl        = Get-JavbusCoverUrl -WebRequest $webRequest
            ScreenshotUrl   = Get-JavbusScreenshotUrl -WebRequest $webRequest
        }

        Write-JLog -Level Debug -Message "JavBus data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}

function Get-JavbusId {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $id = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )
    process {
        try {
            $title = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )

    process {
        try {
            $releaseDate = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )

    process {
        try {
            $releaseYear = Get-JavbusReleaseDate -WebRequest $WebRequest
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
        [object]$WebRequest
    )

    process {
        try {
            $length = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )

    process {
        try {
            $director = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )

    process {
        try {
            $maker = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )

    process {
        try {
            $label = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )

    process {
        try {
            $series = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )

    process {
        # Write-Output $rating
    }
}

function Get-JavbusGenre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $genre = @()
        try {
            $genre = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )

    process {
        $actress = @()

        try {
            $actress = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<a href="(.*)\/star\/(.*)">(.*)<\/a>').Matches |
            ForEach-Object { $_.Groups[3].Value } |
            Where-Object { $_ -ne '' } |
            Select-Object -Unique

            $actressThumb = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<a href="(.*)\/star\/(.*)"><img src="(.*)" title="(.*)"><\/a>').Matches |
            ForEach-Object { $_.Groups[3].Value } |
            Where-Object { $_ -ne '' }


            $movieActressObject = [pscustomobject]@{
                Name     = $actress
                ThumbUrl = $actressThumb
            }
        } catch {
            return
        }

        Write-Output $movieActressObject
    }
}

function Get-JavbusCoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $coverUrl = ($WebRequest | ForEach-Object { $_ -split '\n' } |
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
        [object]$WebRequest
    )

    process {
        $screenshotUrl = @()

        try {
            $screenshotUrl = (($WebRequest | ForEach-Object { $_ -split '\n' } |
                    Select-String -Pattern 'href="(https:\/\/images\.javbus\.(com|org)\/bigsample\/(.*))">') -split '<a class="sample-box"' |
                Select-String -Pattern '(https:\/\/images\.javbus\.(com|org)\/bigsample\/(.*).jpg)">').Matches |
            ForEach-Object { $_.Groups[1].Value }
        } catch {
            return
        }

        Write-Output $screenshotUrl
    }
}
