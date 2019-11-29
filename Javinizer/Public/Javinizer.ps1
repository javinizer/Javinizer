function Javinizer {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Info', Mandatory = $true, Position = 0)]
        [Alias('f')]
        [string]$Find,
        [Parameter(ParameterSetName = 'Path', Mandatory = $true, Position = 0)]
        [Alias('s', 'p')]
        [system.io.fileinfo]$Path,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false, Position = 1)]
        [Alias('u')]
        [string]$Url,
        [Alias('a')]
        [switch]$Apply,
        [switch]$R18,
        [switch]$Dmm,
        [Alias('jl')]
        [switch]$Javlibrary
    )

    begin {
        $urlLocation = @()
        $urlList = @()
    }

    process {
        $settingsPath = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'settings.ini'
        $settings = Import-IniSettings -Path $settingsPath

        Write-Debug "Parameter set: $($PSCmdlet.ParameterSetName)"
        Write-Debug "Bound parameters: $($PSBoundParameters.Keys)"
        if (-not ($PSBoundParameters.ContainsKey('r18')) -and `
            (-not ($PSBoundParameters.ContainsKey('dmm')) -and `
                (-not ($PSBoundParameters.ContainsKey('javlibrary')) -and `
                    (-not ($PSBoundParameters.ContainsKey('7mmtv')))))) {
            if ($settings.Main.'scrape-r18' -eq 'true') { $r18 = $true }
            if ($settings.Main.'scrape-dmm' -eq 'true') { $dmm = $true }
            if ($settings.Main.'scrape-javlibrary' -eq 'true') { $javlibrary = $true }
            if ($settings.Main.'scrape-7mmtv' -eq 'true') { $7mmtv = $true }
        }

        Write-Debug "r18: $r18"
        Write-Debug "dmm: $dmm"
        Write-Debug "jl: $javlibrary"

        switch ($PsCmdlet.ParameterSetName) {
            'Info' {
                # Perform a check to see if the find string is an url
                if ($Find -match 'http:\/\/') {
                    $urlLocation = Test-UrlLocation -Url $Find
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

            'Path' {
                $getPath = Get-Item $Path
                $fileDetails = Convert-JavTitle -Path $Path
                Write-Debug "Converted file details: $($fileDetails)"

                # Match a single file and perform actions on it
                if ($getPath.Mode -eq '-a----') {
                    Write-Debug "Expected Mode: '-a----'"
                    Write-Debug "Mode: $($getPath.Mode)"
                    if ($PSBoundParameters.ContainsKey('Url')) {
                        if ($Url -match ',') {
                            #$urlList = $Url -split ','
                            $urlList = $Url -split ','
                            $urlLocation = Test-UrlLocation -Url $urlList
                            $dataObject = Get-AggregatedDataObject -UrlLocation $urlLocation -Settings $settings -ErrorAction 'SilentlyContinue'
                            Write-Output $dataObject

                        } else {
                            $urlLocation = Test-UrlLocation -Url $Url
                            $dataObject = Get-AggregatedDataObject -UrlLocation $urlLocation -Settings $settings -ErrorAction 'SilentlyContinue'
                            Write-Output $dataObject
                            <#                             if ($urlLocation.Result -contains 'r18') {
                                $r18Data = Get-R18DataObject -Url $urlLocation.Url
                            }

                            if ($urlLocation.Result -contains 'dmm') {
                                $dmmData = Get-DmmDataObject -Url $urlLocation.Url
                            }

                            if ($urlLocation.Result -contains 'javlibrary') {
                                $javlibraryData = Get-JavlibraryDataObject -Url $urlLocation.Url
                            } #>
                        }
                    } else {
                        $dataObject = Get-AggregatedDataObject -FileDetails $fileDetails -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue'
                        Write-Output $dataObject
                        <#                         if ($r18) {
                            $r18Data = Get-R18DataObject -Name $fileDetails.Id
                        }

                        if ($dmm) {
                            $dmmData = Get-DmmDataObject -Name $fileDetails.Id
                        }

                        if ($javlibrary) {
                            $javlibraryData = Get-JavlibraryDataObject -Name $fileDetails.Id
                        } #>
                    }
                    # Match a directory/multiple files and perform actions on them
                } else {
                    Write-Debug "Expected Mode: '-d----'"
                    Write-Debug "Mode: $($getPath.Mode)"
                }
            }
        }
    }
}


