#Requires -PSEdition Core

function Get-MgstageUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id
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

        $searchResults = $webRequest.Links.href | Where-Object { $_ -like '/product/product_detail/*' } | Select-Object -Unique | ForEach-Object { "https://www.mgstage.com" + $_ }

        if ($null -ne $searchResults) {
            $retryCount = 3
            $numResults = $searchResults.count

            if ($retryCount -gt $numResults) {
                $retryCount = $numResults
            }

            if ($numResults -ge 1) {
                $count = 1
                foreach ($result in $searchResults) {
                    try {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                        $webRequest = Invoke-WebRequest -Uri $result -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$result]: $PSItem" -Action 'Continue'
                    }

                    $resultId = Get-MgstageId -WebRequest $webRequest

                    try {
                        $alternateResultId = ($resultId | Select-String -Pattern '\d*(.*)').Matches.Groups[1].Value
                    } catch {
                        return
                    }

                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                    if ($resultId -eq $Id -or $alternateResultId -eq $Id) {
                        $mgstageUrlJa = $result
                        break
                    }

                    if ($count -eq $retryCount) {
                        break
                    }

                    $count++
                }
            }
        }

        if ($null -eq $mgstageUrlJa) {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on Mgstage"
            return
        } else {
            $urlObject = [PSCustomObject]@{
                Ja = $mgstageUrlJa
            }

            Write-Output $urlObject
        }
    }
}
