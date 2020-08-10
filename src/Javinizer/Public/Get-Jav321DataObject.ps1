function Get-Jav321DataObject {
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
                Source          = 'jav321'
                Url             = $Url
                Id              = Get-Jav321Id -WebRequest $webRequest
                Title           = Get-Jav321Title -WebRequest $webRequest
                Date            = Get-Jav321ReleaseDate -WebRequest $webRequest
                Year            = Get-Jav321ReleaseYear -WebRequest $webRequest
                Runtime         = Get-Jav321Runtime -WebRequest $webRequest
                Maker           = Get-Jav321Maker -WebRequest $webRequest
                Actress         = (Get-Jav321Actress -WebRequest $webRequest).Name
                ActressThumbUrl = (Get-Jav321Actress -WebRequest $webRequest).ThumbUrl
                Genre           = Get-Jav321Genre -WebRequest $webRequest
                CoverUrl        = Get-Jav321CoverUrl -WebRequest $webRequest
                ScreenshotUrl   = Get-Jav321ScreenshotUrl -WebRequest $webRequest
            }

        Write-JLog -Level Debug -Message "Jav321 data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}

function Get-Jav321Id {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $id = ((($WebRequest | ForEach-Object { $_ -split '\n' } |
                        Select-String '<b>品番<\/b>: (.*)<br><b>').Matches.Groups[1].Value -split '<br>')[0]).ToUpper()
        } catch {
            return
        }

        Write-Output $id
    }
}

function Get-Jav321Title {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $title = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<div class="panel-heading"><h3>(.*) <small>').Matches.Groups[1].Value
        } catch {
            return
        }

        $title = Convert-HtmlCharacter -String $title
        Write-Output $title
    }
}

function Get-Jav321ReleaseDate {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $releaseDate = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<b>(.*)<\/b>: (\d{4}-\d{2}-\d{2})<br>').Matches.Groups[2].Value
        } catch {
            return
        }

        Write-Output $releaseDate
    }
}

function Get-Jav321ReleaseYear {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $releaseYear = Get-Jav321ReleaseDate -WebRequest $WebRequest
            $releaseYear = ($releaseYear -split '-')[0]
        } catch {
            return
        }

        Write-Output $releaseYear
    }
}

function Get-Jav321Runtime {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $length = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<b>(.*)<\/b>: (\d{1,3}) minutes<br>').Matches.Groups[2].Value
        } catch {
            return
        }

        Write-Output $length
    }
}

function Get-Jav321Maker {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $maker = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<b>メーカー<\/b>: (.*)>(.*)<\/a><br><b>ジャンル').Matches.Groups[2].Value
        } catch {
            return
        }

        $maker = Convert-HtmlCharacter -String $maker
        Write-Output $maker
    }
}

function Get-Jav321Genre {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $genre = @()

        try {
            $genre = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<a href="\/genre\/(.*)\/(.*)">(.*)<\/a> ').Matches.Groups[0] -split '<\/a>' |
            ForEach-Object { ($_ -split '>')[1] }
        } catch {
            return
        }

        Write-Output $genre
    }
}

function Get-Jav321Actress {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $actress = @()

        try {
            $actress = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<a href="\/star\/(.*)\/(.*)">(.*)<\/a>によって行われる<\/div>').Matches |
            ForEach-Object { $_.Groups[3].Value } |
            Where-Object { $_ -ne '' }

            $actressThumb = ($WebRequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<div class="thumbnail"><a href="/star\/(.*)\/(.*)"><img class="img-responsive" src="(.*)" onerror').Matches |
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

function Get-Jav321CoverUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        try {
            $coverUrl = (($WebRequest | ForEach-Object { $_ -split '\n' } |
                    Select-String -Pattern 'poster="(.*).jpg">').Matches.Groups[1].Value) + '.jpg'
        } catch {
            return
        }

        Write-Output $coverUrl
    }
}

function Get-Jav321ScreenshotUrl {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$WebRequest
    )

    process {
        $screenshotUrl = @()

        try {
            $screenshotUrl = (($WebRequest | ForEach-Object { $_ -split '\n' } |
                    Select-String -Pattern '<a href="\/snapshot\/(.*)\/(.*)\/(.*)"><img class="img-responsive" src="(.*)"') -split "src=\'" |
                Select-String -Pattern "(https:\/\/www.jav321.com\/digital\/video\/(.*)\/(.*).jpg)(.*)<\/a>").Matches |
            ForEach-Object { $_.Groups[1].Value }
        } catch {
            try {
                $screenshotUrl = (($WebRequest | ForEach-Object { $_ -split '\n' } |
                        Select-String -Pattern '<a href="\/snapshot/(.*)\/(.*)\/(.*)"><img class="img-responsive"') -split 'src="' |
                    Select-String -Pattern '(https:\/\/www.jav321.com\/\/images\/(.*)\/(.*)\/(.*)\/(.*).jpg)"><\/a><\/p>').Matches |
                ForEach-Object { $_.Groups[1].Value }
            } catch {
                return
            }
        }

        Write-Output $screenshotUrl
    }
}
