function Get-JavadatabaseUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter()]
        [Switch]$AllResults
    )

    process {
        $searchUrl = "https://www.javdatabase.com/?post_type=movies%2Cuncensored&s=$Id"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            try {
                Start-Sleep -Seconds 3
                $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
            }
        }

        try {
            $results = ($webRequest.Content | Select-String -Pattern '<div[^>]*class="mt-auto"[^>]*>[\s\S]*?<a\s+href="(?<url>[^"]+/movies/(?<id>[^/]+)/)"[^>]*class="cut-text"[^>]*>\s*(?<title>[\s\S]*?)\s*</a>[\s\S]*?</div>' -AllMatches).Matches
            $resultObject = $results | ForEach-Object {
                [PSCustomObject]@{
                    Id    = $_.Groups[2].Value.ToUpper()
                    Title = $_.Groups[3].Value
                    Url   = $_.Groups[1].Value
                }
            }
        } catch {
            # Do nothing
        }

        if ($Id -in $resultObject.Id) {
            $matchedResult = $resultObject | Where-Object { $Id -eq $_.Id }

            if ($matchedResult.Count -gt 1 -and !($AllResults)) {
                $matchedResult = $matchedResult[0]
            }

            $urlObject = foreach ($entry in $matchedResult) {
                [PSCustomObject]@{
                    Url   = $entry.Url
                    Id    = $entry.Id
                    Title = $entry.Title
                }
            }

            Write-Output $urlObject
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on Javdatabase"
            return
        }
    }
}
