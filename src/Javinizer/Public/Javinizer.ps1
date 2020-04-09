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

    .PARAMETER ImportSettings
            The importsettings parameter allows you to specify an external settings file. This is useful if you want to have different presets for groups of videos.

    .PARAMETER Url
        The url parameter allows you to set direct URLs to JAVLibrary, DMM, and R18 data sources to scrape a video from in direct URLs comma-separated-format (url1,url2,url3).

    .PARAMETER Apply
        The apply parameter allows you to automatically begin your sort using settings specified in your settings.ini file.

    .PARAMETER MoveToFolder
        The movetofolder parameter will allow you to set a true/false value for the setting move-to-folder from the commandline.

    .PARAMETER Multi
        The multi parameter will perform your sort using multiple concurrent threads with a throttle limit of (1-5) set in your settings.ini file.

    .PARAMETER Recurse
        The recurse parameter will perform your sort recursively within your specified sort directory.

    .PARAMETER RenameFile
        The renamefile parameter will allow you to set a true/false v alue for the setting rename-file from the commandline.

    .PARAMETER Strict
        The strict parameter will perform your sort without automatically cleaning your filenames. It will read the exact filename.

    .PARAMETER Help
        The help parameter will open a help dialogue in your console for Javinizer usage.

    .PARAMETER Version
        The version parameter will display Javinizer's current module version.

    .PARAMETER OpenSettings
        The opensettings parameter will open your settings.ini file for you to view and edit.

    .PARAMETER BackupSettings
        The backupsettings parameter will backup your settings.ini and r18-thumbs.csv file to an archive.

    .PARAMETER RestoreSettings
        The restoresettings parameter will restore your archive created from the backupsettings parameter to the root module folder.

    .PARAMETER OpenLog
        The openlog parameter will open your Javinizer.log file located in your module path.

    .PARAMETER ViewLog
        The viewlog parameter will output the Javinizer.log file in your console.

    .PARAMETER LogLevel
        The loglevel parameter will allow you to select which logging level to view (INFO, ERROR, WARN, DEBUG)

    .PARAMETER Entries
        The entries parameter lets you select the amount of log entries to view

    .PARAMETER Order
        The order parameter lets you select which sort order to view your log entries (Asc, Desc) with descending being default

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

    .PARAMETER R18Zh
        The r18zh parameter allows you to set your data source of R18Zh to true.

    .PARAMETER Dmm
        The dmm parameter allows you to set your data source of DMM to true.

    .PARAMETER Javlibrary
        The javlibrary parameter allows you to set your data source of JAVLibrary to true.

    .PARAMETER JavlibraryZh
        The javlibraryzh parameter allows you to set your data source of JAVLibraryZh to true.

    .Parameter JavlibraryJa
        The javlibraryja parameter allows you to set your data source of JAVLibraryJa to true.

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
        PS> Javinizer -Path C:\Downloads\Jav\Sorted -Recurse -MoveToFolder:$false -RenameFile:$false -Multi

        Description
        -----------
        Performs a multi-threaded recursive sort on your directories while setting move-to-folder and rename-file false to refresh metadata within those directories.

    .EXAMPLE
        PS> Javinizer -Path C:\Downloads -ImportSettings C:\Downloads\settings-template1.ini -Multi

        Description
        -----------
        Performs a multi-threaded sort on your directories while importing an external settings file.

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

    .EXAMPLE
        PS> Javinizer -ViewLog List -Entries 5 -LogLevel Error

        Description
        -----------
        Writes your latest 5 error log entries in list view to the console from your Javinizer log file.

    .EXAMPLE
        PS> Javinizer -ViewLog Object | Select-Object -First 10 | Sort-Object timestamp -Descending | Format-Table wrap

        Description
        -----------
        Outputs your Javinizer log file to the console as a PowerShell object.

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
        [switch]$Strict,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [switch]$Force,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [string]$ImportSettings,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [bool]$MoveToFolder,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [bool]$RenameFile,
        [Parameter(ParameterSetName = 'Help')]
        [Alias('h')]
        [switch]$Help,
        [Parameter(ParameterSetName = 'Version')]
        [Alias('v')]
        [switch]$Version,
        [Parameter(ParameterSetName = 'Settings')]
        [switch]$OpenSettings,
        [Parameter(ParameterSetName = 'Settings')]
        [string]$BackupSettings,
        [Parameter(ParameterSetName = 'Settings')]
        [string]$RestoreSettings,
        [Parameter(ParameterSetName = 'Log')]
        [switch]$OpenLog,
        [Parameter(ParameterSetName = 'Log')]
        [ValidateSet('List', 'Grid', 'Table', 'Object')]
        [string]$ViewLog,
        [Parameter(ParameterSetName = 'Log')]
        [ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG')]
        [string]$LogLevel,
        [Parameter(ParameterSetName = 'Log')]
        [int]$Entries,
        [Parameter(ParameterSetName = 'Log')]
        [ValidateSet('Asc', 'Desc')]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$Order,
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
        [switch]$R18Zh,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Info', Mandatory = $false)]
        [switch]$Dmm,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Info', Mandatory = $false)]
        [switch]$Javlibrary,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Info', Mandatory = $false)]
        [switch]$JavlibraryZh,
        [Parameter(ParameterSetName = 'Path', Mandatory = $false)]
        [Parameter(ParameterSetName = 'Info', Mandatory = $false)]
        [switch]$JavlibraryJa,
        [string]$ScriptRoot = (Get-Item $PSScriptRoot).Parent
    )

    begin {
        $urlLocation = @()
        $urlList = @()
        $index = 1

        try {
            # Load the settings file from either commandline path or default
            if ($PSBoundParameters.ContainsKey('ImportSettings')) {
                $settingsPath = Get-Item -LiteralPath $ImportSettings
            } else {
                $settingsPath = Join-Path -Path $ScriptRoot -ChildPath 'settings.ini'
            }
            $settings = Import-IniSettings -Path $settingsPath
        } catch {
            throw "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Unable to load settings from path: $settingsPath"
        }

        if (($settings.Other.'log-path' -eq '') -or ($null -eq $settings.Other.'log-path')) {
            $global:javinizerLogPath = Join-Path -Path $ScriptRoot -ChildPath javinizer.log
        } else {
            $global:javinizerLogPath = $settings.Other.'log-path' -replace '"', ''
        }

        if ($settings.Other.'check-updates' -eq 'True') {
            if (-not ($javinizerUpdateCheck)) {
                Update-Javinizer
                $global:javinizerUpdateCheck = $true
            }
        }

        if ($PSBoundParameters.ContainsKey('MoveToFolder')) {
            if ($MoveToFolder -eq $true) {
                $Settings.General.'move-to-folder' = 'True'
            } elseif ($MoveToFolder -eq $false) {
                $Settings.General.'move-to-folder' = 'False'
            }
        }

        if ($PSBoundParameters.ContainsKey('RenameFile')) {
            if ($RenameFile -eq $true) {
                $Settings.General.'rename-file' = 'True'
            } elseif ($RenameFile -eq $false) {
                $Settings.General.'rename-file' = 'False'
            }
        }

        if (($settings.Other.'verbose-shell-output' -eq 'True') -or ($PSBoundParameters.ContainsKey('Verbose'))) {
            $VerbosePreference = 'Continue'
        } else {
            $VerbosePreference = 'SilentlyContinue'
        }

        if ($settings.Other.'debug-shell-output' -eq 'True' -or ($DebugPreference -eq 'Continue')) {
            $DebugPreference = 'Continue'
        } elseif ($settings.Other.'debug-shell-output' -eq 'False') {
            $DebugPreference = 'SilentlyContinue'
        } else {
            $DebugPreference = 'SilentlyContinue'
        }

        $ProgressPreference = 'SilentlyContinue'

        #Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Parameter set: [$($PSCmdlet.ParameterSetName)]"
        #Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Bound parameters: [$($PSBoundParameters.Keys)]"
        #$settings.Main.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        #$settings.General.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        #$settings.Metadata.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        #$settings.Locations.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        #$settings.'Emby/Jellyfin'.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'
        #$settings.Other.GetEnumerator() | Sort-Object Key | Out-String | Write-Debug -ErrorAction 'SilentlyContinue'

        if (-not ($PSBoundParameters.ContainsKey('r18')) -and `
            (-not ($PSBoundParameters.ContainsKey('dmm')) -and `
                (-not ($PSBoundParameters.ContainsKey('javlibrary')) -and `
                    (-not ($PSBoundParameters.ContainsKey('javlibraryzh')) -and `
                        (-not ($PSBoundParameters.ContainsKey('javlibraryja')) -and `
                                -not ($PSBoundParameters.ContainsKey('r18zh'))))))) {
            if ($settings.Main.'scrape-r18' -eq 'true') {
                $R18 = $true
            }
            if ($settings.Main.'scrape-dmm' -eq 'true') {
                $Dmm = $true
            }
            if ($settings.Main.'scrape-javlibrary' -eq 'true') {
                $Javlibrary = $true
            }
            if ($settings.Main.'scrape-javlibraryzh' -eq 'true') {
                $JavlibraryZh = $true
            }
            if ($settings.Main.'scrape-javlibraryja' -eq 'true') {
                $JavlibraryJa = $true
            }
            if ($settings.Main.'scrape-r18zh' -eq 'true') {
                $R18Zh = $true
            }
        }
    }

    process {
        Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] R18: [$R18]; R18Zh: [$R18Zh] Dmm: [$Dmm]; Javlibrary: [$Javlibrary]; JavlibraryZh: [$JavlibraryZh]; JavlibraryJa: [$JavlibraryJa]"
        switch ($PsCmdlet.ParameterSetName) {
            'Info' {
                $dataObject = Get-FindDataObject -Find $Find -Settings $settings -Aggregated:$Aggregated -Dmm:$Dmm -R18:$R18 -R18Zh:$R18Zh -Javlibrary:$Javlibrary -JavlibraryZh:$JavlibraryZh -JavlibraryJa:$JavlibraryJa
                Write-Output $dataObject
            }

            'Log' {
                if ($OpenLog.IsPresent) {
                    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                        try {
                            Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Opening javinizer.log file from [$javinizerLogPath]"
                            Invoke-Item -Path $javinizerLogPath
                        } catch {
                            Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error opening javinizer.log file from [$javinizerLogPath]"
                            throw $_
                        }
                    } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                        try {
                            Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Opening javinizer.log file from [$javinizerLogPath]"
                            nano $javinizerLogPath
                        } catch {
                            Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error opening javinizer.log file from [$javinizerLogPath]"
                            throw $_
                        }
                    }
                }

                if ($ViewLog) {
                    try {
                        if (!($PSBoundParameters.ContainsKey('Entries'))) {
                            $Entries = 10
                        }

                        if ($PSBoundParameters.ContainsKey('LogLevel')) {
                            Get-Log -Path $javinizerLogPath -LogView $ViewLog -LogLevel $LogLevel -Entries $Entries -Order $Order
                        } else {
                            Get-Log -Path $javinizerLogPath -LogView $ViewLog -Entries $Entries -Order $Order
                        }
                    } catch {
                        Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error displaying javinizer.log from [$javinizerLogPath]: $($PSItem.ToString())"
                    }
                }
            }

            'Settings' {
                if ($OpenSettings.IsPresent) {
                    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                        try {
                            Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Opening settings.ini file from [$settingsPath]"
                            Invoke-Item -Path $settingsPath
                        } catch {
                            Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error opening settings.ini file from [$settingsPath]"
                            throw $_
                        }
                    } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                        try {
                            Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Opening settings.ini file from [$settingsPath]"
                            nano $settingsPath
                        } catch {
                            Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error opening settings.ini file from [$settingsPath]"
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
                        Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Writing settings backup archive to [$BackupSettings]"
                        Compress-Archive @backupSettingsParams
                    } catch {
                        Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error writing settings backup archive to [$BackupSettings]"
                        throw $_
                    }
                } elseif ($PSBoundParameters.ContainsKey('RestoreSettings')) {
                    $restoreSettingsParams = @{
                        LiteralPath     = $RestoreSettings
                        DestinationPath = $ScriptRoot
                        Force           = $true
                    }
                    try {
                        Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Restoring settings backup archive from [$RestoreSettings] to [$ScriptRoot]"
                        Expand-Archive @restoreSettingsParams
                    } catch {
                        Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error restoring settings backup archive to [$ScriptRoot] from [$RestoreSettings]"
                        throw $_
                    }
                }
            }

            'Help' {
                help Javinizer
            }

            'Version' {
                Get-InstalledModule -Name Javinizer
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
                        Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Neither [Path] nor [Apply] parameters are specified; Exiting..."
                        return
                    }
                    $Path = ($settings.Locations.'input-path') -replace '"', ''
                    $DestinationPath = ($settings.Locations.'output-path') -replace '"', ''
                }

                try {
                    $getPath = Get-Item -LiteralPath ($Path).replace('`[', '[').replace('`]', ']') -ErrorAction Stop
                } catch {
                    Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Path: [$Path] does not exist; Exiting..."
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
                    Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Destination Path: [$DestinationPath] does not exist; Attempting to create the directory..."
                    New-Item -ItemType Directory -LiteralPath $DestinationPath -Confirm | Out-Null
                    $getDestinationPath = Get-Item -LiteralPath $DestinationPath -ErrorAction Stop
                } catch {
                    throw $_
                }

                try {
                    Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Attempting to read file(s) from path: [$($getPath.FullName)]"
                    $fixedPath = ($getPath.FullName).replace('[', '`[').replace(']', '`]')
                    $fileDetails = Convert-JavTitle -Path $fixedPath -Recurse:$Recurse -Settings $settings -Strict:$Strict
                } catch {
                    Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Path: [$Path] does not contain any video files or does not exist; Exiting..."
                    return
                }
                #Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Converted file details: [$($fileDetails)]"

                # Match a single file and perform actions on it
                if ((Test-Path -LiteralPath $getPath.FullName -PathType Leaf) -and (Test-Path -LiteralPath $getDestinationPath.FullName -PathType Container)) {
                    Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Detected path: [$($getPath.FullName)] as single item"
                    Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] ($index of $($fileDetails.Count)) Sorting [$($fileDetails.OriginalFileName)]"
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
                        $dataObject = Get-AggregatedDataObject -FileDetails $fileDetails -Settings $settings -R18:$R18 -R18Zh:$R18Zh -Dmm:$Dmm -Javlibrary:$Javlibrary -JavlibraryZh:$JavlibraryZh -JavlibraryJa:$JavlibraryJa -ErrorAction 'SilentlyContinue' -ScriptRoot $ScriptRoot
                        Set-JavMovie -DataObject $dataObject -Settings $settings -Path $getPath.FullName -DestinationPath $getDestinationPath.FullName -ScriptRoot $ScriptRoot
                    }
                    # Match a directory/multiple files and perform actions on them
                } elseif (((Test-Path -LiteralPath $getPath.FullName -PathType Container) -and (Test-Path -LiteralPath $getDestinationPath.FullName -PathType Container)) -or $Apply.IsPresent) {
                    Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Detected path: [$($getPath.FullName)] as directory and destinationpath: [$($getDestinationPath.FullName)] as directory"
                    Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Sort path: [$($getPath.FullName)]"
                    Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Destination path: [$($getDestinationPath.FullName)]"
                    Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Included file ext: [$($Settings.General.'included-file-extensions')]"
                    Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Excluded file strings: [$($Settings.General.'excluded-file-strings')]"

                    if ($Multi.IsPresent) {
                        $throttleCount = $Settings.General.'multi-sort-throttle-limit'
                        try {
                            if ($Javlibrary) {
                                New-CloudflareSession -ScriptRoot $ScriptRoot
                            }

                            if ($Settings.General.'move-to-folder' -eq 'True') {
                                $movePreference = $true
                            } else {
                                $movePreference = $false
                            }

                            if ($Settings.General.'rename-file' -eq 'True') {
                                $renamePreference = $true
                            } else {
                                $renamePreference = $false
                            }

                            Start-MultiSort -Path $getPath.FullName -Throttle $throttleCount -Recurse:$Recurse -DestinationPath $getDestinationPath.FullName -Strict:$Strict -MoveToFolder:$movePreference -RenameFile:$renamePreference -Force:$Force -Settings $settings

                        } catch {
                            Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] There was an error starting multi sort for path: [$($getPath.FullName)] with destinationpath: [$DestinationPath] and threads: [$throttleCount]"
                        } finally {
                            # Stop all running jobs if script is stopped by user input
                            Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Sort has completed or has been stopped prematurely; Stopping all running jobs..."
                            Get-RSJob | Stop-RSJob
                        }
                    } else {
                        foreach ($video in $fileDetails) {
                            Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] ($index of $($fileDetails.Count)) Sorting [$($video.OriginalFileName)]"
                            $dataObject = Get-AggregatedDataObject -FileDetails $video -Settings $settings -R18:$R18 -R18Zh:$R18Zh -Dmm:$Dmm -Javlibrary:$Javlibrary -JavlibraryZh:$JavlibraryZh -JavlibraryJa:$JavlibraryJa -ScriptRoot $ScriptRoot -ErrorAction 'SilentlyContinue'
                            Set-JavMovie -DataObject $dataObject -Settings $settings -Path $video.OriginalFullName -DestinationPath $getDestinationPath.FullName -Force:$Force -ScriptRoot $ScriptRoot
                            $index++
                        }
                    }
                } else {
                    throw "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Specified Path: [$Path] and/or DestinationPath: [$DestinationPath] did not match allowed types"
                }
            }
        }
    }

    end {
        Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
