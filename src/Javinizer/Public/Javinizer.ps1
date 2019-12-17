function Javinizer {

    <#
    .SYNOPSIS
        A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files

    .DESCRIPTION
        Javinizer is used to pull data from online data sources such as JAVLibrary, DMM, and R18 to aggregate data into a CMS (Plex,Emby,Jellyfin) parseable format.

    .PARAMETER Find
        The find parameter will output a list-formatted data output from the data sources specified using a movie ID, file path, or URL.

    .PARAMETER Aggregated
        The aggregated parameter will create an aggregated list-formatted data output from the data sources specified as well as metadata priorities in your settings.ini file.

    .PARAMETER Path
        The path parameter sets the file or directory path that Javinizer will search and sort files in.

    .PARAMETER DestinationPath
        The destinationpath parameter sets the directory path that Javinizer will send sorted files to.

    .PARAMETER Url
        The url parameter allows you to set direct URLs to JAVLibrary, DMM, and R18 data sources to scrape a video from in direct URLs comma-separated-format (url1,url2,url3).

    .PARAMETER Apply
        The apply parameter allows you to automatically begin your sort using settings specified in your settings.ini file.

    .PARAMETER Multi
        The multi parameter will perform your sort using multiple concurrent threads with a throttle limit of (1-5) set in your settings.ini file.

    .PARAMETER Recurse
        The recurse parameter will perform your sort recursively within your specified sort directory.

    .PARAMETER Help
        The help parameter will open a help dialogue in your console for Javinizer usage.

    .PARAMETER OpenSettings
        The opensettings parameter will open your settings.ini file for you to view and edit.

    .PARAMETER BackupSettings
        The backupsettings parameter will backup your settings.ini and r18-thumbs.csv file to an archive.

    .PARAMETER RestoreSettings
        The restoresettings parameter will restore your archive created from the backupsettings parameter to the root module folder.

    .PARAMETER GetThumbs
        The getthumbs parameter will fully update your R18 actress and thumbnail csv database file which will attempt to write unknown actress thumburls on sort.

    .PARAMETER UpdateThumbs
        The updatethumbs parameter will partially update your R18 actress and thumbnail csv database file with a specified number of R18.com pages.

    .PARAMETER OpenThumbs
        The openthumbs parameter will open your r18-thumbs.csv file for you to view and edit.

    .PARAMETER SetEmbyActorThumbs
        The setembyactorthumbs parameter will POST matching R18 actor images from `r18-thumbs.csv` to your Emby or Jellyfin instance.

    .PARAMETER R18
        The r18 parameter allows you to set your data source of R18 to true.

    .PARAMETER Dmm
        The dmm parameter allows you to set your data source of DMM to true.

    .PARAMETER Javlibrary
        The javlibrary parameter allows you to set your data source of JAVLibrary to true.

    .PARAMETER Force
        The force parameter will attempt to force any new sorted files to be overwritten if it already exists.

    .PARAMETER ScriptRoot
        The scriptroot parameter sets the default Javinizer module directory. This should not be touched.


    .EXAMPLE
        PS> Javinizer -OpenSettings

        Description
        -----------
        Opens your Javinizer settings.ini file in the root module directory.

    .EXAMPLE
        PS> Javinizer -Path C:\Downloads\Unsorted -Multi

        Description
        -----------
        Performs a multi-threaded sort on C:\Downloads\Unsorted with settings specified in your settings.ini file.

    .EXAMPLE
        PS> Javinizer -Apply -Multi

        Description
        -----------
        Performs a multi-threaded sort on your directories with settings specified in your settings.ini file.

    .EXAMPLE
        PS> Javinizer -Path C:\Downloads -DestinationPath C:\Downloads\Sorted -Recurse

        Description
        -----------
        Performs a single-threaded recursive sort on your specified Path with other settings specified in your settings.ini file.

    .EXAMPLE
        PS> Javinizer -Path 'C:\Downloads\Jav\snis-620.mp4' -DestinationPath C:\Downloads\JAV\Sorted\' -Url 'http://www.javlibrary.com/en/?v=javlilljyy,https://www.r18.com/videos/vod/movies/detail/-/id=snis00620/?i3_ref=search&i3_ord=1,https://www.dmm.co.jp/digital/videoa/-/detail/=/cid=snis00620/?i3_ref=search&i3_ord=4'

        Description
        -----------
        Performs a single-threaded sort on your specified file using direct URLs to match the file.

    .EXAMPLE
        PS> Javinizer -Find SNIS-420

        Description
        -----------
        Performs a console search of SNIS-420 for all data sources specified in your settings.ini file.

    .EXAMPLE
        PS> Javinizer -Find SNIS-420 -R18 -DMM -Aggregated

        Description
        -----------
        Performs a console search of SNIS-420 for R18 and DMM and aggregates output to your settings specified in your settings.ini file.

    .EXAMPLE
        PS> Javinizer -Find 'https://www.r18.com/videos/vod/movies/detail/-/id=pred00200/?dmmref=video.movies.new&i3_ref=list&i3_ord=2'

        Description
        -----------
        Performs a console search of PRED-200 using a direct url.

    .EXAMPLE
        PS> Javinizer -SetEmbyActorThumbs

        Description
        -----------
        Writes actor thumbnails to your Emby/Jellyfin server instance from your r18-thumbs.csv file.

    #>

    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Info', Mandatory = $true, Position = 0)]
        [Alias('f')]
        [string]$Find,
        [Parameter(ParameterSetNAme = 'Info', Mandatory = $false)]
        [switch]$Aggregated,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false, Position = 0)]
        [Alias('p')]
        [string]$Path,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false, Position = 1)]
        [Alias('d')]
        [string]$DestinationPath,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Alias('u')]
        [string]$Url,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Alias('a')]
        [switch]$Apply,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Alias('m')]
        [switch]$Multi,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [switch]$Recurse,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [switch]$Force,
        [Parameter(ParameterSetName = 'Help')]
        [Alias('h')]
        [switch]$Help,
        [Parameter(ParameterSetName = 'Settings')]
        [switch]$OpenSettings,
        [Parameter(ParameterSetName = 'Settings')]
        [string]$BackupSettings,
        [Parameter(ParameterSetName = 'Settings')]
        [string]$RestoreSettings,
        [Parameter(ParameterSetName = 'Thumbs')]
        [switch]$GetThumbs,
        [Parameter(ParameterSetName = 'Thumbs')]
        [int]$UpdateThumbs,
        [Parameter(ParameterSetName = 'Thumbs')]
        [switch]$OpenThumbs,
        [Parameter(ParameterSetName = 'Thumbs')]
        [switch]$SetEmbyActorThumbs,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Info', Mandatory = $false)]
        [switch]$R18,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Info', Mandatory = $false)]
        [switch]$Dmm,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Info', Mandatory = $false)]
        [switch]$Javlibrary,
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
            throw "[$($MyInvocation.MyCommand.Name)] Unable to load settings from path: $settingsPath"
        }

        if (($settings.Other.'verbose-shell-output' -eq 'True') -or ($PSBoundParameters.ContainsKey('Verbose'))) { $VerbosePreference = 'Continue' } else { $VerbosePreference = 'SilentlyContinue' }
        if ($settings.Other.'debug-shell-output' -eq 'True' -or ($DebugPreference -eq 'Continue')) { $DebugPreference = 'Continue' } elseif ($settings.Other.'debug-shell-output' -eq 'False') { $DebugPreference = 'SilentlyContinue' } else { $DebugPreference = 'SilentlyContinue' }
        $ProgressPreference = 'SilentlyContinue'
        Write-Host "[$($MyInvocation.MyCommand.Name)] Function started"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Parameter set: [$($PSCmdlet.ParameterSetName)]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Bound parameters: [$($PSBoundParameters.Keys)]"
        $settings.Main.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        $settings.General.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        $settings.Metadata.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        $settings.Locations.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        $settings.'Emby/Jellyfin'.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        $settings.Other.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'

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

            'Settings' {
                if ($OpenSettings.IsPresent) {
                    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                        try {
                            Write-Host "[$($MyInvocation.MyCommand.Name)] Opening settings.ini file from [$settingsPath]"
                            Invoke-Item -Path $settingsPath
                        } catch {
                            Write-Warning "[$($MyInvocation.MyCommand.Name)] Error opening settings.ini file from [$settingsPath]"
                            throw $_
                        }
                    } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                        try {
                            Write-Host "[$($MyInvocation.MyCommand.Name)] Opening settings.ini file from [$settingsPath]"
                            nano $settingsPath
                        } catch {
                            Write-Warning "[$($MyInvocation.MyCommand.Name)] Error opening settings.ini file from [$settingsPath]"
                            throw $_
                        }
                    }
                } elseif ($PSBoundParameters.ContainsKey('BackupSettings')) {
                    $backupSettingsParams = @{
                        LiteralPath      = (Join-Path -Path $ScriptRoot -ChildPath 'settings.ini'), (Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs.csv')
                        CompressionLevel = 'Fastest'
                        DestinationPath  = $BackupSettings
                    }
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] Writing settings backup archive to [$BackupSettings]"
                        Compress-Archive @backupSettingsParams
                    } catch {
                        Write-Warning "[$($MyInvocation.MyCommand.Name)] Error writing settings backup archive to [$BackupSettings]"
                        throw $_
                    }
                } elseif ($PSBoundParameters.ContainsKey('RestoreSettings')) {
                    $restoreSettingsParams = @{
                        LiteralPath     = $RestoreSettings
                        DestinationPath = $ScriptRoot
                        Force           = $true
                    }
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] Restoring settings backup archive from [$RestoreSettings] to [$ScriptRoot]"
                        Expand-Archive @restoreSettingsParams
                    } catch {
                        Write-Warning "[$($MyInvocation.MyCommand.Name)] Error restoring settings backup archive to [$ScriptRoot] from [$RestoreSettings]"
                        throw $_
                    }
                }
            }

            'Help' {
                help Javinizer
            }

            'Thumbs' {
                if ($GetThumbs.IsPresent) {
                    Get-R18ThumbCsv -ScriptRoot $ScriptRoot -Force:$Force
                } elseif ($OpenThumbs.IsPresent) {
                    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                        try {
                            Invoke-Item -Path (Join-Path $ScriptRoot -ChildPath 'r18-thumbs.csv')
                        } catch {
                            throw $_
                        }
                    } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                        try {
                            nano (Join-Path $ScriptRoot -ChildPath 'r18-thumbs.csv')
                        } catch {
                            throw $_
                        }
                    }
                } elseif ($PSBoundParameters.ContainsKey('UpdateThumbs')) {
                    Get-R18ThumbCsv -ScriptRoot $ScriptRoot -NewPages $UpdateThumbs -Force:$Force
                } elseif ($SetEmbyActorThumbs.IsPresent) {
                    Set-EmbyActors -Settings $settings -ScriptRoot $ScriptRoot
                }
            }


            'Path' {
                if (-not ($PSBoundParameters.ContainsKey('Path'))) {
                    if (-not ($Apply.IsPresent)) {
                        Write-Warning "[$($MyInvocation.MyCommand.Name)] Neither [Path] nor [Apply] parameters are specified; Exiting..."
                        return
                    }
                    $Path = ($settings.Locations.'input-path') -replace '"', ''
                    $DestinationPath = ($settings.Locations.'output-path') -replace '"', ''
                }

                try {
                    $getPath = Get-Item -LiteralPath ($Path).replace('`[', '[').replace('`]', ']') -ErrorAction Stop
                } catch {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] Path: [$Path] does not exist; Exiting..."
                    return
                }

                if (-not ($PSBoundParameters.ContainsKey('DestinationPath')) -and (-not ($Apply.IsPresent))) {
                    if (Test-Path -LiteralPath $getPath.FullName -PathType Leaf) {
                        $DestinationPath = $getPath.DirectoryName
                    } else {
                        $DestinationPath = $Path
                    }
                }

                try {
                    $getDestinationPath = Get-Item -LiteralPath $DestinationPath -ErrorAction 'SilentlyContinue'
                } catch [System.Management.Automation.SessionStateException] {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] Destination Path: [$DestinationPath] does not exist; Attempting to create the directory..."
                    New-Item -ItemType Directory -LiteralPath $DestinationPath -Confirm | Out-Null
                    $getDestinationPath = Get-Item -LiteralPath $DestinationPath -ErrorAction Stop
                } catch {
                    throw $_
                }

                try {
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Attempting to read file(s) from path: [$($getPath.FullName)]"
                    $fixedPath = ($getPath.FullName).replace('[', '`[').replace(']', '`]')
                    $fileDetails = Convert-JavTitle -Path $fixedPath -Recurse:$Recurse -Settings $settings
                } catch {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] Path: [$Path] does not contain any video files or does not exist; Exiting..."
                    return
                }
                #Write-Debug "[$($MyInvocation.MyCommand.Name)] Converted file details: [$($fileDetails)]"

                # Match a single file and perform actions on it
                if ((Test-Path -LiteralPath $getPath.FullName -PathType Leaf) -and (Test-Path -LiteralPath $getDestinationPath.FullName -PathType Container)) {
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Detected path: [$($getPath.FullName)] as single item"
                    Write-Host "[$($MyInvocation.MyCommand.Name)] ($index of $($fileDetails.Count)) Sorting [$($fileDetails.OriginalFileName)]"
                    # Write-Verbose "[$($MyInvocation.MyCommand.Name)] Starting sort on [$($fileDetails.OriginalFileName)]"
                    if ($PSBoundParameters.ContainsKey('Url')) {
                        if ($Url -match ',') {
                            $urlList = $Url -split ','
                            $urlLocation = Test-UrlLocation -Url $urlList
                        } else {
                            $urlLocation = Test-UrlLocation -Url $Url
                        }
                        $dataObject = Get-AggregatedDataObject -UrlLocation $urlLocation -Settings $settings -ErrorAction 'SilentlyContinue'
                        Set-JavMovie -DataObject $dataObject -Settings $settings -Path $getPath.FullName -DestinationPath $getDestinationPath.FullName -ScriptRoot $ScriptRoot
                    } else {
                        $dataObject = Get-AggregatedDataObject -FileDetails $fileDetails -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ErrorAction 'SilentlyContinue' -ScriptRoot $ScriptRoot
                        Set-JavMovie -DataObject $dataObject -Settings $settings -Path $getPath.FullName -DestinationPath $getDestinationPath.FullName -ScriptRoot $ScriptRoot
                    }
                    # Match a directory/multiple files and perform actions on them
                } elseif (((Test-Path -LiteralPath $getPath.FullName -PathType Container) -and (Test-Path -LiteralPath $getDestinationPath.FullName -PathType Container)) -or $Apply.IsPresent) {
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Detected path: [$($getPath.FullName)] as directory and destinationpath: [$($getDestinationPath.FullName)] as directory"
                    Write-Host "[$($MyInvocation.MyCommand.Name)] Sort path set to: [$($getPath.FullName)]"
                    Write-Host "[$($MyInvocation.MyCommand.Name)] Destination path set to: [$($getDestinationPath.FullName)]"

                    if ($Multi.IsPresent) {
                        $throttleCount = $Settings.General.'multi-sort-throttle-limit'
                        try {
                            if ($Javlibrary) {
                                New-CloudflareSession -ScriptRoot $ScriptRoot
                            }
                            Start-MultiSort -Path $getPath.FullName -Throttle $throttleCount -Recurse:$Recurse -DestinationPath $getDestinationPath.FullName -Settings $settings
                        } catch {
                            Write-Warning "[$($MyInvocation.MyCommand.Name)] There was an error starting multi sort for path: [$($getPath.FullName)] with destinationpath: [$DestinationPath] and threads: [$throttleCount]"
                        } finally {
                            # Stop all running jobs if script is stopped by user input
                            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Sort has completed or has been stopped prematurely; Stopping all running jobs..."
                            Get-RSJob | Stop-RSJob
                        }
                    } else {
                        foreach ($video in $fileDetails) {
                            Write-Host "[$($MyInvocation.MyCommand.Name)] ($index of $($fileDetails.Count)) Sorting [$($video.OriginalFileName)]"
                            if ($video.PartNumber -ge '1' -or $Multi.IsPresent) {
                                # Get data object for part 1 of a multipart video
                                $dataObject = Get-AggregatedDataObject -FileDetails $video -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ScriptRoot $ScriptRoot -ErrorAction 'SilentlyContinue'
                                # $script:savedDataObject = $dataObject
                                Set-JavMovie -DataObject $dataObject -Settings $settings -Path $video.OriginalFullName -DestinationPath $getDestinationPath.FullName -Force:$Force -ScriptRoot $ScriptRoot
                            } <# elseif ($video.PartNumber -ge '2') {
                                # Use the saved data object for the following parts
                                $dataObject = Get-AggregatedDataObject -FileDetails $video -Settings $settings -R18:$R18 -Dmm:$Dmm -Javlibrary:$Javlibrary -ScriptRoot $ScriptRoot -ErrorAction 'SilentlyContinue'
                                Set-JavMovie -DataObject $DataObject -Settings $settings -Path $video.OriginalFullName -DestinationPath $getDestinationPath.FullName -Force:$Force -ScriptRoot $ScriptRoot -ErrorAction 'SilentlyContinue'
                            } #>
                            $index++
                        }
                    }
                } else {
                    throw "[$($MyInvocation.MyCommand.Name)] Specified Path: [$Path] and/or DestinationPath: [$DestinationPath] did not match allowed types"
                }
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Ended sort on [$($fileDetails.OriginalFileName)]"
            }
        }
    }

    end {
        Write-Host "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}


