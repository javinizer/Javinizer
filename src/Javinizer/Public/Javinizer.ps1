function Javinizer {

    <#
    .SYNOPSIS
        A command-line based tool to scrape and sort your local Japanese Adult Video (JAV) files.

    .DESCRIPTION
        Javinizer detects your local JAV files and structures them into media library compatible
        formats. A metadata nfo file is created per file to be read by the media library.

    .PARAMETER Path
        Specifies the file or directory path to JAV files. Defaults to 'location.input' in the settings file.

    .PARAMETER DestinationPath
        Specifies the directory path to output sorted JAV files. Defaults to 'location.output' in the settings file.

    .PARAMETER Recurse
        Specifies to search sub-directories in your Path.

    .PARAMETER Depth
        Specifies the depth of sub-directories to search when using -Recurse.

    .PARAMETER Url
        Specifies a url or an array of urls to sort a single JAV file.

    .PARAMETER Update
        Specifies to only create/update metadata files without moving any existing files.

    .PARAMETER SettingsPath
        Specifies the path to the settings file you want Javinizer to use. Defaults to the jvSettings.json file in the module root.

    .PARAMETER Strict
        Specifies to not automatically try to match filenames to the movie ID. Can be useful for movies like T28- and R18-.

    .PARAMETER MoveToFolder
        Specifies whether or not to move sorted files to its own folder. Defaults to 'sort.movetofolder' in the settings file.

    .PARAMETER RenameFile
        Specifies whether or not to rename sorted files. Defaults to 'sort.renamefile' in the settings file.

    .PARAMETER Force
        Specifies to replace all sort files (nfo, images, trailers, etc.) if they already exist. Without -Force,
        only the nfo file will be replaced if it already exists.

    .PARAMETER HideProgress
        Specifies to hide the progress bar during sort.

    .PARAMETER IsThread
        Specifies that the current running Javinizer instance is a thread. This is for internal purposes only.

    .PARAMETER Find
        Specifies an ID or an array of URLs to search metadata for.

    .PARAMETER Aggregated
        Specifies to aggregate the data from -Find according to your settings.

    .PARAMETER Nfo
        Specifies to output the nfo contents from -Find.

    .PARAMETER R18
        Specifies to search R18 when using -Find.

    .PARAMETER R18Zh
        Specifies to search R18-Chinese when using -Find.

    .PARAMETER Dmm
        Specifies to search Dmm when using -Find.

    .PARAMETER DmmJa
        Specifies to search Dmm-Japanese when using -Find.

    .PARAMETER Javlibrary
        Specifies to search Javlibrary when using -Find.

    .PARAMETER JavlibraryZh
        Specifies to search Javlibrary-Chinese when using -Find.

    .PARAMETER JavlibraryJa
        Specifies to search Javlibrary-Japanese when using -Find.

    .PARAMETER Javbus
        Specifies to search Javbus when using -Find.

    .PARAMETER JavbusJa
        Specifies to search Javbus-Japanese when using -Find.

    .PARAMETER JavbusZh
        Specifies to search Javbus-Chinese when using -Find.

    .PARAMETER Jav321Ja
        Specifies to search Jav321-Japanese when using -Find.

    .PARAMETER SetEmbyThumbs
        Specifies to set Emby/Jellyfin actress thumbnails using the thumbnail csv. If 'location.thumbcsv' is not specified in the settings file,
        it defaults to the jvGenres.csv file in the module root. 'emby.url' and 'emby.apikey' need to be defined in the settings file.

    .PARAMETER EmbyUrl
        Specifies the Emby/Jellyfin baseurl instead of using the setting 'emby.url'.

    .PARAMETER EmbyApiKey
        Specifies the Emby/Jellyfin API key instead of using th setting 'emby.apikey'.

    .PARAMETER ReplaceAll
        Specifies to replace all Emby/Jellyfin actress thumbnails regardless if they already have one.

    .PARAMETER OpenSettings
        Specifies to open the settings file.

    .PARAMETER OpenLog
        Specifies to open the log file.

    .PARAMETER OpenThumbs
        Specifies to open the actress thumbnails file.

    .PARAMETER OpenGenres
        Specifies to open the genre replacements file.

    .PARAMETER OpenUncensor
        Specifies to open the uncensor replacements file.

    .PARAMETER UpdateThumbs
        Specifies to update the actress thumbnails file.

    .PARAMETER Pages
        Specifies an array as a range of pages to search for and update the actress thumbnails file.

    .PARAMETER Set
        Specifies a hashtable to update specific settings on the command-line.

    .PARAMETER SetOwned
        Specifies to set a path of movie files as owned on JavLibrary.

    .PARAMETER Version
        Specifies to display the Javinizer module version.

    .PARAMETER Help
        Specifies to display the Javinizer help.

    .EXAMPLE
    Javinizer

    Description
    -----------
    Sorts a path of files using 'location.input' and 'location.output' from your settings file.

    .EXAMPLE
    Javinizer -Path 'C:\JAV\Unsorted\ABP-420.mp4' -DestinationPath 'C:\JAV\Sorted'

    Description
    -----------
    Sorts a single file and move it to the destination path.

    .EXAMPLE
    Javinizer -Path 'C:\JAV\Unsorted\ABP-420.mp4' -Url 'http://www.javlibrary.com/en/?v=javlilb54i', 'https://www.r18.com/[..]/id=118abp00420/'

    Description
    -----------
    Sorts a single file using specific urls.

    .EXAMPLE
    Javinizer -Path 'C:\JAV\Unsorted' -Strict

    Description
    -----------
    Sorts a path of JAV files without attemping automatic filename cleaning.

    .EXAMPLE
    Javinizer -Path 'C:\JAV\Sorted' -Recurse -Update

    Description
    -----------
    Sorts a path of JAV files while only updating/creating metadata without moving any existing files.

    .EXAMPLE
    Javinizer -Path 'C:\JAV\Sorted' -Set @{'sort.download.actressimg' = 1; 'sort.format.file' = '<ID> - <TITLE>'}

    Description
    -----------
    Sorts files from a path and specify updated settings from the commmand-line using a hashtable.

    .EXAMPLE
    Javinizer -Path 'C:\JAV\Sorted' -SettingsPath 'C:\JAV\alternateSettings.json'

    Description
    -----------
    Sorts files from a path and specify an external settings file to use.

    .EXAMPLE
    Javinizer -Find 'ABP-420' -R18 -Dmm

    Description
    -----------
    Find a movie metadata on R18 and DMM by specifying its id.

    .EXAMPLE
    Javinizer -Find 'http://www.javlibrary.com/en/?v=javlilb54i', 'https://www.r18.com/[..]/id=118abp00420/' -Aggregated

    Description
    -----------
    Find an array of urls metadata and aggregates them according to your settings file.

    .EXAMPLE
    Javinizer -Find 'ABP-420' -R18 -Javlibrary -Dmm -Aggregated -Nfo

    Description
    -----------
    Find a movie metadata on R18 and DMM by specifying its id, aggrregates the data, and outputs the corresponding nfo contents.

    .EXAMPLE
    Javinizer -SetEmbyThumbs

    Description
    -----------
    Sets missing Emby/Jellyfin actress thumbnails using the actress thumbnail file. Settings 'emby.url' and 'emby.apikey' need to be defined.

    .EXAMPLE
    Javinizer -SetEmbyThumbs -ReplaceAll

    Description
    -----------
    Sets/replaces all Emby/Jellyfin actress thumbnails using the actress thumbnail file. Settings 'emby.url' and 'emby.apikey' need to be defined.

    .EXAMPLE
    Javinizer -Path 'C:\JAV\Sorted' -Recurse -UpdateNfo

    Description
    -----------
    Updates existing sorted nfo files from a path with updated aliases, thumburls, names, ignored genres, and genre replacements according to the settings.

    .EXAMPLE
    Javinizer -UpdateThumbs -Pages 1,10

    Description
    -----------
    Updates the actress csv file using a range of pages to scrape from.

    .EXAMPLE
    Javinizer -OpenSettings

    Description
    -----------
    Opens the settings file.

    .EXAMPLE
    Javinizer -Path 'C:\JAV\Sorted' -Recurse -SetOwned

    Description
    -----------
    Sets movies detected in a directory as owned on JavLibrary.
    #>

    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (

        [Parameter(ParameterSetName = 'Path', Position = 0)]
        [Parameter(ParameterSetName = 'Nfo', Position = 0)]
        [Parameter(ParameterSetName = 'Javlibrary', Position = 0)]
        [AllowEmptyString()]
        [System.IO.FileInfo]$Path,

        [Parameter(ParameterSetName = 'Path', Position = 1)]
        [AllowEmptyString()]
        [System.IO.DirectoryInfo]$DestinationPath,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'Nfo')]
        [Parameter(ParameterSetName = 'Javlibrary')]
        [Switch]$Recurse,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'Nfo')]
        [Parameter(ParameterSetName = 'Javlibrary')]
        [Int]$Depth,

        [Parameter(ParameterSetName = 'Path')]
        [Array]$Url,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'Nfo')]
        [Parameter(ParameterSetName = 'Info')]
        [Parameter(ParameterSetName = 'Javlibrary')]
        [System.IO.FileInfo]$SettingsPath,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetNAme = 'Info')]
        [Parameter(ParameterSetName = 'Javlibrary')]
        [Switch]$Strict,

        [Parameter(ParameterSetName = 'Path')]
        [Boolean]$MoveToFolder,

        [Parameter(ParameterSetName = 'Path')]
        [Boolean]$RenameFile,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Force,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'Javlibrary')]
        [Switch]$HideProgress,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Update,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$IsThread,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$IsWeb,

        [Parameter(ParameterSetName = 'Path')]
        [ValidateSet('Search', 'Sort')]
        [String]$IsWebType,

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
        [Switch]$DmmJa,

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
        [Switch]$Jav321Ja,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$MgstageJa,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$Aventertainment,

        [Parameter(ParameterSetName = 'Info')]
        [Switch]$AventertainmentJa,

        [Parameter(ParameterSetName = 'Info')]
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'Javlibrary')]
        [PSObject]$CfSession,

        [Parameter(ParameterSetName = 'Emby')]
        [Switch]$SetEmbyThumbs,

        [Parameter(ParameterSetName = 'Emby')]
        [String]$EmbyUrl,

        [Parameter(ParameterSetName = 'Emby')]
        [String]$EmbyApiKey,

        [Parameter(ParameterSetName = 'Emby')]
        [Switch]$ReplaceAll,

        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenSettings,

        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenLog,

        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenThumbs,

        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenGenres,

        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenUncensor,

        [Parameter(ParameterSetName = 'Nfo', Mandatory = $true)]
        [Switch]$UpdateNfo,

        [Parameter(ParameterSetName = 'Thumbs', Mandatory = $true)]
        [Switch]$UpdateThumbs,

        [Parameter(ParameterSetName = 'Thumbs')]
        [Array]$Pages,

        [Parameter(ParameterSetName = 'Javlibrary')]
        [Switch]$SetOwned,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetNAme = 'Info')]
        [Parameter(ParameterSetName = 'Settings')]
        [Parameter(ParameterSetName = 'Emby')]
        [Parameter(ParameterSetName = 'Thumbs')]
        [Parameter(ParameterSetName = 'Javlibrary')]
        [Hashtable]$Set,

        [Parameter(ParameterSetName = 'Version', Mandatory = $true)]
        [Alias('v')]
        [Switch]$Version,

        [Parameter(ParameterSetName = 'Help', Mandatory = $true)]
        [Alias('h')]
        [Switch]$Help,

        [Parameter(ParameterSetName = 'Gui')]
        [Switch]$InstallGUI,

        [Parameter(ParameterSetName = 'Gui')]
        [Switch]$OpenGUI,

        [Parameter(ParameterSetName = 'Gui')]
        [ValidateRange(0, 65353)]
        [Int]$Port = 5000
    )

    process {
        if ($HideProgress) {
            $ProgressPreference = 'SilentlyContinue'
        }

        try {
            if (!($SettingsPath)) {
                $SettingsPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvSettings.json'
            }
            $Settings = Get-Content -LiteralPath $SettingsPath | ConvertFrom-Json -Depth 32
        } catch {
            Write-Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when loading settings file [$SettingsPath]: $PSItem" -ErrorAction Stop
        }

        if ($Settings.'admin.log' -eq '1') {
            if ($Settings.'location.log' -eq '') {
                $script:JVLogPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvLog.log'
            } else {
                if (!(Test-Path -LiteralPath $Settings.'location.log' -PathType Leaf)) {
                    New-Item -Path $Settings.'location.log' | Out-Null
                }
                $script:JVLogPath = $Settings.'location.log'
            }

            $script:JVLogWrite = '1'
            $script:JVLogWriteLevel = $Settings.'admin.log.level'
        } else {
            $script:JVLogWrite = 0
        }

        if ($Settings.'location.historycsv' -eq '') {
            $historyCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvHistory.csv'
        } else {
            if (!(Test-Path -LiteralPath $Settings.'location.historycsv' -PathType Leaf)) {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Thumb csv not found at path [$($Settings.'location.historycsv')]"
                return
            } else {
                $historyCsvPath = $Settings.'location.historycsv'
            }
        }

        if ($Settings.'location.thumbcsv' -eq '') {
            $thumbCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'
        } else {
            if (!(Test-Path -LiteralPath $Settings.'location.thumbcsv' -PathType Leaf)) {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Thumb csv not found at path [$($Settings.'location.thumbcsv')]"
                return
            } else {
                $thumbCsvPath = $Settings.'location.thumbcsv'
            }
        }

        if ($Settings.'location.genrecsv' -eq '') {
            $genreCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvGenres.csv'
        } else {
            if (!(Test-Path -LiteralPath $Settings.'location.genrecsv' -PathType Leaf)) {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Genre csv not found at path [$($Settings.'location.genrecsv')]"
                return
            } else {
                $genreCsvPath = $Settings.'location.genrecsv'
            }
        }

        if ($Settings.'location.uncensorcsv' -eq '') {
            $uncensorCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvUncensor.csv'
        } else {
            if (!(Test-Path -LiteralPath $Settings.'location.uncensorcsv' -PathType Leaf)) {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Uncensor csv not found at path [$($Settings.'location.uncensorcsv')]"
                return
            } else {
                $uncensorCsvPath = $Settings.'location.uncensorcsv'
            }
        }

        if ($PSBoundParameters.ContainsKey('MoveToFolder')) {
            if ($MoveToFolder -eq $true) {
                $Settings.'sort.movetofolder' = 1
            } elseif ($MoveToFolder -eq $false) {
                $Settings.'sort.movetofolder' = 0
            }
        }

        if ($PSBoundParameters.ContainsKey('RenameFile')) {
            if ($RenameFile -eq $true) {
                $Settings.'sort.renamefile' = 1
            } elseif ($RenameFile -eq $false) {
                $Settings.'sort.renamefile' = 0
            }
        }

        if ($Set) {
            try {
                foreach ($item in $Set.GetEnumerator()) {
                    $Settings."$($item.Key)" = $item.Value
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - $($item.Key)] replaced as [$($item.Value)]"
                }
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when defining settings using -Set: $PSItem"
            }
        }

        # Validate the values in the settings file following all command-line transformations
        $Settings = $Settings | Test-JVSettings

        if (!($IsThread)) {
            if (($Settings.'scraper.movie.javlibrary' -or $Settings.'scraper.movie.javlibraryja' -or $Settings.'scraper.movie.javlibraryzh' -and $Path) -or ($Javlibrary -or $JavlibraryZh -or $JavlibraryJa) -or ($Find -like '*javlibrary*' -or $Find -like '*g46e*' -or $Find -like '*m45e*') -or $SetOwned) {
                if (!($CfSession)) {
                    try {
                        Invoke-WebRequest -Uri $Settings.'javlibrary.baseurl' -Verbose:$false | Out-Null
                    } catch {
                        try {
                            $CfSession = Get-CfSession -Cfduid:$Settings.'javlibrary.cookie.cfduid' -Cfclearance:$Settings.'javlibrary.cookie.cfclearance' -UserAgent:$Settings.'javlibrary.browser.useragent' -BaseUrl $Settings.'javlibrary.baseurl'
                            # Testing with the newly created session sometimes fails if there is no wait time
                            Start-Sleep -Seconds 1
                            Invoke-WebRequest -Uri $Settings.'javlibrary.baseurl' -WebSession $CfSession -UserAgent $CfSession.UserAgent -Verbose:$false | Out-Null
                        } catch {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] Unable reach Javlibrary, enter websession/cookies to use the scraper"
                            $CfSession = Get-CfSession -BaseUrl $Settings.'javlibrary.baseurl'
                            # Testing with the newly created session sometimes fails if there is no wait time
                            Start-Sleep -Seconds 1
                            try {
                                Invoke-WebRequest -Uri $Settings.'javlibrary.baseurl' -WebSession $CfSession -UserAgent $CfSession.UserAgent -Verbose:$false | Out-Null
                            } catch {
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Unable reach Javlibrary, invalid websession values"
                            }
                        }
                    }
                } else {
                    try {
                        Invoke-WebRequest -Uri $Settings.'javlibrary.baseurl' -WebSession $CfSession -UserAgent $CfSession.UserAgent -Verbose:$false | Out-Null
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Unable reach Javlibrary, invalid websession values"
                    }
                }

                if ($CfSession) {
                    $originalSettingsContent = Get-Content -Path $SettingsPath
                    $cookies = $CfSession.Cookies.GetCookies($Settings.'javlibrary.baseurl')
                    $cfduid = ($cookies | Where-Object { $_.Name -eq '__cfduid' }).Value
                    $cfclearance = ($cookies | Where-Object { $_.Name -eq 'cf_clearance' }).Value
                    $userAgent = $CfSession.UserAgent
                    $settingsContent = $OriginalSettingsContent
                    $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cfduid": ".*"', "`"javlibrary.cookie.cfduid`": `"$cfduid`""
                    $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cfclearance": ".*"', "`"javlibrary.cookie.cfclearance`": `"$cfclearance`""
                    $settingsContent = $settingsContent -replace '"javlibrary\.browser\.useragent": ".*"', "`"javlibrary.browser.useragent`": `"$userAgent`""
                    $origJson = $originalSettingsContent | ConvertFrom-Json
                    $newJson = $settingsContent | ConvertFrom-Json

                    if (($origJson.'javlibrary.browser.useragent' -ne $newJson.'javlibrary.browser.useragent') -or ($origJson.'javlibrary.cookie.cfduid' -ne $newJson.'javlibrary.cookie.cfduid') -or ($origJson.'javlibrary.cookie.cfclearance' -ne $newJson.'javlibrary.cookie.cfclearance')) {
                        $settingsContent | Out-File -FilePath $SettingsPath
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] Replaced Javlibrary settings with updated values in [$SettingsPath]"
                    }
                }
            }
        }

        switch ($PsCmdlet.ParameterSetName) {
            'Gui' {
                if ($InstallGUI) {
                    Install-JVGui
                } elseif ($OpenGUI) {
                    Start-JVGui -Port:$Port
                }
            }


            'Info' {
                if ($Find -match 'https?:\/\/') {
                    $urlObject = Get-JVUrlLocation -Url $Find -Settings $Settings
                    $data = foreach ($item in $urlObject) {
                        if ($item.Source -match 'dmm') {
                            $item.Url | Get-DmmData -ScrapeActress:$Settings.'scraper.option.dmm.scrapeactress'
                        }

                        if ($item.Source -match 'jav321') {
                            $item.Url | Get-Jav321Data
                        }

                        if ($item.Source -match 'javbus') {
                            $item.Url | Get-JavbusData
                        }

                        if ($item.Source -match 'javlibrary') {
                            $item.Url | Get-JavlibraryData -JavlibraryBaseUrl $Settings.'javlibrary.baseurl'
                        }

                        if ($item.Source -match 'r18') {
                            $item.Url | Get-R18Data -UncensorCsvPath:$uncensorCsvPath
                        }

                        if ($item.Source -match 'dlgetchu') {
                            $item.Url | Get-DLgetchuData
                        }

                        if ($item.Source -match 'mgstage') {
                            $item.Url | Get-MgstageData
                        }

                        if ($item.Source -match 'aventertainment') {
                            $item.Url | Get-AventertainmentData
                        }
                    }

                    $data = [PSCustomObject]@{
                        Data = $data
                    }
                } else {
                    $data = Get-JVData -Id $Find -R18:$R18 -R18Zh:$R18Zh -Javlibrary:$Javlibrary -JavlibraryJa:$JavlibraryJa -JavlibraryZh:$JavlibraryZh -Dmm:$Dmm `
                        -DmmJa:$DmmJa -Javbus:$Javbus -JavbusJa:$JavbusJa -JavbusZh:$JavbusZh -Jav321Ja:$Jav321Ja -JavlibraryBaseUrl $Settings.'javlibrary.baseurl' `
                        -MgstageJa:$MgstageJa -Aventertainment:$Aventertainment -AventertainmentJa:$AventertainmentJa -UncensorCsvPath $uncensorCsvPath -Strict:$Strict -Session:$CfSession
                }

                if ($Aggregated) {
                    $data = $data | Get-JVAggregatedData -Settings $Settings
                }

                if ($Nfo) {
                    $nfoData = $data.Data | Get-JVNfo -ActressLanguageJa:$Settings.'sort.metadata.nfo.actresslanguageja' -NameOrder:$Settings.'sort.metadata.nfo.firstnameorder' -AltNameRole:$Settings.'sort.metadata.nfo.altnamerole'
                    Write-Output $nfoData
                } else {
                    Write-Output $data.Data
                }
            }

            'Settings' {
                if ($OpenSettings) {
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] [SettingsPath - $SettingsPath]"
                        Invoke-Item -LiteralPath $SettingsPath
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening settings file [$SettingsPath]: $PSItem"
                    }
                }

                if ($OpenLog) {
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] [LogPath - $script:JVLogPath]"
                        Invoke-Item -LiteralPath $script:JVLogPath
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening log file [$script:JVLogPath]: $PSItem"
                    }
                }

                if ($OpenThumbs) {
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] [ThumbCsvPath - $thumbCsvPath]"
                        Invoke-Item -LiteralPath $thumbCsvPath
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening thumbcsv file [$thumbCsvPath]: $PSItem"
                    }
                }

                if ($OpenGenres) {
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] [GenreCsvPath - $genreCsvPath]"
                        Invoke-Item -LiteralPath $genreCsvPath
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening thumbcsv file [$genreCsvPath]: $PSItem"
                    }
                }

                if ($OpenUncensor) {
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] [UncensorCsvPath - $uncensorCsvPath]"
                        Invoke-Item -LiteralPath $uncensorCsvPath
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening thumbcsv file [$uncensorCsvPath]: $PSItem"
                    }
                }
            }

            'Help' {
                help Javinizer
            }

            'Version' {
                $moduleManifest = Get-Content -LiteralPath (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'Javinizer.psd1')
                [PSCustomObject]@{
                    Version      = ($moduleManifest | Select-String -Pattern "ModuleVersion\s*= '(.*)'").Matches.Groups[1].Value
                    Prerelease   = ($moduleManifest | Select-String -Pattern "Prerelease\s*= '(.*)'").Matches.Groups[1].Value
                    Project      = ($moduleManifest | Select-String -Pattern "ProjectUri\s*= '(.*)'").Matches.Groups[1].Value
                    License      = ($moduleManifest | Select-String -Pattern "LicenseUri\s*= '(.*)'").Matches.Groups[1].Value
                    ReleaseNotes = ($moduleManifest | Select-String -Pattern "ReleaseNotes\s*= '(.*)'").Matches.Groups[1].Value
                }
            }

            'Emby' {
                if ($EmbyUrl) {
                    $Settings | Set-JVEmbyThumbs -ReplaceAll:$ReplaceAll -Url $EmbyUrl -ApiKey $EmbyApiKey
                } else {
                    $Settings | Set-JVEmbyThumbs -ReplaceAll:$ReplaceAll
                }
            }

            'Nfo' {
                Write-Warning "Feature is currently in progress. Check back in a future release."
                <# $nfoParams = @{
                    Path              = $Path
                    Recurse           = $Recurse
                    Depth             = $Depth
                    GenreCsv          = $Settings.'sort.metadata.genrecsv'
                    GenreCsvPath      = $genreCsvPath
                    GenreIgnore       = $Settings.'sort.metadata.genre.ignore'
                    FirstNameOrder    = $Settings.'sort.metadata.nfo.firstnameorder'
                    ThumbCsv          = $Settings.'sort.metadata.thumbcsv'
                    ThumbCsvAlias     = $Settings.'sort.metadata.thumbcsv.convertalias'
                    ThumbCsvPath      = $thumbCsvPath
                    ActressLanguageJa = $Settings.'sort.metadata.nfo.actresslanguageja'
                }

                Update-JVNfo @nfoParams #>
            }

            'Javlibrary' {
                try {
                    if (!($Path)) {
                        $Path = $Settings.'location.input'
                        if ($null -eq $Path -or $Path -eq '') {
                            $Path = (Get-Location).Path
                        }
                    }

                    $javlibraryBaseUrl = $Settings.'javlibrary.baseurl'
                    $request = Invoke-WebRequest -Uri "$javlibraryBaseUrl/en/mv_owned_print.php" -WebSession $CfSession -UserAgent $CfSession.UserAgent -Verbose:$false -Headers @{
                        "method"                    = "GET"
                        "authority"                 = "$javlibraryBaseUrl"
                        "scheme"                    = "https"
                        "path"                      = "/en/mv_owned_print.php"
                        "upgrade-insecure-requests" = "1"
                        "accept"                    = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
                        "sec-fetch-site"            = "none"
                        "sec-fetch-mode"            = "navigate"
                        "sec-fetch-user"            = "?1"
                        "sec-fetch-dest"            = "document"
                        "accept-encoding"           = "gzip, deflate, br"
                        "accept-language"           = "en-US,en;q=0.9"
                        "cookie"                    = "timezone=420; over18=18; userid=$($Settings.'javlibrary.cookie.userid'); session=$($Settings.'javlibrary.cookie.session')"
                    }

                    $ownedMovies = ($request.content -split '<td class="title">' | ForEach-Object { (($_ -split '<\/td>')[0] -split ' ')[0] })
                    $ownedMovies = $ownedMovies[2..($ownedMovies.Length - 1)]
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when retrieving owned movies from [$javlibraryBaseUrl/en/mv_owned_print.php]"
                }

                if ($null -ne $ownedMovies) {
                    if ($ownedMovies -gt 1) {
                        if ($ownedMovies[0].Length -le 1) {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when authenticating to JAVLibrary, check that your userid and session cookies are valid"
                        }
                    }
                }

                try {
                    $javMovies = $Settings | Get-JVItem -Path $Path -MinimumFileSize $Settings.'match.minimumfilesize' -RegexEnabled:$Settings.'match.regex' -RegexString $Settings.'match.regex.string' -RegexIdMatch $Settings.'match.regex.idmatch' -RegexPtMatch $Settings.'match.regex.ptmatch' -Recurse:$Recurse -Depth:$Depth -Strict:$Strict | Select-Object Id -Unique
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when getting existing movies from path [$Path]: $PSItem"
                    return
                }

                $unowned = @()
                foreach ($movie in $javMovies) {
                    if (!($ownedMovies -match $movie.Id)) {
                        $unowned += $movie.Id
                    }
                }

                if ($unowned.Count -ge 1) {
                    $index = 1
                    foreach ($movieId in $unowned) {
                        Write-Progress -Id 1 -Activity "Javinizer" -Status "Remaining Jobs: $($unowned.Count-$index)" -PercentComplete ($index / $unowned.Count * 100) -CurrentOperation "Setting owned: $movieId"
                        Set-JavlibraryOwned -Id $movieId -UserId $Settings.'javlibrary.cookie.userid' -LoginSession $Settings.'javlibrary.cookie.session' -Session:$CfSession -BaseUrl $javlibraryBaseUrl
                        $index++
                    }
                } else {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] [$Path] Exiting -- no unowned movies detected"
                }
            }

            'Thumbs' {
                if ($Pages) {
                    Update-JVThumbCsv -ThumbCsvPath $thumbCsvPath -StartPage $Pages[0] -EndPage $Pages[1]
                } else {
                    Update-JVThumbCsv -ThumbCsvPath $thumbCsvPath
                }
            }

            'Path' {
                if (!($Path)) {
                    try {
                        # Default path to location.input in settings if not specified
                        $Path = $Settings.'location.input'
                    } catch {
                        # Default path to the current directory if settings not specified
                        $Path = (Get-Location).Path
                    }
                }

                # This will check that the Path is valid
                if (!(Test-Path -LiteralPath $Path)) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Path [$Path] is not a valid path"
                }

                if (!($DestinationPath)) {
                    try {
                        # Default destination path to location.output in settings if not specified
                        $DestinationPath = $Settings.'location.output'
                    } catch {
                        # Default destination path to the current directory if settings not specified
                        $DestinationPath = (Get-Item -LiteralPath $Path).Directory
                    }
                }

                try {
                    $javMovies = $Settings | Get-JVItem -Path $Path -MinimumFileSize $Settings.'match.minimumfilesize' -RegexEnabled:$Settings.'match.regex' -RegexString $Settings.'match.regex.string' -RegexIdMatch $Settings.'match.regex.idmatch' -RegexPtMatch $Settings.'match.regex.ptmatch' -Recurse:$Recurse -Depth:$Depth -Strict:$Strict
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when getting local movies in [$Path]: $PSItem"
                    return
                }

                if ($null -eq $javMovies) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] [$Path] Exiting -- no valid movies detected"
                    return
                }

                if ($Url) {
                    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] [$Path] Exiting -- not a valid single file path"
                        return
                    }

                    if ($Settings.'sort.metadata.nfo.mediainfo') {
                        $mediaInfo = Get-JVMediaInfo -Path $movie.FullName
                    }

                    $javData = Get-JVData -Url $Url -Settings $Settings -UncensorCsvPath $uncensorCsvPath -Session:$CfSession
                    if ($null -ne $javData) {
                        $javAggregatedData = $javData | Get-JVAggregatedData -Settings $Settings -MediaInfo $mediaInfo | Test-JVData -RequiredFields $Settings.'sort.metadata.requiredfield'
                        if ($javAggregatedData.NullFields -eq '') {
                            $javAggregatedData | Set-JVMovie -Path $javMovies.FullName -DestinationPath $DestinationPath -Settings $Settings -PartNumber $JavMovies.PartNumber -Force:$Force
                        } else {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($javMovies.FullName)] Skipped -- missing required fields [$($javAggregatedData.NullFields)]"
                            return
                        }
                    }
                } else {
                    if ($Settings.'throttlelimit' -lt 1 -or $Settings.'throttlelimit' -gt 10) {
                        Write-JVLog -Write $script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Setting 'scraper.throttlelimit' must be within accepted values (1-5)"
                    }

                    if (!($PSboundParameters.ContainsKey('IsThread'))) {
                        $jvModulePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'Javinizer.psm1'
                        if ($PSBoundParameters.ContainsKey('IsWeb')) {
                            if ($IsWebType -eq 'Search') {
                                $javMovies | Invoke-JVParallel -IsWeb -IsWebType 'search' -MaxQueue $Settings.'throttlelimit' -Throttle $Settings.'throttlelimit' -Quiet:$true -ScriptBlock {
                                    Import-Module $using:jvModulePath
                                    $jvMovie = $_
                                    $Settings = $using:Settings
                                    $jvData = Javinizer -IsThread -IsWeb -IsWebType $using:IsWebType -Path $jvMovie.FullName -DestinationPath $using:DestinationPath -Set $using:Set -MoveToFolder:$Settings.'sort.movetofolder' -RenameFile:$Settings.'sort.renamefile' -CfSession:$using:CfSession -Update:$using:Update -SettingsPath:$using:SettingsPath -Strict:$using:Strict -Force:$using:Force -Verbose:$using:VerbosePreference -Debug:$using:DebugPreference
                                    Write-Output $jvData
                                }
                            } else {
                                $javMovies | Invoke-JVParallel -IsWeb -IsWebType 'sort' -MaxQueue $Settings.'throttlelimit' -Throttle $Settings.'throttlelimit' -Quiet:$true -ScriptBlock {
                                    Import-Module $using:jvModulePath
                                    $jvMovie = $_
                                    $Settings = $using:Settings
                                    Javinizer -IsThread -IsWeb -IsWebType $using:IsWebType -Path $jvMovie.FullName -DestinationPath $using:DestinationPath -Set $using:Set -MoveToFolder:$Settings.'sort.movetofolder' -RenameFile:$Settings.'sort.renamefile' -CfSession:$using:CfSession -Update:$using:Update -SettingsPath:$using:SettingsPath -Strict:$using:Strict -Force:$using:Force -Verbose:$using:VerbosePreference -Debug:$using:DebugPreference
                                }
                            }

                        } else {
                            $javMovies | Invoke-JVParallel -MaxQueue $Settings.'throttlelimit' -Throttle $Settings.'throttlelimit' -Quiet:$HideProgress -ScriptBlock {
                                Import-Module $using:jvModulePath
                                $jvMovie = $_
                                $Settings = $using:Settings
                                Javinizer -IsThread -Path $jvMovie.FullName -DestinationPath $using:DestinationPath -Set $using:Set -MoveToFolder:$Settings.'sort.movetofolder' -RenameFile:$Settings.'sort.renamefile' -CfSession:$using:CfSession -Update:$using:Update -SettingsPath:$using:SettingsPath -Strict:$using:Strict -Force:$using:Force -Verbose:$using:VerbosePreference -Debug:$using:DebugPreference
                            }
                        }
                    }

                    if ($PSboundParameters.ContainsKey('IsThread')) {
                        foreach ($movie in $javMovies) {
                            if ($Settings.'sort.metadata.nfo.mediainfo') {
                                $mediaInfo = Get-JVMediaInfo -Path $movie.FullName
                            }

                            $javData = Get-JVData -Id $movie.Id -Settings $Settings -UncensorCsvPath $uncensorCsvPath -Strict:$Strict -Session:$CfSession
                            if ($PSBoundParameters.ContainsKey('IsWeb')) {
                                $javAggregatedData = $javData | Get-JVAggregatedData -Settings $Settings -MediaInfo $mediaInfo | Test-JVData -RequiredFields $Settings.'sort.metadata.requiredfield'
                                if ($IsWebType -eq 'Search') {
                                    [PSCustomObject]@{
                                        Path       = $movie.FullName
                                        Data       = $javAggregatedData.Data
                                        PartNumber = $movie.PartNumber
                                    }
                                } elseif ($IsWebType -eq 'Sort') {
                                    $sortData = Get-JVSortData -Data $javAggregatedData.Data -Path $movie.FullName -DestinationPath $DestinationPath -Settings $Settings -Update:$Update -Force:$Force -PartNumber $movie.PartNumber
                                    $javAggregatedData | Set-JVMovie -Path $movie.FullName -DestinationPath $DestinationPath -Settings $Settings -PartNumber $movie.PartNumber -Update:$Update -Force:$Force
                                    if (!($Update)) {
                                        Write-JVWebLog -HistoryPath $historyCsvPath -OriginalPath $movie.FullName -DestinationPath $sortData.Path.FilePath -Data $sortData.Data
                                    }
                                }
                            } else {
                                if ($null -ne $javData) {
                                    $javAggregatedData = $javData | Get-JVAggregatedData -Settings $Settings -MediaInfo $mediaInfo | Test-JVData -RequiredFields $Settings.'sort.metadata.requiredfield'
                                    if ($javAggregatedData.NullFields -eq '') {
                                        $javAggregatedData | Set-JVMovie -Path $movie.FullName -DestinationPath $DestinationPath -Settings $Settings -PartNumber $movie.Partnumber -Update:$Update -Force:$Force
                                    } else {
                                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($movie.FileName)] Skipped -- missing required fields [$($javAggregatedData.NullFields)]"
                                        return
                                    }
                                } else {
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($movie.FileName)] Skipped -- not matched"
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
