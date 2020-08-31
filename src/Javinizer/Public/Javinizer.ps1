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
        [Parameter(ParameterSetName = 'Info', Mandatory = $true, Position = 0)]
        [Alias ('f')]
        [PSObject]$Find,
        [Parameter(ParameterSetNAme = 'Info')]
        [Switch]$Aggregated,
        [Parameter(ParameterSetNAme = 'Info')]
        [Switch]$ShowNfo,
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
        [Parameter(ParameterSetName = 'Path', Position = 0)]
        [Alias('p')]
        [System.IO.DirectoryInfo]$Path,
        [Parameter(ParameterSetName = 'Path', Position = 1)]
        [Alias('d')]
        [System.IO.DirectoryInfo]$DestinationPath,
        [Parameter(ParameterSetName = 'Path')]
        [Alias('u')]
        [Array]$Url,
        [Parameter(ParameterSetName = 'Path')]
        [Alias('m')]
        [Switch]$Multi,
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'JavLibrary')]
        [Switch]$Recurse,
        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Force,
        [Parameter(ParameterSetName = 'Path')]
        [PSObject]$Settings,
        [Parameter(ParameterSetName = 'Path')]
        [String]$ImportSettings,
        [Parameter(ParameterSetName = 'Help')]
        [Alias('h')]
        [Switch]$Help,
        [Parameter(ParameterSetName = 'Version')]
        [Alias('v')]
        [Switch]$Version,
        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenSettings,
        [Parameter(ParameterSetName = 'Settings')]
        [String]$BackupSettings,
        [Parameter(ParameterSetName = 'Settings')]
        [String]$RestoreSettings,
        [Parameter(ParameterSetName = 'Log')]
        [Switch]$OpenLog,
        [Parameter(ParameterSetName = 'JavLibrary')]
        [String]$SetJavlibraryOwned,
        [Parameter(ParameterSetName = 'Thumbs')]
        [Switch]$GetThumbs,
        [Parameter(ParameterSetName = 'Thumbs')]
        [Int]$UpdateThumbs,
        [Parameter(ParameterSetName = 'Thumbs')]
        [Switch]$OpenThumbs,
        [Parameter(ParameterSetName = 'Thumbs')]
        [Switch]$SetEmbyActorThumbs
    )

    begin {
        $urlLocation = @()

        if (!($Multi.IsPresent -or $GetThumbs.IsPresent -or $UpdateThumbs.IsPresent)) {
            $ProgressPreference = 'SilentlyContinue'
        }



        <#         try {
            # Allow user to update settings via commandline using a hashtable
            # I.e $updateSettings = @{ "priority.actress" = @('r18', 'javlibrary', dmm'); "moveToFolder" = "true"}
            # Javinizer -Path . -Settings $updateSettings
            foreach ($setting in $Settings.GetEnumerator()) {
                $nest = $setting.Key -split '\.'
                if ($nest.Count -eq 1) {
                    $root = $nest[0]
                    $script:gSettings.$root = $setting.Value
                } elseif ($nest.Count -eq 2) {
                    $root = $nest[0]
                    $key = $nest[1]
                    $script:gSettings.$root.$key = $setting.Value
                } elseif ($nest.Count -eq 3) {
                    $root = $nest[0]
                    $nestOne = $nest[1]
                    $key = $nest[2]
                    $script:gSettings.$root.$nestOne.$key = $setting.Value
                } elseif ($nest.Count -eq 4) {
                    $root = $nest[0]
                    $nestOne = $nest[1]
                    $nestTwo = $nest[2]
                    $key = $nest[3]
                    $script:gSettings.$root.$nestOne.$nestTwo.$key = $setting.Value
                }
            }
        } catch {
            Write-JLog -Level Error -Message $_
        } #>
    }

    process {
        $settingsPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvSettings.json'
        $Settings = Get-Content -LiteralPath $settingsPath | ConvertFrom-Json -Depth 32

        if ($Settings.'admin.log.path' -eq '') {
            $logPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvLog.log'
        } else {
            $logPath = $Settings.'admin.log.path'
        }

        # The user will be able import an external settings file via commandline
        # by using the ImportSettings parameter
        <#         try {
            # TODO Change this path
            $gSettingsPath = 'X:\git\Projects\JAV-Organizer\src\Javinizer\javinizerSettings.json'
            if ($PSBoundParameters.ContainsKey('ImportSettings')) {
                $script:gSettings = Get-Content -LiteralPath $ImportSettings | ConvertFrom-Json
            } else {
                $script:gSettings = Get-Content -LiteralPath $gSettingsPath | ConvertFrom-Json
            }
        } catch {
            throw $_
        } #>

        Add-LoggingTarget -Name File -Configuration @{
            Path     = $logPath
            Append   = $true
            Encoding = 'utf8'
            Level    = $Settings.'admin.log.level'
            Format   = '[%{timestamp}] [%{level:-7}] %{message}'
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

                if ($ShowNfo) {
                    $nfo = $data.Data | Get-JVNfo -ActressLanguageJa:$Settings.'sort.metadata.nfo.actresslanguageja' -NameOrder:$Settings.'sort.metadata.nfo.firstnameorder' -AddTag:$Settings.'sort.metadata.nfo.seriesastag'
                    Write-Output $nfo
                } else {
                    Write-Output $data.Data
                }
            }

            'Log' {
                if ($OpenLog) {
                    try {
                        Invoke-Item -LiteralPath $logPath
                    } catch {
                        Write-JLog -Level Error -Message "Error occurred when opening log file [$logPath]: $PSItem"
                    }
                }
            }

            'Settings' {
                if ($OpenSettings.IsPresent) {
                    try {
                        Invoke-Item -Path $settingsPath
                    } catch {
                        Write-JLog -Level Error -Message "Error occurred when opening settings file [$settingsPath]: $PSItem"
                    }
                }
            }

            'JavLibrary' {
                # TODO Re-check without creating a cloudflare session
                if (!($Session)) {
                    New-CloudflareSession -ScriptRoot $ScriptRoot
                }

                try {
                    Write-JLog -Level Debug -Message "Getting owned movies on JAVLibrary"
                    $request = Invoke-WebRequest -Uri "https://www.javlibrary.com/en/mv_owned_print.php" -Verbose:$false -Headers @{
                        "method"                    = "GET"
                        "authority"                 = "www.javlibrary.com"
                        "scheme"                    = "https"
                        "path"                      = "/en/mv_owned_print.php"
                        "upgrade-insecure-requests" = "1"
                        "user-agent"                = $session.UserAgent
                        "accept"                    = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
                        "sec-fetch-site"            = "none"
                        "sec-fetch-mode"            = "navigate"
                        "sec-fetch-user"            = "?1"
                        "sec-fetch-dest"            = "document"
                        "accept-encoding"           = "gzip, deflate, br"
                        "accept-language"           = "en-US,en;q=0.9"
                        "cookie"                    = "__cfduid=$SessionCFDUID; timezone=420; over18=18; userid=$($Settings.JavLibrary.username); session=$($Settings.JavLibrary.'session-cookie')"
                    }

                    $javlibraryOwnedMovies = ($request.content -split '<td class="title">' | ForEach-Object { (($_ -split '<\/td>')[0] -split ' ')[0] })
                    $global:javlibraryOwnedMovies = $javlibraryOwnedMovies[2..($javlibraryOwnedMovies.Length - 1)]
                } catch {
                    Write-JLog -Level Error -Message "Error getting existing owned movies on JAVLibrary: $PSItem"
                    return
                }

                if ($null -ne $global:javlibraryOwnedMovies) {
                    if ($global:javlibraryOwnedMovies.Count -gt 1) {
                        if ($javlibraryOwnedMovies[0].Length -le 1) {
                            Write-JLog -Level Error -Message "Error authenticating to JAVLibrary to set owned movies, check that your username and sessionCookie are valid"
                        }
                    }
                }

                try {
                    if (Test-Path -Path $SetJavLibraryOwned -PathType Leaf) {
                        $movieList = Get-Content -LiteralPath $SetJavLibraryOwned
                    } else {
                        $movieList = (Convert-JavTitle -Path $SetJavLibraryOwned -Recurse:$Recurse -Settings $Settings -Strict:$Strict).Id
                    }
                } catch {
                    Write-JLog -Level Error -Message "Error getting movies from [$SetJavLibraryOwned]: $PSItem"
                }

                # Validate which movies in the current path are unowned
                # This will avoid trying to re-add currently existing movies on JAVLibrary
                $unowned = @()
                foreach ($movie in $movieList) {
                    if (!($javlibraryOwnedMovies -match $movie)) {
                        $unowned += $movie
                    }
                }

                Write-JLog -Level Info -Message "[$($unowned.Count)] movies to add"

                if ($unowned.Count -ge 1) {
                    $index = 1
                    foreach ($movie in $unowned) {
                        Write-JLog -Level Info -Message "($index of $($unowned.Count)) Setting [$movie] as owned on JAVLibrary"
                        $javlibObject = Get-JavlibraryData -Name $movie
                        if ($null -ne $javlibObject) {
                            $ajaxId = $javlibObject.AjaxId
                            $url = $javlibObject.Url
                            Set-JavlibraryOwned -AjaxId $ajaxId -JavlibraryUrl $url -Settings $settings
                            Start-Sleep -Seconds $Settings.JavLibrary.'request-interval-sec'
                        } else {
                            Write-JLog -Level Warning -Message "Skipping [$movie] -- not matched on JAVLibrary"
                        }
                        $index++
                    }
                } else {
                    Write-JLog -Level Warning -Message "Exiting -- no new movies detected in [$SetJavLibraryOwned]"
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
                    Get-R18ThumbCsv -ScriptRoot $ScriptRoot -Settings $settings -Force:$Force
                } elseif ($OpenThumbs.IsPresent) {
                    try {
                        Invoke-Item -Path (Join-Path $ScriptRoot -ChildPath 'r18-thumbs.csv')
                    } catch {
                        Write-JLog -Level Error -Message "Error opening thumb csv: $PSItem"
                    }
                } elseif ($PSBoundParameters.ContainsKey('UpdateThumbs')) {
                    Get-R18ThumbCsv -ScriptRoot $ScriptRoot -NewPages $UpdateThumbs -Force:$Force
                } elseif ($SetEmbyActorThumbs.IsPresent) {
                    Set-EmbyActors -Settings $settings -ScriptRoot $ScriptRoot
                }
            }

            'Path' {
                # Default path to location.input in settings if not specified
                if (!($Path)) {
                    $Path = $Settings.'location.input'
                }

                # This will check that the Path is valid
                if (!(Test-Path -LiteralPath $Path)) {
                    Write-JLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Path [$Path] is not a valid path"
                }

                # Default destination path to location.output in settings if not specified
                if (!($DestinationPath)) {
                    $DestinationPath = $Settings.'location.output'
                }

                if ($Url) {

                }

                # This will check that the DestinationPath is a valid directory
                if (Test-Path -LiteralPath $DestinationPath -PathType Leaf) {
                    Write-JLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] DestinationPath [$DestinationPath] is not a valid directory path"
                }

                try {
                    $javMovies = $Settings | Get-JVItem -Path $Path -Recurse:$Recurse -Strict:$Strict
                    Write-Host "[$($MyInvocation.MyCommand.Name)] [Path - $Path] [DestinationPath - $DestinationPath] [Count - $($javMovies.Count)]"
                } catch {
                    Write-JLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Exiting -- no movies detected in [$Path]"
                }

                $index = 1
                foreach ($movie in $javMovies) {
                    Write-Host "[$index of $($javMovies.Count)] Sorting [$($movie.FileName)] as [$($movie.Id)]"
                    $javData = Get-JVData -Settings $Settings -Id $movie.Id
                    $javAggregatedData = $javData | Get-JVAggregatedData -Settings $Settings
                    $javAggregatedData | Set-JVMovie -Path $movie.FullName -DestinationPath $DestinationPath -Settings $Settings -PartNumber $movie.Partnumber
                    $index++
                }
            }
        }
    }
}
