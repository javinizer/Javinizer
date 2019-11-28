function Test-UrlLocation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Url
    )

    process {
        if ($Url -match 'r18.com\/videos\/vod\/movies\/') {
            Write-Output 'r18'
        } elseif ($Url -match 'javlibrary.com\/en\/\?v=') {
            Write-Output 'javlibrary'
        } elseif ($Url -match 'dmm.co.jp\/digital\/videoa\/-\/detail\/=\/cid=') {
            Write-Output 'dmm'
        } else {
            Write-Output 'none'
        }
    }
}
