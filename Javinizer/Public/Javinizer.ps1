function Javinizer {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Info', Mandatory = $true, Position = 0)]
        [Alias('f')]
        [string]$Find,
        [Parameter(ParameterSetNAme = 'Info', Mandatory = $false)]
        [switch]$Aggregated,
        [Parameter(ParameterSetName = 'Path', Mandatory = $true, Position = 0)]
        [Alias('p')]
        [system.io.fileinfo]$Path,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false, Position = 1)]
        [Alias('u')]
        [string]$Url,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [switch]$PassThru,
        [Alias('a')]
        [switch]$Apply,
        [switch]$Parallel,
        [switch]$R18,
        [switch]$Dmm,
        [switch]$Javlibrary
    )

    begin {
        Write-Debug "Parameter set: $($PSCmdlet.ParameterSetName)"
        Write-Debug "Bound parameters: $($PSBoundParameters.Keys)"
        $settingsPath = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'settings.ini'
        $settings = Import-IniSettings -Path $settingsPath
        if (($settings.Other.'verbose-shell-output' -eq 'True') -or ($PSBoundParameters.ContainsKey('Verbose'))) { $VerbosePreference = 'Continue' } else { $VerbosePreference = 'SilentlyContinue' }
        $ProgressPreference = 'SilentlyContinue'
        $urlLocation = @()
        $urlList = @()
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        if ($PSVersionTable.PSVersion -like '7*') {
            $directoryMode = 'd----'
            $itemMode = '-a---'
        } else {
            $directoryMode = 'd-----'
            $itemMode = '-a----'
        }

        if (-not ($PSBoundParameters.ContainsKey('r18')) -and `
            (-not ($PSBoundParameters.ContainsKey('dmm')) -and `
                (-not ($PSBoundParameters.ContainsKey('javlibrary')) -and `
                    (-not ($PSBoundParameters.ContainsKey('7mmtv')))))) {
            if ($settings.Main.'scrape-r18' -eq 'true') { $R18 = $true }
            if ($settings.Main.'scrape-dmm' -eq 'true') { $Dmm = $true }
            if ($settings.Main.'scrape-javlibrary' -eq 'true') { $Javlibrary = $true }
            if ($settings.Main.'scrape-7mmtv' -eq 'true') { $7mmtv = $true }
        }
    }

    process {
        Write-Debug "R18 toggle: $r18"
        Write-Debug "Dmm toggle: $dmm"
        Write-Debug "Javlibrary toggle: $javlibrary"

        switch ($PsCmdlet.ParameterSetName) {
            'Info' {
                $dataObject = Get-FindDataObject -Find $Find -Settings $settings -Aggregated:$Aggregated -Dmm:$Dmm -R18:$R18 -Javlibrary:$Javlibrary
                Write-Output $dataObject
            }

            'Path' {
                $getItem = Get-Item $Path
                $fileDetails = Convert-JavTitle -Path $Path
                Write-Debug "Converted file details: $($fileDetails)"

                # Match a single file and perform actions on it
                if ($getItem.Mode -eq $itemMode) {
                    if ($Url.IsPresent) {
                        if ($Url -match ',') {
                            $urlList = $Url -split ','
                            $urlLocation = Test-UrlLocation -Url $urlList
                        } else {
                            $urlLocation = Test-UrlLocation -Url $Url
                        }
                        $dataObject = Get-AggregatedDataObject -UrlLocation $urlLocation -Settings $settings -ErrorAction 'SilentlyContinue'
                        Write-Output $dataObject
                    }
                } else {
                    $dataObject = Get-AggregatedDataObject -FileDetails $fileDetails -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue'
                    Write-Output $dataObject
                }
                # Match a directory/multiple files and perform actions on them
            } elseif ($getItem.Mode -eq $directoryMode) {

            } else {
                throw "$getItem is neither file nor directory"
            }
        }
    }


    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}


