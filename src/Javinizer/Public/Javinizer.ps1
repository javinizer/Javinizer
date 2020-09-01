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

    .PARAMETER SetJavlibraryOwned
        The setjavlibraryowned parameter lets you reference a path to a list of your JAV movies in line separated format in a flat text file to set as owned on JAVLibrary

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

    .Parameter Javbus
        The javbus parameter allows you to set your data source of JAVLibraryJa to true.

    .Parameter JavbusJa
        The javbusja parameter allows you to set your data source of JAVLibraryJa to true.

    .Parameter Jav321
        The jav321 parameter allows you to set your data source of JAVLibraryJa to true.

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
        [Parameter(ParameterSetName = 'Path', Position = 0)]
        [System.IO.DirectoryInfo]$Path,

        [Parameter(ParameterSetName = 'Path', Position = 1)]
        [System.IO.DirectoryInfo]$DestinationPath,

        [Parameter(ParameterSetName = 'Path', Position = 2)]
        [PSObject]$Settings,

        [Parameter(ParameterSetName = 'Info', Mandatory = $true, Position = 0)]
        [Alias ('f')]
        [PSObject]$Find,

        [Parameter(ParameterSetNAme = 'Info')]
        [Switch]$Aggregated,

        [Parameter(ParameterSetNAme = 'Info')]
        [Switch]$Nfo,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$R18,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$R18Zh,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$Dmm,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$Javlibrary,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$JavlibraryZh,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$JavlibraryJa,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$Javbus,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$JavbusJa,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$JavbusZh,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$Jav321,

        [Parameter(ParameterSetName = 'Path')]
        [PSObject]$Url,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Recurse,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Force,

        [Parameter(ParameterSetName = 'Emby')]
        [Switch]$SetEmbyThumbs,

        [Parameter(ParameterSetName = 'Emby')]
        [Switch]$ReplaceAll,

        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenSettings,

        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenLog,

        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenThumbs,

        [Parameter(Mandatory = $true, ParameterSetName = 'Thumbs')]
        [Switch]$UpdateThumbs,

        [Parameter(ParameterSetName = 'Thumbs')]
        [PSObject]$Pages,

        [Parameter(ParameterSetName = 'Version')]
        [Alias('v')]
        [Switch]$Version,

        [Parameter(ParameterSetName = 'Help')]
        [Alias('h')]
        [Switch]$Help
    )

    process {
        try {
            if ($Settings) {
                $settingsPath = $Settings
            } else {
                $settingsPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvSettings.json'
            }
            $Settings = Get-Content -LiteralPath $settingsPath | ConvertFrom-Json -Depth 32
        } catch {
            Write-Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when loading settings file [$settingsPath]: $PSItem" -ErrorAction Stop
        }

        if ($Settings.'admin.log' -eq '1') {
            if ($Settings.'admin.log.path' -eq '') {
                $logPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvLog.log'
            } else {
                if (!(Test-Path -LiteralPath $Settings.'admin.log.path' -PathType Leaf)) {
                    New-Item -LiteralPath $Settings.'admin.log.path'
                }
                $logPath = $Settings.'admin.log.path'
            }
            Add-LoggingTarget -Name File -Configuration @{
                Path     = $logPath
                Append   = $true
                Encoding = 'utf8'
                Level    = $Settings.'admin.log.level'
                Format   = '[%{timestamp}] [%{level:-7}] %{message}'
            }
        }

        if ($Settings.'sort.metadata.thumbcsv.path' -eq '') {
            $thumbCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'
        } else {
            if (!(Test-Path -LiteralPath $Settings.'sort.metadata.thumbcsv.path' -PathType Leaf)) {
                New-Item -LiteralPath $Settings.'sort.metadata.thumbcsv.path'
            }
            $thumbCsvPath = $Settings.'sort.metadata.thumbcsv.path'
        }

        if ($Settings.'sort.metadata.genrecsv.path' -eq '') {
            $genreCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvGenres.csv'
        } else {
            if (!(Test-Path -LiteralPath $Settings.'sort.metadata.genrecsv.path' -PathType Leaf)) {
                New-Item -LiteralPath $Settings.'sort.metadata.genrecsv.path'
            }
            $thumbCsvPath = $Settings.'sort.metadata.genrecsv.path'
        }

        switch ($PsCmdlet.ParameterSetName) {
            'Info' {
                if ($Find -match 'https?:\/\/') {
                    $urlObject = Get-JVUrlLocation -Url $Find
                    $data = foreach ($item in $urlObject) {
                        if ($item.Source -eq 'dmm') {
                            $item.Url | Get-DmmData
                        }

                        if ($item.Source -eq 'jav321') {
                            $item.Url | Get-Jav321Data
                        }

                        if ($item.Source -eq 'javbus') {
                            $item.Url | Get-JavbusData
                        }

                        if ($item.Source -eq 'javbusja') {
                            $item.Url | Get-JavbusData
                        }

                        if ($item.Source -eq 'javbuszh') {
                            $item.Url | Get-JavbusData
                        }

                        if ($item.Source -eq 'javlibrary') {
                            $item.Url | Get-JavlibraryData
                        }

                        if ($item.Source -eq 'javlibraryja') {
                            $item.Url | Get-JavlibraryData
                        }

                        if ($item.Source -eq 'javlibraryzh') {
                            $item.Url | Get-JavlibraryData
                        }

                        if ($item.Source -eq 'r18') {
                            $item.Url | Get-R18Data
                        }

                        if ($item.Source -eq 'r18zh') {
                            $item.Url | Get-R18Data
                        }
                    }

                    $data = [PSCustomObject]@{
                        Data = $data
                    }
                } else {
                    $data = Get-JVData -Id $Find -R18:$R18 -R18Zh:$R18Zh -Javlibrary:$Javlibrary -JavlibraryJa:$JavlibraryJa -JavlibraryZh:$JavlibraryZh -Dmm:$Dmm `
                        -Javbus:$Javbus -JavbusJa:$JavbusJa -JavbusZh:$JavbusZh -Jav321:$Jav321
                }

                if ($Aggregated) {
                    $data = $data | Get-JVAggregatedData -Settings $Settings
                }

                if ($Nfo) {
                    $nfo = $data.Data | Get-JVNfo -ActressLanguageJa:$Settings.'sort.metadata.nfo.actresslanguageja' -NameOrder:$Settings.'sort.metadata.nfo.firstnameorder' -AddTag:$Settings.'sort.metadata.nfo.seriesastag'
                    Write-Output $nfo
                } else {
                    Write-Output $data.Data
                }
            }

            'Settings' {
                if ($OpenSettings.IsPresent) {
                    try {
                        Invoke-Item -LiteralPath $settingsPath
                    } catch {
                        Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening settings file [$settingsPath]: $PSItem"
                    }
                }

                if ($OpenLog) {
                    try {
                        Invoke-Item -LiteralPath $logPath
                    } catch {
                        Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening log file [$logPath]: $PSItem"
                    }
                }

                elseif ($OpenThumbs) {
                    try {
                        Invoke-Item -LiteralPath (Join-Path $ScriptRoot -ChildPath 'r18-thumbs.csv')
                    } catch {
                        Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening thumbcsv file [$]: $PSItem"
                    }
                }
            }

            'Help' {
                help Javinizer
            }

            'Version' {
                Get-InstalledModule -Name Javinizer
            }

            'Emby' {
                $Settings | Set-JVEmbyThumbs -ReplaceAll:$ReplaceAll
            }

            'Thumbs' {
                if ($Pages) {
                    Update-JVThumbs -ThumbCsvPath $thumbCsvPath -StartPage $Pages[0] -EndPage $Pages[1]
                } else {
                    Update-JVThumbs -ThumbCsvPath $thumbCsvPath
                }
            }

            'Path' {
                # Default path to location.input in settings if not specified
                if (!($Path)) {
                    $Path = $Settings.'location.input'
                }

                # This will check that the Path is valid
                if (!(Test-Path -LiteralPath $Path)) {
                    Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Path [$Path] is not a valid path"
                }

                # Default destination path to location.output in settings if not specified
                if (!($DestinationPath)) {
                    $DestinationPath = $Settings.'location.output'
                }

                # This will check that the DestinationPath is a valid directory
                if (Test-Path -LiteralPath $DestinationPath -PathType Leaf) {
                    Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] DestinationPath [$DestinationPath] is not a valid directory path"
                }

                try {
                    $javMovies = $Settings | Get-JVItem -Path $Path -Recurse:$Recurse -Strict:$Strict
                    Write-Host "[$($MyInvocation.MyCommand.Name)] [Path - $Path] [DestinationPath - $DestinationPath] [Files - $($javMovies.Count)]"
                } catch {
                    Write-JVLog -Level Warning -Message "Exiting -- no valid movies detected in [$Path]"
                }

                if ($Url) {
                    if (Test-Path -LiteralPath $Path -PathType Leaf) {
                        Write-JVLog -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] Exiting -- [$Path] is not a valid file path"
                    }


                } else {
                    $index = 1
                    foreach ($movie in $javMovies) {
                        Write-Host "[$index of $($javMovies.Count)] Sorting [$($movie.FileName)] as [$($movie.Id)]"
                        $index++
                        $javData = Get-JVData -Settings $Settings -Id $movie.Id
                        if ($null -ne $javData) {
                            $javAggregatedData = $javData | Get-JVAggregatedData -Settings $Settings | Test-JVData -RequiredFields $Settings.'sort.metadata.requiredfield'
                            if ($null -ne $javAggregatedData) {
                                $javAggregatedData | Set-JVMovie -Path $movie.FullName -DestinationPath $DestinationPath -Settings $Settings -PartNumber $movie.Partnumber -Force:$Force
                            } else {
                                Write-JVLog -Level Warning -Message "[$($movie.FileName)] Skipped -- missing required metadata fields"
                                return
                            }
                        } else {
                            Write-JVLog -Level Warning -Message "[$($movie.FileName)] Skipped -- not matched"
                        }
                    }
                }
            }
        }
    }
}
