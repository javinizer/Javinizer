function Get-MgstageUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id,

        [Parameter()]
        [Switch]$AllResults
    )

    begin {
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $cookie = New-Object System.Net.Cookie
        $cookie.Name = 'adc'
        $cookie.Value = '1'
        $cookie.Domain = '.mgstage.com'
        $session.Cookies.Add($cookie)
    }

    process {
        $searchUrl = "https://www.mgstage.com/search/cSearch.php?search_word=$Id"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -WebSession $session -Verbose:$false
        } catch {
            try {
                Start-Sleep -Seconds 3
                $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -WebSession $session -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem" -Action 'Continue'
            }
        }

        try {
            $rawHtml = $webRequest.Content -split '<p class="tag">'

            if ($rawHtml.Count -gt 1) {
                $results = $rawHtml[1..($rawHtml.Count - 1)]
                $resultObject = $results | ForEach-Object {
                    [PSCustomObject]@{
                        Id    = (($_ -split '<a href="\/product\/product_detail\/')[1] -split '\/">')[0]
                        Title = (($_ -split '<p class="title lineclamp">')[1] -split '<\/p>')[0]
                        Url   = "https://www.mgstage.com" + (($_ -split '<a href="')[1] -split '\/">')[0]
                    }
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
                    Ja    = $entry.Url
                    Id    = $entry.Id
                    Title = $entry.Title
                }
            }

            Write-Output $urlObject
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on Mgstage"
            return
        }
    }
}
