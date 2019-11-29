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
        [switch]$Parallel,
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
                $dataObject = Get-FindDataObject -Find $Find
                Write-Output $dataObject
            }

            'Path' {
                $getItem = Get-Item $Path
                $fileDetails = Convert-JavTitle -Path $Path
                Write-Debug "Converted file details: $($fileDetails)"

                # Match a single file and perform actions on it
                if ($getItem.Mode -eq '-a----') {
                    Write-Debug "Expected Mode: '-a----'"
                    Write-Debug "Mode: $($getItem.Mode)"
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
                        }
                    } else {
                        $dataObject = Get-AggregatedDataObject -FileDetails $fileDetails -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue'
                        Write-Output $dataObject
                    }
                    # Match a directory/multiple files and perform actions on them
                } elseif ($getItem.Mode -eq '-d----') {
                    Write-Debug "Expected Mode: '-d----'"
                    Write-Debug "Mode: $($getItem.Mode)"
                } else {
                    throw "$getItem is neither file nor directory"
                }
            }
        }
    }
}


