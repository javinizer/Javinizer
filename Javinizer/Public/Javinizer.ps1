function Javinizer {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Info', Mandatory = $true, Position = 0)]
        [Alias('f')]
        [string]$Find,
        [Parameter(ParameterSetName = 'Path', Mandatory = $true, Position = 0)]
        [Alias('p')]
        [system.io.fileinfo]$Path,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false, Position = 1)]
        [Alias('u')]
        [string]$Url,
        [switch]$r18,
        [switch]$dmm,
        [switch]$javlibrary
    )

    begin {
        $settingsPath = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'settings.ini'
        $settings = Import-IniSettings -Path $settingsPath


    }

    process {
        Write-Debug "Parameter set: $($PSCmdlet.ParameterSetName)"

        if (-not ($PSBoundParameters.ContainsKey('r18') -and (-not ($PSBoundParameters.ContainsKey('dmm')) -and (-not ($PSBoundParameters.ContainsKey('javlibrary')))))) {
            if ($settings.Main.'scrape-r18' -eq 'true') { $r18 = $true }
            if ($settings.Main.'scrape-dmm' -eq 'true') { $dmm = $true }
            if ($settings.Main.'scrape-javlibrary' -eq 'true') { $javlibrary = $true }
        }

        Write-Debug "r18: $r18"
        Write-Debug "dmm: $dmm"
        Write-Debug "jl: $javlibrary"

        switch ($PsCmdlet.ParameterSetName) {
            'Info' {
                if ($Find -match 'http:\/\/') {
                    $urlLocation = Test-UrlLocation -Url $Find
                    if ($urlLocation -eq 'r18') {
                        $r18Data = Get-R18DataObject -Url $Find
                        Write-Output $r18Data
                    }

                    if ($urlLocation -eq 'dmm') {
                        $dmmData = Get-DmmDataObject -Url $Find
                        Write-Output $dmmData
                    }

                    if ($urlLocation -eq 'javlibrary') {
                        $javlibraryData = Get-JavlibraryDataObject -Url $Find
                        Write-Output $javlibraryData
                    }
                } else {
                    if ($PSBoundParameters.ContainsKey('r18')) {
                        $r18Data = Get-R18DataObject -Name $Find
                        Write-Output $r18Data
                    }

                    if ($PSBoundParameters.ContainsKey('dmm')) {
                        $dmmData = Get-DmmDataObject -Name $Find
                        Write-Output $dmmData
                    }

                    if ($PSBoundParameters.ContainsKey('javlibrary')) {
                        $javlibraryData = Get-JavlibraryDataObject -Name $Find
                        Write-Output $javlibraryData
                    }
                }
            }

            'Path' {
                $fileDetails = Convert-JavTitle -Path $Path

                if ($PSBoundParameters.ContainsKey('r18') -or $urlLocation -eq 'r18') {
                    $r18Data = Get-R18DataObject -Name $fileDetails.Id -Url $Url
                    #Write-Output $r18Data
                }

                if ($PSBoundParameters.ContainsKey('dmm') -or $urlLocation -eq 'dmm') {
                    $dmmData = Get-DmmDataObject -Name $fileDetails.Id -Url $Url
                    #Write-Output $dmmData
                }

                if ($PSBoundParameters.ContainsKey('javlibrary') -or $urlLocation -eq 'javlibrary') {
                    $javlibraryData = Get-JavlibraryDataObject -Name $fileDetails.Id -Url $Url
                    #Write-Output $javlibraryData
                }
            }
        }
    }
}


