function Test-UrlMatch {
    param(
        [string]$Url,
        [switch]$JavLibrary,
        [switch]$R18
    )

    if ($JavLibrary.IsPresent) {
        if ($Url -match 'http:\/\/www\.javlibrary\.com\/(.*)\/\?v=(.*)') {
            return $Url
        }
    } elseif ($R18.IsPresent) {
        return $Url
    }
}
