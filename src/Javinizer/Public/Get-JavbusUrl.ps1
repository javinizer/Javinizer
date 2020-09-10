#Requires -PSEdition Core

function Get-JavbusUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id
    )

    process {
        $searchUrl = "https://www.javbus.com/search/$Id&type=0&parent=uc"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
            $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
        } catch {
            try {
                $searchUrl = "https://www.javbus.com/uncensored/search/$Id&type=0&parent=uc"
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
                $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                try {
                    $searchUrl = "https://www.javbus.org/search/$Id&type=0&parent=uc"
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
                    $webRequest = Invoke-RestMethod -Uri $searchUrl -Method Get -Verbose:$false
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on JavBus"
                    return
                }
            }
        }

        $Tries = 5
        # Get the page search results
        try {
            $searchResults = (($webRequest | ForEach-Object { $_ -split '\n' } | Select-String '<a class="movie-box" href="(.*)">').Matches) | ForEach-Object { $_.Groups[1].Value }
        } catch {
            return
        }
        $numResults = $searchResults.Count

        if ($Tries -gt $numResults) {
            $Tries = $numResults
        }

        if ($numResults -ge 1) {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Searching [$Tries] of [$numResults] results for [$Id]"

            $count = 1
            foreach ($result in $searchResults) {
                try {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                    $webRequest = Invoke-RestMethod -Uri $result -Method Get -Verbose:$false
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occurred on [GET] on URL [$result]: $PSItem"
                }
                $resultId = Get-JavbusId -WebRequest $webRequest
                if ($resultId -eq $Id) {
                    $directUrlZh = "https://" + ($result -split '/')[-2] + "/" + ($result -split '/')[-1]
                    $directUrlJa = "https://" + ($result -split '/')[-2] + "/ja/" + ($result -split '/')[-1]
                    $directUrl = "https://" + ($result -split '/')[-2] + "/en/" + ($result -split '/')[-1]
                    break
                }

                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "Result [$count] is [$resultId]"

                if ($count -eq $Tries) {
                    break
                }

                $count++
            }

            if ($null -eq $directUrl) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on JavBus"
                return
            } else {
                $urlObject = [PSCustomObject]@{
                    En = $directUrl
                    Ja = $directUrlJa
                    Zh = $directUrlZh
                }

                Write-Output $urlObject
            }
        }
    }
}
