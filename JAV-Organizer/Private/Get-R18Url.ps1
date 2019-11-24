function Get-R18Url {
    [CmdletBinding()]
    param(
        [string]$Id
    )

    $R18Search = Invoke-WebRequest "https://www.r18.com/common/search/searchword=$Id/"
    $R18Url = (($R18Search.Links | Where-Object { $_.href -like "*/videos/vod/movies/detail/-/id=*" }).href)

    if ($R18Search.Content -match "data-product-page-url=`"https://www.r18.com/videos/vod/movies/detail") {
        $R18Title = (((($R18Search.Content -split "data-title=`"")[1] -split "data-title=`"")[0] -split "data-description")[0].Trim()) -replace ".$"
    }

    if ($R18Url) {
        if ($R18Url.Count -gt 1) {
            $R18Search = Invoke-WebRequest -Uri $R18Url[0] -Method Get
        } else {
            $R18Search = Invoke-WebRequest -Uri $R18Url -Method Get
        }
        # Scrape series title from R18
        $R18SeriesUrl = $R18Search.Links.href | Where-Object { $_ -match "Type=series\/" }
        if ($null -ne $R18SeriesUrl) {
            $R18SeriesSearch = Invoke-WebRequest -Uri $R18SeriesUrl -Method Get
            $R18SeriesTitle = (((((($R18SeriesSearch.Content -split "<div class=`"breadcrumbs`">")[1]) -split "<dl><dt>")[1]) -split "<span class=")[0]).Trim()
        }

        $R18DirectorString = (((($R18Search -split "<dd itemprop=`"director`">")[1]) -split "<br>")[0])
        if ($R18DirectorString -notmatch '----') {
            $R18DirectorName = $R18DirectorString.Trim()
        }
    }
}
