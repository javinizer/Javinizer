function Test-UrlLocation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [array]$Url
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $testUrlObject = @()
    }

    process {
        foreach ($link in $Url) {
            if ($link -match 'r18.com\/videos\/vod\/movies\/') {
                $testUrlObject += [pscustomobject]@{
                    Url    = $link
                    Result = 'r18'
                }
            } elseif ($link -match 'javlibrary.com\/en\/\?v=') {
                $testUrlObject += [pscustomobject]@{
                    Url    = $link
                    Result = 'javlibrary'
                }
            } elseif ($link -match 'dmm.co.jp\/digital\/videoa\/-\/detail\/=\/cid=') {
                $testUrlObject = [pscustomobject]@{
                    Url    = $link
                    Result = 'dmm'
                }
            } else {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Url: [$Url] not matched"
            }
        }

        Write-Output $testUrlObject
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
