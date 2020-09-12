function Get-JVUrlLocation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PSObject]$Url
    )

    process {
        $testUrlObject = @()
        foreach ($link in $Url) {
            if ($link -match 'r18.com') {
                if ($link -match 'lg=zh') {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'r18zh'
                    }
                } else {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'r18'
                    }
                }
            } elseif ($link -match 'javlibrary.com' -or $link -match 'g46e.com' -or $link -match 'm45e.com') {
                if ($link -match '/ja/') {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'javlibraryja'
                    }
                } elseif ($link -match '/cn/') {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'javlibraryzh'
                    }
                } elseif ($link -match '/tw/') {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'javlibraryzh'
                    }
                } else {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'javlibrary'
                    }
                }
            } elseif ($link -match 'dmm.co.jp') {
                if ($link -match '/en') {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'dmm'
                    }
                } else {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'dmmja'
                    }
                }
            } elseif ($link -match 'javbus') {
                if ($link -match '/ja') {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'javbusja'
                    }
                } elseif ($link -match '/zh') {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'javbuszh'
                    }
                } else {
                    $testUrlObject += [PSCustomObject]@{
                        Url    = $link
                        Source = 'javbus'
                    }
                }
            } elseif ($link -match 'jav321.com') {
                $testUrlObject += [PSCustomObject]@{
                    Url    = $link
                    Source = 'jav321ja'
                }
            } else {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] [Url - $Url] not matched"
            }
        }
        Write-Output $testUrlObject
    }
}
