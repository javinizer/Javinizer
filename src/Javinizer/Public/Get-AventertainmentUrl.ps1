function Get-AventertainmentUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id
    )


    process {
        $jaPpvUrl = "https://www.aventertainments.com/ppv/ppv_searchproducts.aspx?languageID=1&vodtypeid=1&keyword=$Id"
        $webRequest = Invoke-JVWebRequest -Uri $jaPpvUrl -Method Get -WebSession $session -Verbose:$false

        $searchResults = $webRequest.links.href | Where-Object { $_ -like '*new_detail*' } | Select-Object -Unique

        if ($null -ne $searchResults) {
            $retryCount = 2
            $numResults = $searchResults.Count

            if ($retryCount -gt $numResults) {
                $retryCount = $numResults
            }

            $count = 1
            foreach ($result in $searchResults) {
                $webRequest = Invoke-JVWebRequest -Uri $result -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
                $resultId = Get-AventertainmentId -WebRequest $webRequest

                try {
                    $alternateResultId = ($resultId | Select-String -Pattern '_(.*)').Matches.Groups[1].Value
                } catch {
                    # Do nothing
                }

                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                if ($resultId -eq $Id -or $alternateResultId -eq $Id) {
                    $enAventertainmentUrl = $result
                    break
                }

                if ($count -eq $retryCount) {
                    break
                }

                $count++
            }
        }

        if ($null -eq $enAventertainmentUrl) {
            $enPpvUrl = "https://www.aventertainments.com/ppv/ppv_searchproducts.aspx?languageID=1&vodtypeid=2&keyword=$Id"
            $webRequest = Invoke-JVWebRequest -Uri $enPpvUrl -Method Get -WebSession $session -Verbose:$false

            $searchResults = $webRequest.links.href | Where-Object { $_ -like '*new_detail*' } | Select-Object -Unique

            if ($null -ne $searchResults) {
                $retryCount = 2
                $numResults = $searchResults.Count

                if ($retryCount -gt $numResults) {
                    $retryCount = $numResults
                }

                $count = 1
                foreach ($result in $searchResults) {
                    $webRequest = Invoke-JVWebRequest -Uri $result -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
                    $resultId = Get-AventertainmentId -WebRequest $webRequest

                    try {
                        $alternateResultId = ($resultId | Select-String -Pattern '_(.*)').Matches.Groups[1].Value
                    } catch {
                        # Do nothing
                    }

                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                    if ($resultId -eq $Id -or $alternateResultId -eq $Id) {
                        $enAventertainmentUrl = $result
                        break
                    }

                    if ($count -eq $retryCount) {
                        break
                    }

                    $count++
                }
            }
        }

        if ($null -eq $enAventertainmentUrl) {
            $jaDvdUrl = "https://www.aventertainments.com/search_Products.aspx?languageID=1&dept_id=29&keyword=$Id&searchby=keyword"
            $webRequest = Invoke-JVWebRequest -Uri $jaDvdUrl -Method Get -WebSession $session -Verbose:$false

            $searchResults = $webRequest.links.href | Where-Object { $_ -like '*product_lists*' } | Select-Object -Unique

            if ($null -ne $searchResults) {
                $retryCount = 2
                $numResults = $searchResults.Count

                if ($retryCount -gt $numResults) {
                    $retryCount = $numResults
                }

                $count = 1
                foreach ($result in $searchResults) {
                    $webRequest = Invoke-JVWebRequest -Uri $result -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false

                    $resultId = Get-AventertainmentId -WebRequest $webRequest

                    try {
                        $alternateResultId = ($resultId | Select-String -Pattern '_(.*)').Matches.Groups[1].Value
                    } catch {
                        # Do nothing
                    }

                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                    if ($resultId -eq $Id -or $alternateResultId -eq $Id) {
                        $enAventertainmentUrl = $result
                        break
                    }

                    if ($count -eq $retryCount) {
                        break
                    }

                    $count++
                }
            }
        }

        if ($null -eq $enAventertainmentUrl) {
            $enDvdUrl = "https://www.aventertainments.com/search_Products.aspx?languageID=1&dept_id=43&keyword=$Id&searchby=keyword"
            $webRequest = Invoke-JVWebRequest -Uri $enDvdUrl -Method Get -WebSession $session -Verbose:$false

            $searchResults = $webRequest.links.href | Where-Object { $_ -like '*product_lists*' } | Select-Object -Unique

            if ($null -ne $searchResults) {
                $retryCount = 2
                $numResults = $searchResults.Count

                if ($retryCount -gt $numResults) {
                    $retryCount = $numResults
                }

                $count = 1
                foreach ($result in $searchResults) {
                    $webRequest = Invoke-JVWebRequest -Uri $result -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false

                    $resultId = Get-AventertainmentId -WebRequest $webRequest

                    try {
                        $alternateResultId = ($resultId | Select-String -Pattern '_(.*)').Matches.Groups[1].Value
                    } catch {
                        # Do nothing
                    }

                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"

                    if ($resultId -eq $Id -or $alternateResultId -eq $Id) {
                        $enAventertainmentUrl = $result
                        break
                    }

                    if ($count -eq $retryCount) {
                        break
                    }

                    $count++
                }
            }
        }

        if ($null -eq $enAventertainmentUrl) {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] not matched on AVEntertainment"
            return
        } else {
            $urlObject = [PSCustomObject]@{
                Ja = $enAventertainmentUrl -replace 'languageID=1', 'languageID=2'
                En = $enAventertainmentUrl
            }

            Write-Output $urlObject
        }
    }
}
