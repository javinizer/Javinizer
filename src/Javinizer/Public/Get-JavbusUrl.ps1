function Get-JavbusUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter()]
        [Switch]$AllResults
    )

    process {
        $searchUrl = "https://www.javbus.com/search/$Id&type=0&parent=uc"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            # Do nothing
        }

        $rawHtml = ($webRequest -split '<a class="movie-box"')

        if ($rawHtml.Count -gt 1) {
            $results = $rawHtml[1..($rawHtml.Count - 1)]

            $resultObject = $results | ForEach-Object {
                [PSCustomObject]@{
                    Id    = (($_ -split '<date>')[1] -split '<\/date>')[0]
                    Title = (($_ -split 'title="')[1] -split '">')[0]
                    Url   = (($_ -split 'href="')[1] -split '">')[0]
                }
            }
        }

        if ($Id -notin $resultObject.Id) {
            try {
                $searchUrl = "https://www.javbus.com/uncensored/search/$Id&type=0&parent=uc"
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
                $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                # Do nothing
            }

            $rawHtml = ($webRequest -split '<a class="movie-box"')

            if ($rawHtml.Count -gt 1) {
                $results = $rawHtml[1..($rawHtml.Count - 1)]

                $resultObject = $results | ForEach-Object {
                    [PSCustomObject]@{
                        Id    = (($_ -split '<date>')[1] -split '<\/date>')[0]
                        Title = (($_ -split 'title="')[1] -split '">')[0]
                        Url   = (($_ -split 'href="')[1] -split '">')[0]
                    }
                }
            }
        }

        if ($Id -notin $resultObject.Id) {
            try {
                $searchUrl = "https://www.javbus.com/uncensored/search/$Id&type=0&parent=uc"
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
                $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                # Do nothing
            }

            $rawHtml = ($webRequest -split '<a class="movie-box"')

            if ($rawHtml.Count -gt 1) {
                $results = $rawHtml[1..($rawHtml.Count - 1)]

                $resultObject = $results | ForEach-Object {
                    [PSCustomObject]@{
                        Id    = (($_ -split '<date>')[1] -split '<\/date>')[0]
                        Title = (($_ -split 'title="')[1] -split '">')[0]
                        Url   = (($_ -split 'href="')[1] -split '">')[0]
                    }
                }
            }
        }

        if ($Id -notin $resultObject.Id) {
            try {
                $searchUrl = "https://www.javbus.org/search/$Id&type=0&parent=uc"
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
                $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                # Do nothing
            }

            $rawHtml = ($webRequest -split '<a class="movie-box"')

            if ($rawHtml.Count -gt 1) {
                $results = $rawHtml[1..($rawHtml.Count - 1)]

                $resultObject = $results | ForEach-Object {
                    [PSCustomObject]@{
                        Id    = (($_ -split '<date>')[1] -split '<\/date>')[0]
                        Title = (($_ -split 'title="')[1] -split '">')[0]
                        Url   = (($_ -split 'href="')[1] -split '">')[0]
                    }
                }
            }
        }

        if ($Id -in $resultObject.Id) {
            $matchedResult = $resultObject | Where-Object { $Id -eq $_.Id }

            if ($matchedResult.Count -gt 1 -and !($AllResults)) {
                $matchedResult = $matchedResult[0]
            }

            $urlObject = foreach ($entry in $matchedResult) {
                [PSCustomObject]@{
                    En    = $entry.Url -replace "javbus.com/", "javbus.com/en/"
                    Ja    = $entry.Url -replace "javbus.com/", "javbus.com/ja/"
                    Zh    = $entry.Url
                    Id    = $entry.Id
                    Title = $entry.Title
                }
            }

            Write-Output $urlObject
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] not matched on JavBus"
            return
        }
    }
}
