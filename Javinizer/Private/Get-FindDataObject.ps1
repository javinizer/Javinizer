function Get-FindDataObject {
    [CmdletBinding()]
    param(
        [string]$Find,
        [object]$Settings,
        [switch]$Aggregated,
        [switch]$Dmm,
        [switch]$Javlibrary,
        [switch]$R18
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $urlList = @()

        if (-not ($PSBoundParameters.ContainsKey('r18')) -and `
            (-not ($PSBoundParameters.ContainsKey('dmm')) -and `
                (-not ($PSBoundParameters.ContainsKey('javlibrary')) -and `
                    (-not ($PSBoundParameters.ContainsKey('7mmtv')))))) {
            if ($settings.Main.'scrape-r18' -eq 'true') { $R18 = $true }
            if ($settings.Main.'scrape-dmm' -eq 'true') { $Dmm = $true }
            if ($settings.Main.'scrape-javlibrary' -eq 'true') { $Javlibrary = $true }
            if ($settings.Main.'scrape-7mmtv' -eq 'true') { $7mmtv = $true }
        }

        if ($PSVersionTable.PSVersion -like '7*') {
            $directoryMode = 'd----'
            $itemMode = '-a---'
        } else {
            $directoryMode = 'd-----'
            $itemMode = '-a----'
        }
    }

    process {
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
                    $r18Data = Get-R18DataObject -Url $Find -ErrorAction 'SilentlyContinue'
                    Write-Output $r18Data
                }

                if ($urlLocation.Result -eq 'dmm') {
                    $dmmData = Get-DmmDataObject -Url $Find -ErrorAction 'SilentlyContinue'
                    Write-Output $dmmData
                }

                if ($urlLocation.Result -eq 'javlibrary') {
                    $javlibraryData = Get-JavlibraryDataObject -Url $Find -ErrorAction 'SilentlyContinue'
                    Write-Output $javlibraryData
                }
            }
        } elseif ($getItem.Mode -eq $itemMode) {
            $fileDetails = Convert-JavTitle -Path $Find
            if ($Aggregated.IsPresent) {
                $aggregatedDataObject = Get-AggregatedDataObject -FileDetails $fileDetails -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue'
                Write-Output $aggregatedDataObject
            } else {
                if ($r18) {
                    $r18Data = Get-R18DataObject -Name $fileDetails.Id -ErrorAction 'SilentlyContinue'
                    Write-Output $r18Data
                }

                if ($dmm) {
                    $dmmData = Get-DmmDataObject -Name $fileDetails.Id -ErrorAction 'SilentlyContinue'
                    Write-Output $dmmData
                }

                if ($javlibrary) {
                    $javlibraryData = Get-JavlibraryDataObject -Name $fileDetails.Id -ErrorAction 'SilentlyContinue'
                    Write-Output $javlibraryData
                }
            }
        } else {
            if ($Aggregated.IsPresent) {
                $aggregatedDataObject = Get-AggregatedDataObject -Id $Find -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue'
                Write-Output $aggregatedDataObject
            } else {
                if ($r18) {
                    $r18Data = Get-R18DataObject -Name $Find -ErrorAction 'SilentlyContinue'
                    Write-Output $r18Data
                }

                if ($dmm) {
                    $dmmData = Get-DmmDataObject -Name $Find -ErrorAction 'SilentlyContinue'
                    Write-Output $dmmData
                }

                if ($javlibrary) {
                    $javlibraryData = Get-JavlibraryDataObject -Name $Find -ErrorAction 'SilentlyContinue'
                    Write-Output $javlibraryData
                }
            }
        }
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
