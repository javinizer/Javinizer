#Requires -PSEdition Core

function Get-Jav321Url {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id
    )

    process {
        $searchUrl = "https://jp.jav321.com/search"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Post -Body "sn=$Id" -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$searchUrl]: $PSItem"
        }


        $Tries = 5
        # Get the page search results
        $searchResults = $webRequest.Links.OuterHtml | Where-Object { $_ -match 'jav321.com/video/' } |
        Select-String -Pattern 'jav321.com/video/(.*)" target' |
        ForEach-Object { $_.Matches.Groups[1].Value } |
        Select-Object -Unique

        $numResults = $searchResults.Count

        if ($Tries -gt $numResults) {
            $Tries = $numResults
        }

        if ($numResults -ge 1) {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Searching [$Tries] of [$numResults] results for [$Id]"

            $count = 1
            foreach ($result in $searchResults) {
                $result = "https://jp.jav321.com/video/$result"
                try {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                    $webRequest = Invoke-RestMethod -Uri $result -Method Get -Verbose:$false
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$result]: $PSItem"
                }

                $resultId = Get-Jav321Id -WebRequest $webRequest
                if ($resultId -eq $Id) {
                    $directUrl = $result
                    break
                }

                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"
                if ($count -eq $Tries) {
                    break
                }

                $count++
            }

            if ($null -eq $directUrl) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] Search [$Id] not matched on Jav321"
                return
            } else {
                $urlObject = [PSCustomObject]@{
                    Url      = $directUrl
                    Language = 'ja'
                }
                Write-Output $urlObject
            }
        } else {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] Search [$Id] not matched on Jav321"
            return
        }
    }
}
