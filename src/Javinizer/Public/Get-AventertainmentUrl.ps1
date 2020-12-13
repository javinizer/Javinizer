function Get-AventertainmentUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [String]$Id
    )


    process {
        $jaPpvUrl = "https://www.aventertainments.com/ppv/ppv_searchproducts.aspx?languageID=1&vodtypeid=1&keyword=$Id"

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$jaPpvUrl]"
            $webRequest = Invoke-WebRequest -Uri $jaPpvUrl -Method Get -WebSession $session -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$jaPpvUrl]: $PSItem" -Action 'Continue'
        }

        $searchResults = $webRequest.links.href | Where-Object { $_ -like '*new_detail*' } | Select-Object -Unique

        if ($null -ne $searchResults) {
            $retryCount = 2
            $numResults = $searchResults.Count

            if ($retryCount -gt $numResults) {
                $retryCount = $numResults
            }

            $count = 1
            foreach ($result in $searchResults) {
                try {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                    $webRequest = Invoke-WebRequest -Uri $result -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$result]: $PSItem" -Action 'Continue'
                }

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

            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$enPpvUrl]"
                $webRequest = Invoke-WebRequest -Uri $enPpvUrl -Method Get -WebSession $session -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$enPpvUrl]: $PSItem" -Action 'Continue'
            }

            $searchResults = $webRequest.links.href | Where-Object { $_ -like '*new_detail*' } | Select-Object -Unique

            if ($null -ne $searchResults) {
                $retryCount = 2
                $numResults = $searchResults.Count

                if ($retryCount -gt $numResults) {
                    $retryCount = $numResults
                }

                $count = 1
                foreach ($result in $searchResults) {
                    try {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                        $webRequest = Invoke-WebRequest -Uri $result -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$result]: $PSItem" -Action 'Continue'
                    }

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

            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$jaDvdUrl]"
                $webRequest = Invoke-WebRequest -Uri $jaDvdUrl -Method Get -WebSession $session -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$jaDvdUrl]: $PSItem" -Action 'Continue'
            }

            $searchResults = $webRequest.links.href | Where-Object { $_ -like '*product_lists*' } | Select-Object -Unique

            if ($null -ne $searchResults) {
                $retryCount = 2
                $numResults = $searchResults.Count

                if ($retryCount -gt $numResults) {
                    $retryCount = $numResults
                }

                $count = 1
                foreach ($result in $searchResults) {
                    try {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                        $webRequest = Invoke-WebRequest -Uri $result -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$result]: $PSItem" -Action 'Continue'
                    }

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

            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$enDvdUrl]"
                $webRequest = Invoke-WebRequest -Uri $enDvdUrl -Method Get -WebSession $session -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$enDvdUrl]: $PSItem" -Action 'Continue'
            }

            $searchResults = $webRequest.links.href | Where-Object { $_ -like '*product_lists*' } | Select-Object -Unique

            if ($null -ne $searchResults) {
                $retryCount = 2
                $numResults = $searchResults.Count

                if ($retryCount -gt $numResults) {
                    $retryCount = $numResults
                }

                $count = 1
                foreach ($result in $searchResults) {
                    try {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                        $webRequest = Invoke-WebRequest -Uri $result -WebSession:$Session -UserAgent:$Session.UserAgent -Method Get -Verbose:$false
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured on [GET] on URL [$result]: $PSItem" -Action 'Continue'
                    }

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
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] not matched on AVEntertainment"
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
