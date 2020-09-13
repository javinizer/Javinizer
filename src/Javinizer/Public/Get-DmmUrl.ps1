#Requires -PSEdition Core

function Get-DmmUrl {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$Id,

        [Parameter()]
        [string]$r18Url
    )

    process {
        $originalId = $Id
        if ($r18Url) {
            $r18Id = (($r18Url -split 'id=')[1] -split '\/')[0]
            $directUrl = "https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=$r18Id"
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$originalId] [$($MyInvocation.MyCommand.Name)] Converting R18 Id to Dmm: [$r18Id] -> [$directUrl]"
        } else {
            # Convert the movie Id (ID-###) to content Id (ID00###) to match dmm naming standards
            if ($Id -match '([a-zA-Z|tT28|rR18]+-\d+z{0,1}Z{0,1}e{0,1}E{0,1})') {
                $splitId = $Id -split '-'
                if (($splitId[1])[-1] -match '\D') {
                    $appendChar = ($splitId[1])[-1]
                    $splitId[1] = $splitId[1] -replace '\D', ''
                }
                $Id = $splitId[0] + $splitId[1].PadLeft(5, '0') + $appendChar
                $Id = $Id.Trim()
            }

            $searchUrl = "https://www.dmm.co.jp/search/?redirect=1&enc=UTF-8&category=&searchstr=$Id"

            try {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$originalId] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$searchUrl]"
                $webRequest = Invoke-WebRequest -Uri $searchUrl -Method Get -Verbose:$false
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$originalId] [$($MyInvocation.MyCommand.Name)] Error occurred on [GET] on URL [$searchUrl]: $PSItem"
            }

            $retryCount = 3
            $searchResults = ($webrequest.links.href | Where-Object { $_ -like '*digital/videoa/*' })
            $numResults = $searchResults.count

            if ($retryCount -gt $numResults) {
                $retryCount = $numResults
            }

            if ($numResults -ge 1) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$originalId] [$($MyInvocation.MyCommand.Name)] Searching [$retryCount] of [$numResults] results for [$originalId]"

                $count = 1
                foreach ($result in $searchResults) {
                    try {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$originalId] [$($MyInvocation.MyCommand.Name)] Performing [GET] on URL [$result]"
                        $webRequest = Invoke-WebRequest -Uri $result -Method Get -Verbose:$false
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$originalId] [$($MyInvocation.MyCommand.Name)] Error occurred on [GET] on URL [$result]: $PSItem"
                    }

                    $resultId = Get-DmmContentId -WebRequest $webRequest
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$originalId] [$($MyInvocation.MyCommand.Name)] Result [$count] is [$resultId]"
                    if ($resultId -match "^(.*_)?\d*$Id") {
                        $directUrl = $result
                        break
                    }

                    if ($count -eq $retryCount) {
                        break
                    }

                    $count++
                }
            }
        }

        if ($null -eq $directUrl) {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$originalId] [$($MyInvocation.MyCommand.Name)] not matched on DMM"
            return
        } else {
            try {
                $jaId = ($directUrl | Select-String -Pattern 'cid=(.*)\/\?').Matches.Groups[1].Value
                $jaIdPart = $jaId -replace '\d{5}[zZ]?[eE]?', ''

                $splitJaIdNum = (($jaId | Select-String -Pattern '\d{5}[zZ]?[eE]?').Matches.Groups[0].Value) -replace '^0*', ''
                if (($splitJaIdNum)[-1] -match '\D') {
                    $appendChar = ($splitIdJaIdNum)[-1]
                    $splitJaIdNum = $splitJaIdNum -replace '\D', ''
                }

                $enIdNum = $splitJaIdNum.PadLeft(3, '0') + $appendChar
                $enId = $jaIdPart + $enIdNum
            } catch {
                return
            }

            $enDirectUrl = "https://www.dmm.co.jp/en/mono/dvd/-/detail/=/cid=$enId"
            $urlObject = [PSCustomObject]@{
                En = $enDirectUrl
                Ja = $directUrl
            }

            Write-Output $urlObject
        }
    }
}
