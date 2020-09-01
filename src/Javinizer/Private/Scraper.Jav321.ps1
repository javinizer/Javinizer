function Get-Jav321Id {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Object]$Webrequest
    )

    process {
        try {
            $id = ((($Webrequest | ForEach-Object { $_ -split '\n' } |
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
        [Object]$Webrequest
    )

    process {
        try {
            $title = ($Webrequest | ForEach-Object { $_ -split '\n' } |
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
        [Object]$Webrequest
    )

    process {
        try {
            $releaseDate = ($Webrequest | ForEach-Object { $_ -split '\n' } |
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
        [Object]$Webrequest
    )

    process {
        try {
            $releaseYear = Get-Jav321ReleaseDate -WebRequest $Webrequest
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
        [Object]$Webrequest
    )

    process {
        try {
            $length = ($Webrequest | ForEach-Object { $_ -split '\n' } |
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
        [Object]$Webrequest
    )

    process {
        try {
            $maker = ($Webrequest | ForEach-Object { $_ -split '\n' } |
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
        [Object]$Webrequest
    )

    process {
        $genre = @()

        try {
            $genre = ($Webrequest | ForEach-Object { $_ -split '\n' } |
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
        [Object]$Webrequest
    )

    process {
        $actress = @()

        try {
            $actress = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<a href="\/star\/(.*)\/(.*)">(.*)<\/a>によって行われる<\/div>').Matches |
            ForEach-Object { $_.Groups[3].Value } |
            Where-Object { $_ -ne '' }

            $actressThumb = ($Webrequest | ForEach-Object { $_ -split '\n' } |
                Select-String '<div class="thumbnail"><a href="/star\/(.*)\/(.*)"><img class="img-responsive" src="(.*)" onerror').Matches |
            ForEach-Object { $_.Groups[3].Value } |
            Where-Object { $_ -ne '' }


            $movieActressObject = [PSCustomObject]@{
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
        [Object]$Webrequest
    )

    process {
        try {
            $coverUrl = (($Webrequest | ForEach-Object { $_ -split '\n' } |
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
        [Object]$Webrequest
    )

    process {
        $screenshotUrl = @()

        try {
            $screenshotUrl = (($Webrequest | ForEach-Object { $_ -split '\n' } |
                    Select-String -Pattern '<a href="\/snapshot\/(.*)\/(.*)\/(.*)"><img class="img-responsive" src="(.*)"') -split "src=\'" |
                Select-String -Pattern "(https:\/\/www.jav321.com\/digital\/video\/(.*)\/(.*).jpg)(.*)<\/a>").Matches |
            ForEach-Object { $_.Groups[1].Value }
        } catch {
            try {
                $screenshotUrl = (($Webrequest | ForEach-Object { $_ -split '\n' } |
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
