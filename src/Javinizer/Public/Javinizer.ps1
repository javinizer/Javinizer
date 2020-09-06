#Requires -PSEdition Core

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
        Specifies to search R18 when using -Find.

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

    .PARAMETER Jav321
        Specifies to search Jav321 when using -Find.

    .PARAMETER SetEmbyThumbs
        Specifies to set Emby/Jellyfin actress thumbnails using the thumbnail csv. If 'location.thumbcsv' is not specified in the settings file,
        it defaults to the jvGenres.csv file in the module root. 'emby.url' and 'emby.apikey' need to be defined in the settings file.

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

    .PARAMETER UpdateThumbs
        Specifies to update the actress thumbnails file.

    .PARAMETER Pages
        Specifies an array as a range of pages to search for and update the actress thumbnails file.

    .PARAMETER Set
        Specifies a hashtable to update specific settings on the command-line.

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
    Javinizer -Path 'C:\JAV\Sorted' -DestinationPath 'C:\JAV\Sorted' -RenameFile:$false -MoveToFolder:$false

    Description
    -----------
    Sorts a path of JAV files to its own directory without renaming or moving any files. This is useful for updating already existing directories.

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
    Updates existing sorted nfo files from a path with updated aliases, thumburls, and names according to the settings.

    .EXAMPLE
    Javinizer -OpenSettings

    Description
    -----------
    Opens the settings file.

    #>

    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (

        [Parameter(ParameterSetName = 'Path', Position = 0)]
        [Parameter(ParameterSetName = 'Nfo', Mandatory = $true, Position = 0)]
        [System.IO.DirectoryInfo]$Path,

        [Parameter(ParameterSetName = 'Path', Position = 1)]
        [System.IO.DirectoryInfo]$DestinationPath,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'Nfo')]
        [Switch]$Recurse,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetName = 'Nfo')]
        [Int]$Depth,

        [Parameter(ParameterSetName = 'Path')]
        [Array]$Url,

        [Parameter(ParameterSetName = 'Path')]
        [System.IO.FileInfo]$SettingsPath,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Strict,

        [Parameter(ParameterSetName = 'Path')]
        [Boolean]$MoveToFolder,

        [Parameter(ParameterSetName = 'Path')]
        [Boolean]$RenameFile,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Force,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$HideProgress,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$IsThread,

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

        [Parameter(ParameterSetName = 'Settings')]
        [Switch]$OpenGenres,

        [Parameter(ParameterSetName = 'Nfo', Mandatory = $true)]
        [Switch]$UpdateNfo,

        [Parameter(ParameterSetName = 'Thumbs', Mandatory = $true)]
        [Switch]$UpdateThumbs,

        [Parameter(ParameterSetName = 'Thumbs')]
        [Array]$Pages,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetNAme = 'Info')]
        [Parameter(ParameterSetName = 'Settings')]
        [Parameter(ParameterSetName = 'Emby')]
        [Parameter(ParameterSetName = 'Thumbs')]
        [Hashtable]$Set,

        [Parameter(ParameterSetName = 'Version', Mandatory = $true)]
        [Alias('v')]
        [Switch]$Version,

        [Parameter(ParameterSetName = 'Help', Mandatory = $true)]
        [Alias('h')]
        [Switch]$Help
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

        if ($Settings.'location.thumbcsv' -eq '') {
            $thumbCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'
        } else {
            if (!(Test-Path -LiteralPath $Settings.'location.thumbcsv' -PathType Leaf)) {
                New-Item -Path $Settings.'location.thumbcsv' | Out-Null
            }
            $thumbCsvPath = $Settings.'location.thumbcsv'
        }

        if ($Settings.'location.genrecsv' -eq '') {
            $genreCsvPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvGenres.csv'
        } else {
            if (!(Test-Path -LiteralPath $Settings.'location.genrecsv' -PathType Leaf)) {
                New-Item -Path $Settings.'location.genrecsv' | Out-Null
            }
            $genreCsvPath = $Settings.'location.genrecsv'
        }

        if ($PSBoundParameters.ContainsKey('MoveToFolder')) {
            if ($MoveToFolder -eq $true) {
                $Settings.'sort.movetofolder' = 1
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - sort.movetofolder] replaced as [1]"
            } elseif ($MoveToFolder -eq $false) {
                $Settings.'sort.movetofolder' = 0
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - sort.movetofolder] replaced as [1]"
            }
        }

        if ($PSBoundParameters.ContainsKey('RenameFile')) {
            if ($RenameFile -eq $true) {
                $Settings.'sort.renamefile' = 1
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - sort.renamefile] replaced as [1]"
            } elseif ($RenameFile -eq $false) {
                $Settings.'sort.renamefile' = 0
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - sort.renamefile] replaced as [0]"
            }
        }

        if ($Set) {
            try {
                foreach ($item in $Set.GetEnumerator()) {
                    $settingName = $item.Key
                    $settingValue = $item.Value
                    $Settings."$($item.Key)" = $item.Value
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - $($item.Key)] replaced as [$($item.Value)]"
                }
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when defining settings using -Set: $PSItem"
            }
        }

        # Validate the values in the settings file following all command-line transformations
        $Settings = $Settings | Test-JVSettings

        switch ($PsCmdlet.ParameterSetName) {
            'Info' {
                if ($Find -match 'https?:\/\/') {
                    $urlObject = Get-JVUrlLocation -Url $Find
                    $data = foreach ($item in $urlObject) {
                        if ($item.Source -match 'dmm') {
                            $item.Url | Get-DmmData
                        }

                        if ($item.Source -match 'jav321') {
                            $item.Url | Get-Jav321Data
                        }

                        if ($item.Source -match 'javbus') {
                            $item.Url | Get-JavbusData
                        }

                        if ($item.Source -match 'javlibrary') {
                            $item.Url | Get-JavlibraryData
                        }

                        if ($item.Source -match 'r18') {
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
                    $nfoData = $data.Data | Get-JVNfo -ActressLanguageJa:$Settings.'sort.metadata.nfo.actresslanguageja' -NameOrder:$Settings.'sort.metadata.nfo.firstnameorder' -AddTag:$Settings.'sort.metadata.nfo.seriesastag'
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
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening thumbcsv file [$]: $PSItem"
                    }
                }

                if ($OpenGenres) {
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] [GenreCsvPath - $genreCsvPath]"
                        Invoke-Item -LiteralPath $genreCsvPath
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening thumbcsv file [$]: $PSItem"
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
                $Settings | Set-JVEmbyThumbs -ReplaceAll:$ReplaceAll
            }

            'Nfo' {
                $nfoParams = @{
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

                Update-JVNfo @nfoParams
            }

            'Thumbs' {
                if ($Pages) {
                    Update-JVThumbCsv -ThumbCsvPath $thumbCsvPath -StartPage $Pages[0] -EndPage $Pages[1]
                } else {
                    Update-JVThumbCsv -ThumbCsvPath $thumbCsvPath
                }
            }

            'Path' {
                # Default path to location.input in settings if not specified
                if (!($Path)) {
                    $Path = $Settings.'location.input'
                }

                # This will check that the Path is valid
                if (!(Test-Path -LiteralPath $Path)) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Path [$Path] is not a valid path"
                }

                # Default destination path to location.output in settings if not specified
                if (!($DestinationPath)) {
                    $DestinationPath = $Settings.'location.output'
                }

                # This will check that the DestinationPath is a valid directory
                if (Test-Path -LiteralPath $DestinationPath -PathType Leaf) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] DestinationPath [$DestinationPath] is not a valid directory path"
                }

                try {
                    $javMovies = $Settings | Get-JVItem -Path $Path -MinimumFileSize $Settings.'match.minimumfilesize' -RegexEnabled:$Settings.'match.regex' -RegexString $Settings.'match.regex.string' -RegexIdMatch $Settings.'match.regex.idmatch' -RegexPtMatch $Settings.'match.regex.ptmatch' -Recurse:$Recurse -Depth:$Depth -Strict:$Strict
                    # Write-Host "[$($MyInvocation.MyCommand.Name)] [Path - $Path] [DestinationPath - $DestinationPath] [Files - $($javMovies.Count)]"
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when getting local movies in [$Path]: $PSItem"
                    return
                }

                if ($null -eq $javMovies) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "Exiting -- no valid movies detected in [$Path]"
                    return
                }

                if ($Url) {
                    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "Exited [$Path] is not a valid single file path"
                        return
                    }

                    $javData = Get-JVData -Url $Url -Settings $Settings
                    if ($null -ne $javData) {
                        $javAggregatedData = $javData | Get-JVAggregatedData -Settings $Settings | Test-JVData -RequiredFields $Settings.'sort.metadata.requiredfield'
                        if ($null -ne $javAggregatedData) {
                            $javAggregatedData | Set-JVMovie -Path $javMovies.FullName -DestinationPath $DestinationPath -Settings $Settings -PartNumber $JavMovies.PartNumber -Force:$Force
                        }
                    }
                } else {
                    if ($Settings.'throttlelimit' -lt 1 -or $Settings.'throttlelimit' -gt 10) {
                        Write-JVLog -Write $script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Setting 'scraper.throttlelimit' must be within accepted values (1-5)"
                    }

                    if (!($PSboundParameters.ContainsKey('IsThread'))) {
                        $jvModulePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'Javinizer.psm1'
                        $javMovies | Invoke-Parallel -MaxQueue $Settings.'throttlelimit' -Throttle $Settings.'throttlelimit' -Quiet:$HideProgress -ScriptBlock {
                            Import-Module $using:jvModulePath
                            $jvMovie = $_
                            $Settings = $using:Settings
                            Javinizer -IsThread -Path $jvMovie.FullName -DestinationPath $using:DestinationPath -Set $using:Set -MoveToFolder:$Settings.'sort.movetofolder' -RenameFile:$Settings.'sort.renamefile' -SettingsPath:$using:SettingsPath -Strict:$using:Strict -Force:$using:Force -Verbose:$using:VerbosePreference -Debug:$using:DebugPreference
                        }
                    }

                    if ($PSboundParameters.ContainsKey('IsThread')) {
                        foreach ($movie in $javMovies) {
                            $javData = Get-JVData -Id $movie.Id -Settings $Settings
                            if ($null -ne $javData) {
                                $javAggregatedData = $javData | Get-JVAggregatedData -Settings $Settings | Test-JVData -RequiredFields $Settings.'sort.metadata.requiredfield'
                                if ($javAggregatedData.NullFields -eq '') {
                                    $javAggregatedData | Set-JVMovie -Path $movie.FullName -DestinationPath $DestinationPath -Settings $Settings -PartNumber $movie.Partnumber -Force:$Force
                                } else {
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "Skipped [$($movie.FileName)] missing required fields [$($javAggregatedData.NullFields)]"
                                    return
                                }
                            } else {
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "Skipped [$($movie.FileName)] not matched"
                            }
                        }
                    }
                }
            }
        }
    }
}
