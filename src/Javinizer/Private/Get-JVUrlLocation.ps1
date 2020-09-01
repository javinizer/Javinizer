function Get-JVUrlLocation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PSObject]$Url
    )

    process {
        $testUrlObject = @()
        foreach ($link in $Url) {
            if ($link -match 'r18.com') {
                if ($link -match 'lg=zh') {
                    $testUrlObject += [pscustomobject]@{
                        Url    = $link
                        Source = 'r18zh'
                    }
                } else {
                    $testUrlObject += [pscustomobject]@{
                        Url    = $link
                        Source = 'r18'
                    }
                }
            } elseif ($link -match 'javlibrary.com') {
                if ($link -match '/ja/') {
                    $testUrlObject += [pscustomobject]@{
                        Url    = $link
                        Source = 'javlibraryja'
                    }
                } elseif ($link -match '/cn/') {
                    $testUrlObject += [pscustomobject]@{
                        Url    = $link
                        Source = 'javlibraryzh'
                    }
                } elseif ($link -match '/tw/') {
                    $testUrlObject += [pscustomobject]@{
                        Url    = $link
                        Source = 'javlibraryzh'
                    }
                } else {
                    $testUrlObject += [pscustomobject]@{
                        Url    = $link
                        Source = 'javlibrary'
                    }
                }
            } elseif ($link -match 'dmm.co.jp') {
                $testUrlObject += [pscustomobject]@{
                    Url    = $link
                    Source = 'dmm'
                }
            } elseif ($link -match 'javbus') {
                if ($link -match '/ja') {
                    $testUrlObject += [pscustomobject]@{
                        Url    = $link
                        Source = 'javbusja'
                    }
                } elseif ($link -match '/zh') {
                    $testUrlObject += [pscustomobject]@{
                        Url    = $link
                        Source = 'javbuszh'
                    }
                } else {
                    $testUrlObject += [pscustomobject]@{
                        Url    = $link
                        Source = 'javbus'
                    }
                }
            } elseif ($link -match 'jav321.com') {
                $testUrlObject += [pscustomboject]@{
                    Url    = $link
                    Source = 'jav321'
                }
            } else {
                Write-JLog -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] [Url - $Url] not matched"
            }
        }
        Write-Output $testUrlObject
    }
}
