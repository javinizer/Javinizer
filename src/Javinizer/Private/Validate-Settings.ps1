function Test-Settings {
    [CmdletBinding()]
    param (
        [string]$Path
    )

    $boolSettings = @(
        'scrape-r18',
        'scrape-r18zh',
        'scrape-dmm',
        'scrape-javlibrary',
        'scrape-javlibraryja',
        'scrape-javlibraryzh',
        'scrape-javbus',
        'scrape-javbusja',
        'scrape-jav321',
        'scrape-actress-en',
        'scrape-actress-ja',
        'move-to-folder',
        'rename-file',
        'regex-match',
        'create-nfo',
        'create-nfo-per-file',
        'download-thumb-img',
        'download-poster-img',
        'download-trailer-vid',
        'download-actress-img',
        'translate-description',
        'add-series-as-tag',
        'first-last-name-order',
        'convert-alias-to-originalname'
        'normalize-genres',
        'set-owned',
        'check-updates',
        'verbose-shell-output',
        'debug-shell-output'
    )

    $stringSettings = @(
        'rename-file-string',
        'rename-folder-string',
        'cms-displayname-string',
        'poster-file-string',
        'thumbnail-file-string',
        'trailer-file-string',
        'nfo-file-string',
        'screenshot-folder-string',
        'screenshot-img-string',
        'actor-folder-string'
    )

    $intSettings = @(
        'multi-sort-throttle-limit',
        'max-title-length',
        'max-path-length',
        'minimum-filesize-to-sort',
        'regex-id-match',
        'regex-pt-match',
        'request-timeout-sec'
    )

    $javlibrarySettings = @(
        'set-owned',
        'username',
        'session-cookie',
        'requeste-timeout-sec'
    )

    $validTags = @(
        'ID',
        'TITLE',
        'STUDIO',
        'YEAR',
        'RELEASEDATE',
        'RUNTIME',
        'ACTORS',
        'LABEL',
        'ORIGINALTITLE',
        'SET'
    )

    $errorObject = @()

    $settingObject = @()
    $settingsContent = Get-Content -LiteralPath $Path
    $settingsContent | ForEach-Object {
        if ($_ -match '^[a-zA-Z]') {
            $entry = [pscustomobject]@{
                Name  = ($_ -split '=')[0]
                Value = ($_ -split '=')[1]
            }

            $settingObject += $entry
        }
    }

    foreach ($setting in $settingObject) {
        if ($setting.Name -in $boolSettings) {
            if ($setting.Value -ne 'True' -and $setting.Value -ne 'False') {
                $entry = [PSCustomObject]@{
                    Name  = $setting.Name
                    Value = $setting.Value
                    Type  = 'Boolean'
                }
                $errorObject += $entry
            }
        }

        if ($setting.Name -in $intSettings) {
            if ($setting.Value -notmatch '^\d+$') {
                $entry = [PSCustomObject]@{
                    Name  = $setting.Name
                    Value = $setting.Value
                    Type  = 'Int'
                }
                $errorObject += $entry
            }
        }

        <#
        if ($setting.Name -in $stringSettings) {
            $tags = (($Setting.Value | Select-String '<(.*?)>' -AllMatches).Matches.Groups | Where-Object { $_.Name -eq 1 }).Value
            foreach ($tag in $tags) {
                if ($tag -notin $validTags) {
                    $entry = [PSCustomObject]@{
                        Name  = $setting.Name
                        Value = $setting.Value
                        Type  = 'String'
                    }
                    $errorObject += $entry
                }
            }
        }
        #>

        if ($setting.Name -eq 'multi-sort-throttle-limit') {
            if ([int]$setting.Value -lt 1 -or [int]$setting.Value -gt 15) {
                $entry = [PSCustomObject]@{
                    Name  = $setting.Name
                    Value = $setting.Value
                    Type  = 'Multi'
                }
                $errorObject += $entry
            }
        }
    }

    foreach ($err in $errorObject) {
        if ($err.Type -eq 'Boolean') {
            Write-Error "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error validating setting [$($err.Name)] with value [$($err.Value)], value must match [True / False]"
        }

        if ($err.Type -eq 'Int') {
            Write-Error "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error validating setting [$($err.Name)] with value [$($err.Value)], value must match an integer"
        }

        if ($err.Type -eq 'String') {
            Write-Error "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error validating setting [$($err.Name)] with value [$($err.Value)], value must match available tags"
        }

        if ($err.Type -eq 'Multi') {
            Write-Error "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error validating setting [$($err.Name)] with value [$($err.Value)], value must match [MIN: 1 / MAX: 15]"
        }
    }
}
