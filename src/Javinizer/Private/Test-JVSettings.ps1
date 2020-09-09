function Test-JVSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PSObject]$Settings
    )

    process {
        function Test-JVSettingsGroup {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [PSObject]$Settings,

                [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
                [Array]$SettingsGroup,

                [Parameter(Mandatory = $true, Position = 1)]
                [ValidateSet('Path', 'Boolean', 'Integer', 'String', 'Array')]
                [String]$Type
            )

            foreach ($setting in $SettingsGroup) {
                $settingValue = $Settings.($setting)

                if ($Type -eq 'Path') {
                    if ($settingValue -ne '') {
                        if (!(Test-Path -Path $settingValue)) {
                            Write-JVLog -Level Error -Message "Error occurred when validating setting [$setting] with value [$settingValue] as a path"
                        }
                    }
                }

                if ($Type -eq 'Boolean') {
                    if ($settingValue -ne 0 -and $settingValue -ne 1) {
                        Write-JVLog -Level Error -Message "Error occurred when validating setting [$setting] with value [$settingValue] as a boolean"
                    }
                }

                if ($Type -eq 'Integer') {
                    if ($settingValue.GetType().BaseType -ne 'System.ValueType' -and $settingValue.GetType().Name -notlike 'int*') {
                        Write-JVLog -Level Error -Message "Error occurred when validating setting [$setting] with value [$settingValue] as an integer"
                    }

                }

                if ($Type -eq 'String') {
                    if ($settingValue.GetType().BaseType -ne 'System.Object' -and $settingValue.GetType().Name -ne 'String') {
                        Write-JVLog -Level Error -Message "Error occurred when validating setting [$setting] with value [$settingValue] as a string"
                    }
                }

                if ($Type -eq 'Array') {
                    if ($settingValue.GetType().BaseType -notlike '*array*' -and $settingValue.GetType().BaseType -notlike '*object*') {
                        Write-JVLog -Level Error -Message "Error occurred when validating setting [$setting] with value [$settingValue] as an array"
                    }
                }
            }
        }

        $pathSettings = @(
            'location.genrecsv',
            'location.input',
            'location.log',
            'location.output',
            'location.thumbcsv'
        ) | Test-JVSettingsGroup -Settings $Settings -Type Path

        $booleanSettings = @(
            'admin.log',
            'javlibrary.request.interval',
            'javlibrary.request.timeout',
            'match.regex',
            'scraper.movie.dmm',
            'scraper.movie.jav321ja',
            'scraper.movie.javbus',
            'scraper.movie.javbusja',
            'scraper.movie.javbuszh',
            'scraper.movie.javlibrary',
            'scraper.movie.javlibraryja',
            'scraper.movie.javlibraryzh',
            'scraper.movie.r18',
            'scraper.movie.r18zh',
            'sort.create.nfo',
            'sort.create.nfoperfile',
            'sort.download.actressimg',
            'sort.download.posterimg',
            'sort.download.screenshotimg',
            'sort.download.thumbimg',
            'sort.download.trailervid',
            'sort.metadata.genrecsv',
            'sort.metadata.nfo.actresslanguageja',
            'sort.metadata.nfo.firstnameorder',
            'sort.metadata.nfo.seriesastag',
            'sort.metadata.nfo.translatedescription',
            'sort.metadata.thumbcsv.convertalias',
            'sort.metadata.thumbcsv.autoadd',
            'sort.metadata.thumbcsv',
            'sort.movetofolder',
            'sort.renamefile'
        ) | Test-JVSettingsGroup -Settings $Settings -Type Boolean

        $integerSettings = @(
            'match.minimumfilesize',
            'match.regex.idmatch',
            'match.regex.ptmatch',
            'sort.maxtitlelength',
            'throttlelimit'
        ) | Test-JVSettingsGroup -Settings $Settings -Type Integer

        $stringSettings = @(
            'admin.log.level',
            'emby.apikey',
            'emby.url',
            'javlibrary.baseurl',
            'javlibrary.sessioncookie',
            'javlibrary.username',
            'match.regex.string',
            'sort.format.actressimgfolder',
            'sort.format.file',
            'sort.format.folder',
            'sort.format.nfo',
            'sort.format.screenshotfolder',
            'sort.format.screenshotimg',
            'sort.format.thumbimg',
            'sort.format.trailervid',
            'sort.metadata.nfo.displayname',
            'sort.metadata.nfo.translatedescription.language'
        ) | Test-JVSettingsGroup -Settings $Settings -Type String

        $arraySettings = @(
            'match.excludedfilestring',
            'match.includedfileextension',
            'sort.format.posterimg',
            'sort.metadata.genre.ignore',
            'sort.metadata.priority.actress',
            'sort.metadata.priority.alternatetitle',
            'sort.metadata.priority.coverurl',
            'sort.metadata.priority.description',
            'sort.metadata.priority.director',
            'sort.metadata.priority.genre',
            'sort.metadata.priority.id',
            'sort.metadata.priority.label',
            'sort.metadata.priority.maker',
            'sort.metadata.priority.releasedate',
            'sort.metadata.priority.runtime',
            'sort.metadata.priority.screenshoturl',
            'sort.metadata.priority.series',
            'sort.metadata.priority.title',
            'sort.metadata.priority.trailerurl',
            'sort.metadata.requiredfield'
        ) | Test-JVSettingsGroup -Settings $Settings -Type Array

        Write-Output $Settings
    }
}
