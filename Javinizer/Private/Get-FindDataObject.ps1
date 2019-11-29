function Get-FindDataObject {
    [CmdletBinding()]
    param(
        [string]$Find,
        [object]$Settings,
        [switch]$Aggregated
    )

    begin {
        $urlList = @()
    }

    process {
        if (-not ($PSBoundParameters.ContainsKey('r18')) -and `
            (-not ($PSBoundParameters.ContainsKey('dmm')) -and `
                (-not ($PSBoundParameters.ContainsKey('javlibrary')) -and `
                    (-not ($PSBoundParameters.ContainsKey('7mmtv')))))) {
            if ($settings.Main.'scrape-r18' -eq 'true') { $r18 = $true }
            if ($settings.Main.'scrape-dmm' -eq 'true') { $dmm = $true }
            if ($settings.Main.'scrape-javlibrary' -eq 'true') { $javlibrary = $true }
            if ($settings.Main.'scrape-7mmtv' -eq 'true') { $7mmtv = $true }
        }

        if (Test-Path -Path $Find) {
            $getItem = Get-Item $Find
        }

        if ($Find -match 'http:\/\/' -or $Find -match 'https:\/\/') {
            $urlList = Convert-CommaDelimitedString -String $Find
            $urlLocation = Test-UrlLocation -Url $urlList
            if ($Aggregated.IsPresent) {
                $aggregatedDataObject = Get-AggregatedDataObject -UrlLocation $urlLocation -Settings $settings -ErrorAction 'SilentlyContinue'
                Write-Output $aggregatedDataObject
            } else {
                if ($urlLocation.Result -eq 'r18') {
                    $r18Data = Get-R18DataObject -Url $Find
                    Write-Output $r18Data
                }

                if ($urlLocation.Result -eq 'dmm') {
                    $dmmData = Get-DmmDataObject -Url $Find
                    Write-Output $dmmData
                }

                if ($urlLocation.Result -eq 'javlibrary') {
                    $javlibraryData = Get-JavlibraryDataObject -Url $Find
                    Write-Output $javlibraryData
                }
            }
        } elseif ($getItem.Mode -eq '-a----') {
            $fileDetails = Convert-JavTitle -Path $Find
            if ($Aggregated.IsPresent) {
                $aggregatedDataObject = Get-AggregatedDataObject -FileDetails $fileDetails -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue'
                Write-Output $aggregatedDataObject
            } else {
                if ($r18) {
                    $r18Data = Get-R18DataObject -Name $fileDetails.Id
                    Write-Output $r18Data
                }

                if ($dmm) {
                    $dmmData = Get-DmmDataObject -Name $fileDetails.Id
                    Write-Output $dmmData
                }

                if ($javlibrary) {
                    $javlibraryData = Get-JavlibraryDataObject -Name $fileDetails.Id
                    Write-Output $javlibraryData
                }
            }
        } else {
            if ($Aggregated.IsPresent) {
                $aggregatedDataObject = Get-AggregatedDataObject -Id $Find -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue'
                Write-Output $aggregatedDataObject
            } else {
                if ($r18) {
                    $r18Data = Get-R18DataObject -Name $Find
                    Write-Output $r18Data
                }

                if ($dmm) {
                    $dmmData = Get-DmmDataObject -Name $Find
                    Write-Output $dmmData
                }

                if ($javlibrary) {
                    $javlibraryData = Get-JavlibraryDataObject -Name $Find
                    Write-Output $javlibraryData
                }
            }
        }
    }
}
