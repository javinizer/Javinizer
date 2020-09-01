#Requires -Modules @{ ModuleName="Logging"; RequiredVersion="4.4.0" }
#Requires -PSEdition Core

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
    #>



    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Path', Position = 0)]
        [System.IO.DirectoryInfo]$Path,

        [Parameter(ParameterSetName = 'Path', Position = 1)]
        [System.IO.DirectoryInfo]$DestinationPath,

        [Parameter(ParameterSetName = 'Path')]
        [Switch]$Recurse,

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

        [Parameter(Mandatory = $true, ParameterSetName = 'Thumbs')]
        [Switch]$UpdateThumbs,

        [Parameter(ParameterSetName = 'Thumbs')]
        [Array]$Pages,

        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ParameterSetNAme = 'Info')]
        [Parameter(ParameterSetName = 'Settings')]
        [Parameter(ParameterSetName = 'Emby')]
        [Parameter(ParameterSetName = 'Thumbs')]
        [Hashtable]$Set,

        [Parameter(Mandatory = $true, ParameterSetName = 'Version')]
        [Alias('v')]
        [Switch]$Version,

        [Parameter(Mandatory = $true, ParameterSetName = 'Help')]
        [Alias('h')]
        [Switch]$Help
    )

    process {
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
                $logPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvLog.log'
            } else {
                if (!(Test-Path -LiteralPath $Settings.'location.log' -PathType Leaf)) {
                    New-Item -Path $Settings.'location.log' | Out-Null
                }
                $logPath = $Settings.'location.log'
            }
            Add-LoggingTarget -Name File -Configuration @{
                Path     = $logPath
                Append   = $true
                Encoding = 'utf8'
                Level    = $Settings.'admin.log.level'
                Format   = '[%{timestamp}] [%{level:-7}] %{message}'
            }
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
                Write-JVLog -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - sort.movetofolder] replaced as [1]"
            } elseif ($MoveToFolder -eq $false) {
                $Settings.'sort.movetofolder' = 0
                Write-JVLog -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - sort.movetofolder] replaced as [1]"
            }
        }

        if ($PSBoundParameters.ContainsKey('RenameFile')) {
            if ($RenameFile -eq $true) {
                $Settings.'sort.renamefile' = 1
                Write-JVLog -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - sort.renamefile] replaced as [1]"
            } elseif ($RenameFile -eq $false) {
                $Settings.'sort.renamefile' = 0
                Write-JVLog -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - sort.renamefile] replaced as [0]"
            }
        }

        if ($Set) {
            foreach ($item in $Set.GetEnumerator()) {
                $settingName = $item.Key
                $settingValue = $item.Value
                $Settings."$($item.Key)" = $item.Value
                Write-JVLog -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Setting - $($item.Key)] replaced as [$($item.Value)]"
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
                        Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening settings file [$SettingsPath]: $PSItem"
                    }
                }

                if ($OpenLog) {
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] [LogPath - $logPath]"
                        Invoke-Item -LiteralPath $logPath
                    } catch {
                        Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening log file [$logPath]: $PSItem"
                    }
                }

                if ($OpenThumbs) {
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] [ThumbCsvPath - $thumbCsvPath]"
                        Invoke-Item -LiteralPath $thumbCsvPath
                    } catch {
                        Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening thumbcsv file [$]: $PSItem"
                    }
                }

                if ($OpenGenres) {
                    try {
                        Write-Host "[$($MyInvocation.MyCommand.Name)] [GenreCsvPath - $genreCsvPath]"
                        Invoke-Item -LiteralPath $genreCsvPath
                    } catch {
                        Write-JVLog -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Error occurred when opening thumbcsv file [$]: $PSItem"
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
                    return
                }

                if ($Url) {
                    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) {
                        Write-JVLog -Level Warning -Message "Exiting -- [$Path] is not a valid single file path"
                        return
                    }

                    $javData = Get-JVData  -Url $Url -Settings $Settings
                    if ($null -ne $javData) {
                        $javAggregatedData = $javData | Get-JVAggregatedData -Settings $Settings | test-JVData -RequiredFields $Settings.'sort.metadata.requiredfield'
                        if ($null -ne $javAggregatedData) {
                            $javAggregatedData | Set-JVMovie -Path $javMovies.FullName -DestinationPath $DestinationPath -Settings $Settings -PartNumber $JavMovies.PartNumber -Force:$Force
                        }
                    }
                } else {
                    $index = 1
                    foreach ($movie in $javMovies) {
                        Write-Host "[$index of $($javMovies.Count)] Sorting [$($movie.FileName)] as [$($movie.Id)]"
                        $index++
                        $javData = Get-JVData  -Id $movie.Id -Settings $Settings
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
