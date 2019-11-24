function Test-UrlMatch {
    param(
        [string]$Url,
        [switch]$JavLibrary,
        [switch]$R18
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        if ($JavLibrary.IsPresent) {
            if ($Url -match 'http:\/\/www\.javlibrary\.com\/(.*)\/\?v=(.*)') {
                $match = $Url
            }
        } elseif ($R18.IsPresent) {
            $match = $Url
        }
    }

    end {
        Write-Output $match
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
