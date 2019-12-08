function Javinizer {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Info', Mandatory = $true, Position = 0)]
        [Alias('f')]
        [string]$Find,
        [Parameter(ParameterSetNAme = 'Info', Mandatory = $false)]
        [switch]$Aggregated,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false, Position = 0)]
        [Alias('p')]
        [system.io.fileinfo]$Path,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false, Position = 1)]
        [Alias('d')]
        [system.io.fileinfo]$DestinationPath,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Alias('u')]
        [string]$Url,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [switch]$PassThru,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Alias('a')]
        [switch]$Apply,
        [switch]$Parallel,
        [switch]$R18,
        [switch]$Dmm,
        [switch]$Javlibrary,
        [switch]$Force,
        [string]$ScriptRoot = (Get-Item $PSScriptRoot).Parent
    )

    begin {
        $urlLocation = @()
        $urlList = @()
        $index = 1

        try {
            $settingsPath = Join-Path -Path $ScriptRoot -ChildPath 'settings.ini'
            Write-Verbose "Settings path: $ScriptRoot"
            $settings = Import-IniSettings -Path $settingsPath
        } catch {
            throw $_
        }

        if (($settings.Other.'verbose-shell-output' -eq 'True') -or ($PSBoundParameters.ContainsKey('Verbose'))) { $VerbosePreference = 'Continue' } else { $VerbosePreference = 'SilentlyContinue' }
        if ($settings.Other.'debug-shell-output' -eq 'True' -or ($DebugPreference -eq 'Continue')) { $DebugPreference = 'Continue' } elseif ($settings.Other.'debug-shell-output' -eq 'False') { $DebugPreference = 'SilentlyContinue' } else { $DebugPreference = 'SilentlyContinue' }
        $ProgressPreference = 'SilentlyContinue'
        Write-Host "[$($MyInvocation.MyCommand.Name)] Function started"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Parameter set: [$($PSCmdlet.ParameterSetName)]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Bound parameters: [$($PSBoundParameters.Keys)]"
        $settings.Main.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug
        $settings.General.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug
        $settings.Metadata.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug
        $settings.Locations.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug
        $settings.'Emby/Jellyfin'.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug
        $settings.Other.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug

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
            #if ($settings.Main.'scrape-7mmtv' -eq 'true') { $7mmtv = $true }
        }
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] R18 toggle: [$R18]; Dmm toggle: [$Dmm]; Javlibrary toggle: [$javlibrary]"

        switch ($PsCmdlet.ParameterSetName) {
            'Info' {
                $dataObject = Get-FindDataObject -Find $Find -Settings $settings -Aggregated:$Aggregated -Dmm:$Dmm -R18:$R18 -Javlibrary:$Javlibrary
                Write-Output $dataObject
            }

            'Path' {
                if (-not ($PSBoundParameters.ContainsKey('Path'))) {
                    if (-not ($Apply.IsPresent)) {
                        Write-Warning "[$($MyInvocation.MyCommand.Name)] Neither [Path] nor [Apply] parameters are specified; Exiting..."
                        return
                    }
                    $Path = ($settings.Locations.'input-path') -replace '"', ''
                }

                if (-not ($PSBoundParameters.ContainsKey('DestinationPath'))) {
                    $DestinationPath = ($settings.Locations.'output-path') -replace '"', ''
                }

                try {
                    $getPath = Get-Item $Path -ErrorAction Stop
                } catch {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] Path: [$($Path.FullName)] does not exist; Exiting..."
                    return
                }

                try {
                    $getDestinationPath = Get-Item $DestinationPath -ErrorAction 'SilentlyContinue'
                } catch [System.Management.Automation.SessionStateException] {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] Destination Path: [$DestinationPath] does not exist; Attempting to create the directory..."
                    New-Item -ItemType Directory -Path $DestinationPath -Confirm | Out-Null
                    $getDestinationPath = Get-Item $DestinationPath -ErrorAction Stop
                } catch {
                    throw $_
                }

                try {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Attempting to read file(s) from path: [$($getPath.FullName)]"
                    $fileDetails = Convert-JavTitle -Path $Path
                } catch {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] Path: [$Path] does not contain any video files or does not exist; Exiting..."
                    return
                }
                #Write-Debug "[$($MyInvocation.MyCommand.Name)] Converted file details: [$($fileDetails)]"

                # Match a single file and perform actions on it
                if (($getPath.Mode -eq $itemMode) -and ($getDestinationPath.Mode -eq $directoryMode)) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Detected path: [$($getPath.FullName)] as single item"
                    Write-Host "[$($MyInvocation.MyCommand.Name)] ($index of $($fileDetails.Count)) Sorting [$($fileDetails.OriginalFileName)]"
                    if ($PSBoundParameters.ContainsKey('Url')) {
                        if ($Url -match ',') {
                            $urlList = $Url -split ','
                            $urlLocation = Test-UrlLocation -Url $urlList
                        } else {
                            $urlLocation = Test-UrlLocation -Url $Url
                        }
                        $dataObject = Get-AggregatedDataObject -UrlLocation $urlLocation -Settings $settings -ErrorAction 'SilentlyContinue'
                        Set-JavMovie -DataObject $dataObject -Settings $settings -Path $Path -DestinationPath $DestinationPath -ScriptRoot $ScriptRoot
                    } else {
                        # TODO: LOOK OVER HERE TO DEBUG R18 NOT WORKING IN JOB
                        $dataObject = Get-AggregatedDataObject -FileDetails $fileDetails -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue' -ScriptRoot $ScriptRoot
                        Set-JavMovie -DataObject $dataObject -Settings $settings -Path $Path -DestinationPath $DestinationPath -ScriptRoot $ScriptRoot
                    }
                    # Match a directory/multiple files and perform actions on them
                } elseif ((($getPath.Mode -eq $directoryMode) -and ($getDestinationPath.Mode -eq $directoryMode)) -or $Apply.IsPresent) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Detected path: [$($getPath.FullName)] as directory"
                    Write-Host "[$($MyInvocation.MyCommand.Name)] Performing directory sort on: [$($getDestinationPath.FullName)]"
                    foreach ($video in $fileDetails) {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] ($index of $($fileDetails.Count)) Sorting [$($video.OriginalFileName)]"
                        if ($video.PartNumber -le '1') {
                            # Get data object for part 1 of a multipart video
                            $dataObject = Get-AggregatedDataObject -FileDetails $video -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue'
                            $script:savedDataObject = $dataObject
                            Set-JavMovie -DataObject $dataObject -Settings $settings -Path $video.OriginalFullName -DestinationPath $DestinationPath -Force:$Force -ScriptRoot $ScriptRoot
                        } elseif ($video.PartNumber -ge '2') {
                            # Use the saved data object for the following parts
                            $savedDataObject.PartNumber = $video.PartNumber
                            $fileDirName = Get-NewFileDirName -DataObject $savedDataObject
                            $savedDataObject.FileName = $fileDirName.FileName
                            $savedDataObject.OriginalFileName = $fileDirName.OriginalFileName
                            $savedDataObject.FolderName = $fileDirName.FolderName
                            $savedDataObject.DisplayName = $fileDirName.DisplayName
                            Set-JavMovie -DataObject $savedDataObject -Settings $settings -Path $video.OriginalFullName -DestinationPath $DestinationPath -Force:$Force -ScriptRoot $ScriptRoot
                        }
                        $index++
                    }
                } else {
                    throw "[$($MyInvocation.MyCommand.Name)] Specified Path: [$Path] and/or DestinationPath: [$DestinationPath] did not match allowed types"
                }
            }
        }
    }

    end {
        Write-Host "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}


