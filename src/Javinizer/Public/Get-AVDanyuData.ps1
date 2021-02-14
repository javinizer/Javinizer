function Get-AVDanyuData {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$ContentId,

        [Parameter()]
        [Switch]$AllResults
    )

    process {
        $searchUrl = "https://avdanyuwiki.com/?s=$contentId"
        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$ContentId] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$ContentId] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
        }

        if ($webRequest.Content -notmatch 'NOT FOUND') {
            # This will retrieve and split all results displayed on the search page to parse
            $rawMovies = ($webRequest.Content -split '<h2>')
            $movies = $rawMovies[1..($rawMovies.Length - 1)]

            $searchResults = foreach ($vid in $movies) {
                $vidId = ($vid | Select-String -Pattern '品番：(.*)<').Matches.Groups[1].Value
                $vidActors = (($vid | Select-String -Pattern '出演男優：(.*)<').Matches.Groups[1].Value).Trim()
                $id = $vidId.Trim()
                $actors = $vidActors -split ' '

                $actorObject = foreach ($actor in $actors) {
                    [PSCustomObject]@{
                        FirstName    = $null
                        LastName     = $null
                        JapaneseName = $actor
                        ThumbUrl     = $null
                    }
                }

                [PSCustomObject]@{
                    ContentId = $id
                    Actors    = $actorObject
                }
            }

            # We need to perform a relative match on the ContentId since there are cases where there are numbers preceding the Id
            $matchedResult = $searchResults | Where-Object { $_.ContentId -match "(\d+)?$ContentId" }

            if ($matchedResult.Count -ge 1) {
                # We want to automatically select the first match if there are multiple
                if ($matchedResult.Count -gt 1 -and !($AllResults)) {
                    $matchedResult = $matchedResult[0]
                }

                Write-Output $matchedResult
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$ContentId] [$($MyInvocation.MyCommand.Name)] not matched on avdanyuwiki"
            }
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$ContentId] [$($MyInvocation.MyCommand.Name)] not matched on avdanyuwiki"
        }
    }
}
