function Test-UrlMatch {
    param (
        [string]$Url,
        [switch]$JavLibrary,
        [switch]$R18
    )

    begin {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "Url is: [$Url]"
        if ($JavLibrary.IsPresent) {
            if ($Url -match 'http:\/\/www\.javlibrary\.com\/(.*)\/\?v=(.*)') {
                $match = $Url
            }
        } elseif ($R18.IsPresent) {
            $match = $Url
        }

        Write-Output $match
    }

    end {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
