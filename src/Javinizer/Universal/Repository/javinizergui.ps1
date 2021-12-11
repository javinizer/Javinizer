$cache:guiVersion = '2.5.10-1'

# Define Javinizer module file paths
$cache:modulePath = (Get-InstalledModule -Name Javinizer).InstalledLocation
$cache:fullModulePath = Join-Path -Path $cache:modulePath -ChildPath 'Javinizer.psm1'
$cache:defaultSettingsPath = Join-Path -Path $cache:modulePath -ChildPath 'jvSettings.json'
$cache:settingsPath = Join-Path -Path $cache:modulePath -ChildPath 'jvSettings.json'
$cache:defaultLogPath = Join-Path -Path $cache:modulePath -ChildPath 'jvLog.log'
$cache:defaultGenrePath = Join-Path -Path $cache:modulePath -ChildPath 'jvGenres.csv'
$cache:defaultTagPath = Join-Path -Path $cache:modulePath -ChildPath 'jvTags.csv'
$cache:defaultUncensorPath = Join-Path -Path $cache:modulePath -ChildPath 'jvUncensor.csv'
$cache:defaultHistoryPath = Join-Path -Path $cache:modulePath -ChildPath 'jvHistory.csv'
$cache:defaultThumbPath = Join-Path -Path $cache:modulePath -ChildPath 'jvThumbs.csv'

# Import Javinizer and Universal Dashboard dependencies
Import-Module UniversalDashboard.CodeEditor
Import-Module UniversalDashboard.Style
Import-Module UniversalDashboard.UDPlayer
Import-Module UniversalDashboard.UDScrollUp
Import-Module UniversalDashboard.UDSpinner
Import-Module UniversalDashboard.Charts
Import-Module $cache:fullModulePath

# Load Javinizer settings
$cache:javinizerInfo = Javinizer -Version
$cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
if (Test-Path -LiteralPath $cache:settings.'location.log') { $cache:logPath = $cache:settings.'location.log' } else { $cache:logPath = $cache:defaultLogPath }
if (Test-Path -LiteralPath $cache:settings.'location.historycsv') { $cache:historyCsvPath = $cache:settings.'location.historycsv' } else { $cache:historyCsvPath = $cache:defaultHistorypath }
if (Test-Path -LiteralPath $cache:settings.'location.thumbcsv') { $cache:thumbCsvPath = $cache:settings.'location.thumbcsv' } else { $cache:thumbCsvPath = $cache:defaultThumbPath }
if (Test-Path -LiteralPath $cache:settings.'location.genrecsv') { $cache:genreCsvPath = $cache:settings.'location.genrecsv' } else { $cache:genreCsvPath = $cache:defaultGenrePath }
if (Test-Path -LiteralPath $cache:settings.'location.tagcsv') { $cache:tagCsvPath = $cache:settings.'location.tagcsv' } else { $cache:tagCsvPath = $cache:defaultTagPath }
if (Test-Path -LiteralPath $cache:settings.'location.uncensorcsv') { $cache:uncensorCsvPath = $cache:settings.'location.uncensorcsv' } else { $cache:uncensorCsvPath = $cache:defaultUncensorPath }
$cache:actressArray = @()
$cache:actressObject = Import-Csv $cache:thumbCsvPath | Sort-Object FullName
$cache:actressArray += $cache:actressObject | ForEach-Object { "$($_.FullName) ($($_.JapaneseName)) [$actressIndex]"; $actressIndex++ }
$scraperSettings = @(
    'AVEntertainment',
    'AVEntertainmentJa',
    'Dmm',
    'DmmJa',
    'Jav321Ja',
    'Javdb',
    'JavdbZh',
    'Javbus',
    'JavbusJa',
    'JavbusZh',
    'Javlibrary',
    'JavlibraryJa',
    'JavlibraryZh',
    'MGStageJa',
    'R18',
    'R18Zh',
    'TokyoHot',
    'TokyoHotJa',
    'TokyoHotZh'
)

$prioritySettings = @(
    'Actress',
    'AlternateTitle',
    'CoverURL',
    'Description',
    'Director',
    'Genre',
    'ID',
    'ContentID',
    'Label',
    'Maker',
    'Rating',
    'ReleaseDate',
    'Runtime',
    'Series',
    'ScreenshotURL',
    'Title',
    'TrailerURL'
)

$locationSettings = @(
    'input',
    'output',
    'thumbcsv',
    'genrecsv',
    'uncensorcsv',
    'historycsv',
    'tagcsv',
    'log'
)

$embySettings = @(
    'emby.url',
    'emby.apikey'
)

$javlibrarySettings = @(
    'javlibrary.baseurl',
    'javlibrary.browser.useragent',
    "javlibrary.cookie.cf_chl_2",
    "javlibrary.cookie.cf_chl_prog",
    'javlibrary.cookie.cf_clearance',
    'javlibrary.cookie.session',
    'javlibrary.cookie.userid',
    'javdb.cookie.session'
)

$formatStringSettings = @(
    'sort.format.delimiter',
    'sort.format.file',
    'sort.format.folder',
    'sort.format.outputfolder',
    'sort.format.posterimg',
    'sort.format.thumbimg',
    'sort.format.trailervid',
    'sort.format.nfo',
    'sort.format.screenshotimg',
    'sort.format.screenshotfolder',
    'sort.format.actressimgfolder',
    'sort.metadata.nfo.displayname',
    'sort.metadata.nfo.format.tag',
    'sort.metadata.nfo.format.tagline',
    'sort.metadata.nfo.format.credits'
)

$sortSettings = @(
    'sort.movetofolder',
    'sort.renamefile',
    'sort.movesubtitles',
    'sort.create.nfo',
    'sort.create.nfoperfile',
    'sort.download.actressimg',
    'sort.download.thumbimg',
    'sort.download.posterimg',
    'sort.download.screenshotimg',
    'sort.download.trailervid',
    'sort.format.groupactress',
    'sort.metadata.nfo.mediainfo',
    'sort.metadata.nfo.altnamerole',
    'sort.metadata.nfo.addgenericrole',
    'sort.metadata.nfo.firstnameorder',
    'sort.metadata.nfo.actresslanguageja',
    'sort.metadata.nfo.unknownactress',
    'sort.metadata.nfo.actressastag',
    'sort.metadata.nfo.preferactressalias',
    'sort.metadata.nfo.originalpath',
    'sort.metadata.thumbcsv',
    'sort.metadata.thumbcsv.autoadd',
    'sort.metadata.thumbcsv.convertalias',
    'sort.metadata.genrecsv',
    'sort.metadata.genrecsv.autoadd',
    'sort.metadata.tagcsv',
    'sort.metadata.tagcsv.autoadd'
)

$translateLanguages = @(
    'am',
    'ar',
    'bg',
    'bn',
    'ca',
    'chr',
    'cs',
    'cy'
    'da',
    'de',
    'el',
    'en-GB',
    'en',
    'es',
    'et',
    'eu',
    'fi',
    'fil',
    'fr',
    'gu',
    'hi',
    'hr',
    'hu',
    'id',
    'is',
    'it',
    'iw',
    'ja',
    'kn',
    'ko',
    'lt',
    'lv',
    'ml',
    'mr',
    'ms',
    'nl',
    'no',
    'pl',
    'pt-BR',
    'pt-PT',
    'ro',
    'ru',
    'sk',
    'sl',
    'sr',
    'sv',
    'sw',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh-CN',
    'zh-TW'
)

# Set other Javinizer dashboard defaults
$cache:findData = New-Object System.Collections.ArrayList
$cache:originalFindData = New-Object System.Collections.ArrayList
$cache:filePath = ''
$cache:index = 0
$cache:currentIndex = 0
$actressIndex = 0
$cache:tablePageSize = 5
$cache:inProgress = $false
$cache:inProgressEmby = $false
$cache:chartDataCount = 15
$iconSearch = New-UDIcon -Icon 'search' -Size lg
$iconRightArrow = New-UDIcon -Icon 'arrow_right' -Size lg
$iconLeftArrow = New-UDIcon -Icon 'arrow_left' -Size lg
$iconLevelUp = New-UDIcon -Icon 'level_up_alt' -Size lg
$iconForward = New-UDIcon -Icon 'step_forward' -Size lg
$iconFastForward = New-UDIcon -Icon 'fast_forward' -Size lg
$iconCheck = New-UDIcon -Icon 'check' -Size lg
$iconTrash = New-UDIcon -Icon 'trash' -Size lg
$iconEdit = New-UDIcon -Icon 'edit' -Size lg
$iconPlay = New-UDIcon -Icon 'play' -Size sm
$iconUndo = New-UDIcon -Icon 'undo' -Size lg
$iconVideo = New-UDIcon -Icon 'video' -Size lg
$iconImage = New-UDIcon -Icon 'image' -Size lg
$iconExclamation = New-UDIcon -Icon 'exclamation_circle' -Style @{ color = 'red' }
$iconCog = New-UDIcon -Icon 'cog' -Size 2x
$iconTable = New-UDIcon -Icon 'table' -Size 2x
$iconGithub = New-UDIcon -Icon 'github' -Size 2x
$iconBook = New-UDIcon -Icon 'book' -Size 2x
$iconQuestion = New-UDIcon -Icon 'question' -Size 2x
$iconServer = New-UDIcon -Icon 'server' -Size 2x
$iconTerminal = New-UDIcon -Icon 'terminal' -Size 2x
$iconSearchLocation = New-UDIcon -Icon 'search_location' -Size 2x

# Set Universal Dashboard configs
$Pages = @()
$Theme = @{
    light = @{
        spacing = 3
        shape   = @{
            borderRadius = 5
        }
        palette = @{
            type       = 'light'

            background = @{
                default = '#E1E2E1'
                paper   = '#DBDBDC'

            }
            primary    = @{
                main = "#303F9F"
            }
            grey       = @{
                '300' = '#303F9F'
            }
        }
    }

    dark  = @{
        spacing = 3
        shape   = @{
            borderRadius = 5
        }
        palette = @{
            type       = 'dark'

            background = @{
                default = '#121212'
                paper   = '#333333'
            }
            primary    = @{
                main = '#303F9F'
            }
            grey       = @{
                '300' = '#303F9F'
            }
        }
    }
}

function Update-JVPage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Switch]$Sort,

        [Parameter()]
        [Switch]$Settings,

        [Parameter()]
        [Switch]$Emby,

        [Parameter()]
        [Switch]$EditorModal,

        [Parameter()]
        [Switch]$ClearData,

        [Parameter()]
        [Switch]$ClearProgress
    )
    if ($ClearData) {
        $cache:findData = New-Object System.Collections.ArrayList
        $cache:originalFindData = New-Object System.Collections.ArrayList
        $cache:index = 0
        $cache:currentIndex = 0
    }

    if ($ClearProgress) {
        $cache:totalCount = 0
        $cache:completedCount = 0
        $cache:currentSort = $null
        $cache:currentSortFullName = $null
    }

    if ($Sort) {
        if (($cache:findData).Count -eq 0) {
            $cache:findData = New-Object System.Collections.ArrayList
        }
        Sync-UDElement -Id 'dynamic-sort-aggregateddata'
        Sync-UDElement -Id 'dynamic-sort-coverimage'
        Sync-UDElement -Id 'dynamic-sort-movieselect'
    }

    if ($Settings) {
        Sync-UDElement -Id 'dynamic-settings-page'
    }

    if ($Emby) {
        Sync-UDElement -Id 'dynamic-emby-actortable'
    }

    if ($EditorModal) {
        Sync-UDElement -Id 'dynamic-sort-itemeditor'
        Sync-UDElement -Id 'dynamic-sort-favoriteseditor'
        Sync-UDElement -Id 'dynamic-sort-removededitor'
    }
}

function Show-JVProgressModal {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Switch]$Sort,

        [Parameter()]
        [Switch]$Generic,

        [Parameter()]
        [Switch]$Progress,

        [Parameter()]
        [String]$Message,

        [Parameter()]
        [Switch]$NoCancel,

        [Parameter()]
        [Switch]$Off
    )

    if ($Off) {
        $cache:inProgress = $false
        Hide-UDModal
    } else {
        $cache:inProgress = $true
        if ($cache:inProgress -eq $true) {
            if ($Sort) {
                Show-UDModal -Persistent -FullWidth -MaxWidth sm -Content {
                    New-UDDynamic -Content {
                        if (-not ($cache:completedCount) -and -not ($cache:totalCount)) {
                            $cache:completedCount = 0
                            $cache:totalCount = 0
                        }

                        if ($cache:totalCount -ne 0) {
                            $cache:percentComplete = ($cache:completedCount / $cache:totalCount * 100)
                        } else {
                            $cache:percentComplete = 0
                        }

                        New-UDStyle -Style '
                        .MuiLinearProgress-colorPrimary {
                            background-color: rgb(24, 31, 79);
                            height: 25px;
                        }' -Content {
                            New-UDProgress -PercentComplete $cache:percentComplete
                        }

                        New-UDTypography -Variant h3 -Text "$($cache:completedCount) of $($cache:totalCount)" -Align center
                        New-UDTypography -Variant h6 -Text "Not Matched: $((Get-Content $cache:tempFile).Count)" -Align center

                        New-UDCard -Content {
                            New-UDList -Content {
                                # $cache:currentSort is being pulled from the Invoke-JVParallel function
                                for ($x = 0; $x -lt $cache:currentSort.Count; $x++) {
                                    if ($cache:currentSort.Count -eq 1) {
                                        New-UDListItem -Label $cache:currentSort -SubTitle $cache:currentSortFullName
                                    } else {
                                        New-UDListItem -Label $cache:currentSort[$x] -SubTitle $cache:currentSortFullName[$x]
                                    }
                                }
                            }
                        }
                    } -AutoRefresh -AutoRefreshInterval 1
                } -Footer {
                    New-UDButton -Text 'Cancel' -FullWidth -OnClick {
                        # Clean up temp file if it was created
                        if (Test-Path -Path $cache:tempFile) {
                            Remove-Item -Path $cache:tempFile -ErrorAction SilentlyContinue
                        }

                        # The runspace that we want to close is created from Invoke-JVParallel
                        $cache:runspacepool.Close()
                        Show-JVProgressModal -Off

                        # Need to wait before reassigning findData after the runspace is closed otherwise it will stay as null
                        Start-Sleep -Seconds 1
                        Update-JVPage -Sort
                    }
                }
            }

            if ($Generic) {
                if ($Progress) {
                    if ($NoCancel) {
                        Show-UDModal -Persistent -Content {
                            New-UDDynamic -Content {
                                if ($cache:totalCount -eq 0) {
                                    $cache:percentComplete = 0
                                } else {
                                    $cache:percentComplete = ($cache:jobIndex / $cache:totalCount * 100)
                                }
                                New-UDStyle -Style '
                        .MuiLinearProgress-colorPrimary {
                            background-color: rgb(24, 31, 79);
                            height: 25px;
                        }' -Content {
                                    New-UDProgress -PercentComplete $cache:percentComplete
                                }
                                New-UDTypography -Variant 'body1' -Text $Message

                            } -AutoRefresh -AutoRefreshInterval 1
                        }
                    } else {
                        Show-UDModal -Persistent -Content {
                            New-UDDynamic -Content {
                                if ($cache:totalCount -eq 0) {
                                    $cache:percentComplete = 0
                                } else {
                                    $cache:percentComplete = ($cache:jobIndex / $cache:totalCount * 100)
                                }
                                New-UDStyle -Style '
                        .MuiLinearProgress-colorPrimary {
                            background-color: rgb(24, 31, 79);
                            height: 25px;
                        }' -Content {
                                    New-UDProgress -PercentComplete $cache:percentComplete
                                }
                                New-UDTypography -Variant 'body1' -Text $Message

                            } -AutoRefresh -AutoRefreshInterval 1
                        } -Footer {
                            New-UDButton -Text 'Cancel' -FullWidth -OnClick {
                                # The runspace that we want to close is created from Invoke-JVParallel
                                $cache:runspacepool.Close()
                                Show-JVProgressModal -Off
                            }
                        }
                    }
                } else {
                    if ($NoCancel) {
                        Show-UDModal -Persistent -Content {
                            New-UDSpinner -tagName 'ImpulseSpinner' -frontColor "#303f9f" -backColor "#383838"
                            #New-UDSpinner -tagName 'RotateSpinner' -color "#00cc00"
                        }
                    } else {
                        Show-UDModal -Persistent -Content {
                            New-UDSpinner -tagName 'ImpulseSpinner' -frontColor "#303f9f" -backColor "#383838"
                        } -Footer {
                            New-UDButton -Text 'Cancel' -FullWidth -OnClick {
                                # The runspace that we want to close is created from Invoke-JVParallel
                                $cache:runspacepool.Close()
                                Show-JVProgressModal -Off
                            }
                        }
                    }
                }
            }
        }
    }
}

function Show-JVEditorModal {
    param (
        [Array]$Data,

        [Array]$Favorites,

        [String]$Title,

        [ValidateSet('genre', 'tag')]
        [String]$Type
    )

    $cache:removedItems = New-Object System.Collections.ArrayList
    $cache:editorModalData = New-Object System.Collections.ArrayList
    $cache:favoriteItems = New-Object System.Collections.ArrayList

    $Data | ForEach-Object { $cache:editorModalData.Add($_) }
    $cache:settings."web.favorites.$Type" | ForEach-Object { $cache:favoriteItems.Add($_) }

    Show-UDModal -Persistent -FullWidth -MaxWidth md -Content {
        New-UDCard -Title $Title -Content {
            New-UDGrid -Container -Content {
                New-UDDynamic -Id 'dynamic-sort-itemeditor' -Content {
                    if ($cache:editorModalData -gt 0) {
                        foreach ($item in ($cache:editorModalData | Sort-Object)) {
                            $randomItemGuid = [Guid]::NewGuid()
                            New-UDChip -Id $randomItemGuid -Label $item -Variant default -OnClick {
                                if ($item -notin $cache:settings."web.favorites.$Type") {
                                    $cache:favoriteItems.Add($item)
                                    $cache:settings."web.favorites.$Type" = $cache:favoriteItems
                                    Update-JVSettings
                                    Update-JVPage -EditorModal
                                }
                            } -OnDelete {
                                $cache:editorModalData.Remove($item)
                                if ($item -notin $cache:removedItems) {
                                    $cache:removedItems.Add($item)
                                }
                                Update-JVPage -EditorModal
                            } -Style @{
                                'background-color' = '#303F9F'
                            }
                        }
                    }
                }
            }
        }
        New-UDCard -Title "Favorites (web.favorites.$Type)" -Content {
            New-UDGrid -Container -Content {
                New-UDDynamic -Id 'dynamic-sort-favoriteseditor' -Content {
                    if ($cache:favoriteItems -gt 0) {
                        foreach ($item in ($cache:favoriteItems | Sort-Object)) {
                            $randomItemGuid = [Guid]::NewGuid()
                            New-UDChip -Id $randomItemGuid -Label $item -Variant default -OnClick {
                                if ($cache:editorModalData -notcontains $item) {
                                    $cache:editorModalData.Add($item)
                                }

                                Update-JVSettings
                                Update-JVPage -EditorModal
                            } -OnDelete {
                                $cache:favoriteItems.Remove($item)
                                if ($cache:removedItems -notcontains $item) {
                                    $cache:removedItems.Add($item)
                                }
                                $cache:settings."web.favorites.$Type" = $cache:favoriteItems
                                Update-JVSettings
                                Update-JVPage -EditorModal
                            } -Style @{
                                'background-color' = '#303F9F'
                            }
                        }
                    }
                }
            }
        }
        New-UDCard -Title 'Removed' -Content {
            New-UDGrid -Container -Content {
                New-UDDynamic -Id 'dynamic-sort-removededitor' -Content {
                    foreach ($item in $cache:removedItems) {
                        $randomItemGuid = [Guid]::NewGuid()
                        New-UDChip -Id $randomItemGuid -Label $item -Variant default -OnClick {
                            if ($item -notin $cache:editorModalData) {
                                $cache:editorModalData.Add($item)
                            }

                            $cache:removedItems.Remove($item)
                            Update-JVPage -EditorModal
                        } -Style @{
                            'background-color' = 'grey'
                        }
                    }
                }
            }
        }
        New-UDGrid -Container -Content {
            New-UDTextbox 'textbox-sort-additem' -Label "Enter an item"
            New-UDButton -Text "Add $type" -OnClick {
                $addItemValue = (Get-UDElement -Id 'textbox-sort-additem').value
                if ($cache:editorModalData -notcontains $addItemValue) {
                    $cache:editorModalData.Add($addItemValue)
                }
                Set-UDElement -Id 'textbox-sort-additem' -Properties @{ value = '' }
                Update-JVPage -EditorModal
            }
            New-UDButton -Text 'Add favorite' -OnClick {
                $addItemValue = (Get-UDElement -Id 'textbox-sort-additem').value
                if ($cache:favoriteItems -notcontains $addItemValue) {
                    $cache:favoriteItems.Add($addItemValue)
                    $cache:settings."web.favorites.$Type" = $cache:favoriteItems
                    Update-JVSettings
                }
                Set-UDElement -Id 'textbox-sort-additem' -Properties @{ value = '' }
                Update-JVPage -EditorModal
            }
        }
    } -Footer {
        New-UDButton -Text 'Ok' -OnClick {
            switch ($Type) {
                'genre' { $cache:findData[$cache:index].Data.Genre = $cache:editorModalData }
                'tag' { $cache:findData[$cache:index].Data.Tag = $cache:editorModalData }
            }

            Update-JVPage -Sort
            Hide-UDModal
        }
        New-UDButton -Text 'Reset' -OnClick {
            $cache:editorModalData = New-Object System.Collections.ArrayList
            if ($type -eq 'genre') {
                $cache:originalFindData[$cache:index].Data.Genre | ForEach-Object { $cache:editorModalData.Add($_) }
            } elseif ($type -eq 'tag') {
                $cache:originalFindData[$cache:index].Data.Tag | ForEach-Object { $cache:editorModalData.Add($_) }
            }
            <# $cache:editorModalData = switch ($Type) {
                'genre' { $cache:originalFindData[$cache:index].Data.Genre | ForEach-Object { $cache:editorModalData.Add($_) | Out-Null } }
                'tag' { $cache:originalFindData[$cache:index].Data.Tag | ForEach-Object { $cache:editorModalData.Add($_) | Out-Null } }
            } #>
            Update-JVPage -EditorModal
        }
        New-UDButton -Text 'Cancel' -OnClick {
            Hide-UDModal
        }
    }
}

function Show-JVCfModal {
    [CmdletBinding()]
    param ()

    Show-UDModal -FullWidth -MaxWidth sm -Persistent -Content {
        New-UDTypography -Text 'Cloudflare anti-bot protection was detected on JAVLibrary. Manually access JAVLibrary and copy its site cookie values and your browser user-agent into this screen.
        See https://github.com/jvlflame/Javinizer/issues/169 for more detailed instructions. If you want to ignore this error, disable all JAVLibrary scrapers and re-sort.'

        New-UDButton -Text 'Navigate to javlibrary' -Variant text -OnClick {
            Invoke-UDRedirect -OpenInNewWindow -Url 'https://javlibrary.com/'
        }

        New-UDButton -Text 'View my user-agent' -Variant text -OnClick {
            Invoke-UDRedirect -OpenInNewWindow -Url 'https://www.whatismybrowser.com/detect/what-is-my-user-agent'
        }

        New-UDTextbox -Id 'textbox-javlibrary-cfchl2' -Label 'cf_chl_2' -FullWidth
        New-UDTextbox -Id 'textbox-javlibrary-cfchlprog' -Label 'cf_chl_prog' -FullWidth
        New-UDTextbox -Id 'textbox-javlibrary-cfclearance' -Label 'cf_clearance' -FullWidth
        New-UDTextbox -Id 'textbox-javlibrary-useragent' -Label 'user-agent' -FullWidth

    } -Header {
        New-UDTypography -Text 'Enter JAVLibrary Cloudflare Cookies'
    } -Footer {
        New-UDButton -Text 'Ok' -OnClick {

            try {
                $cf_chl_2 = (Get-UDElement -Id 'textbox-javlibrary-cfchl2').value
                $cf_chl_prog = (Get-UDElement -Id 'textbox-javlibrary-cfchlprog').value
                $cf_clearance = (Get-UDElement -Id 'textbox-javlibrary-cfclearance').value
                $UserAgent = (Get-UDElement -Id 'textbox-javlibrary-useragent').value
                $cache:cfSession = Get-CfSession -cf_chl_2 $cf_chl_2 -cf_chl_prog $cf_chl_prog -cf_clearance $cf_clearance -UserAgent $useragent -BaseUrl $cache:settings.'javlibrary.baseurl'
            } catch {
                Show-JVToast -Type Error -Message "$PSItem"
                Hide-UDModal
                return
            }

            try {
                Start-Sleep -Seconds 1
                Invoke-WebRequest -Uri $cache:Settings.'javlibrary.baseurl' -WebSession $cache:cfSession -UserAgent $cache:cfSession.UserAgent -Verbose:$false | Out-Null
                if ($cache:cfSession) {
                    $originalSettingsContent = Get-Content -Path $cache:SettingsPath
                    $settingsContent = $OriginalSettingsContent
                    $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cf_chl_2": ".*"', "`"javlibrary.cookie.cf_chl_2`": `"$cf_chl_2`""
                    $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cf_chl_prog": ".*"', "`"javlibrary.cookie.cf_chl_prog`": `"$cf_chl_prog`""
                    $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cf_clearance": ".*"', "`"javlibrary.cookie.cf_clearance`": `"$cf_clearance`""
                    $settingsContent = $settingsContent -replace '"javlibrary\.browser\.useragent": ".*"', "`"javlibrary.browser.useragent`": `"$userAgent`""

                    $settingsContent | Out-File -FilePath $cache:SettingsPath
                    Show-JVToast -Type Success -Message "Replaced Javlibrary settings with updated values in [$cache:SettingsPath]"

                }
            } catch {
                Show-JVToast -Type Error -Message "$PSItem"
            }
            Hide-UDModal
        }
        New-UDButton -Text 'Cancel' -OnClick {
            Hide-UDModal
        }
    }
}

function Show-JVToast {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('Info', 'Error', 'Success')]
        [String]$Type,

        [Parameter()]
        [String]$Message
    )

    switch ($Type) {
        'Info' {
            Show-UDToast -CloseOnClick -Message $Message -Title 'Info' -Duration 5000 -Position bottomCenter
        }

        'Error' {
            Show-UDToast -CloseOnClick -Message $Message -Title 'Error' -TitleColor red -Duration 5000 -Position bottomCenter
        }

        'Success' {
            Show-UDToast -CloseOnClick -Message $Message -Title 'Success' -TitleColor green -Duration 5000 -Position bottomCenter
        }
    }
}

function Update-JVSettings {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSObject]$Settings = $cache:settings,

        [Parameter()]
        [System.IO.FileInfo]$SettingsPath = $cache:settingsPath,

        [Parameter()]
        [Switch]$Force
    )

    try {
        $jsonSettings = $Settings | ConvertTo-Json
        $jsonSettings | Out-File -LiteralPath $SettingsPath -Force:$Force
    } catch {
        Show-JVToast -Type Error -Message "$PSItem"
    }
}

function Invoke-JavinizerWeb {
    [CmdletBinding()]
    param(
        [Parameter()]
        [PSObject]$Item,

        [Parameter()]
        [String]$Path,

        [Parameter()]
        [Switch]$Recurse = (Get-UDElement -Id 'checkbox-sort-recurse').checked,

        [Parameter()]
        [Int]$Depth = (Get-UDElement -Id 'select-sort-recursedepth').value,

        [Parameter()]
        [Switch]$Strict = (Get-UDElement -Id 'checkbox-sort-strict').checked,

        [Parameter()]
        [Switch]$Update = (Get-UDElement -Id 'checkbox-sort-update').checked,

        [Parameter()]
        [Switch]$Interactive = (Get-UDElement -Id 'checkbox-sort-interactive').checked,

        [Parameter()]
        [Switch]$Force = (Get-UDElement -Id 'checkbox-sort-force').checked

        <# [Parameter()]
        [Switch]$Preview = (Get-UDElement -Id 'checkbox-sort-preview').checked #>
    )

    process {
        if (!($cache:inProgress)) {
            # Check if javlibrary cloudflare protection is enabled
            if ($cache:settings.'scraper.movie.javlibrary' -or $cache:settings.'scraper.movie.javlibraryja' -or $cache:settings.'scraper.movie.javlibraryzh') {
                if (-not ($cache:cfSession)) {
                    try {
                        Invoke-WebRequest -Uri $cache:settings.'javlibrary.baseurl' -Verbose:$false | Out-Null
                    } catch {
                        try {
                            # Test with persisted settings
                            if ($cache:settings.'javlibrary.cookie.cf_chl_2' -and $cache:settings.'javlibrary.cookie.cf_chl_prog' -and $cache:settings.'javlibrary.cookie.cf_clearance' -and $cache:settings.'javlibrary.browser.useragent') {
                                $cache:cfSession = Get-CfSession -cf_chl_2:$cache:settings.'javlibrary.cookie.cf_chl_2' -cf_chl_prog:$cache:settings.'javlibrary.cookie.cf_chl_prog' -cf_clearance:$cache:settings.'javlibrary.cookie.cf_clearance' `
                                    -UserAgent:$cache:settings.'javlibrary.browser.useragent' -BaseUrl $cache:settings.'javlibrary.baseurl'

                                # Testing with the newly created session sometimes fails if there is no wait time
                                Start-Sleep -Seconds 1

                                Invoke-WebRequest -Uri $cache:settings.'javlibrary.baseurl' -WebSession $cache:cfSession -UserAgent $cache:cfSession.UserAgent -Verbose:$false | Out-Null
                            } else {
                                Show-JVCfModal
                                return
                            }
                        } catch {
                            Show-JVCfModal
                            return
                        }
                    }
                } else {
                    try {
                        Invoke-WebRequest -Uri $cache:settings.'javlibrary.baseurl' -WebSession $cache:cfSession -UserAgent $cache:cfSession.UserAgent -Verbose:$false | Out-Null
                    } catch {
                        Show-JVCfModal
                        return
                    }
                }
            }

            Show-JVProgressModal -Sort

            if ($interactive) {
                Update-JVPage -ClearData
                if ($Path) {
                    $Item = (Get-Item -LiteralPath $Path)
                }
                if ($Item.Mode -like 'd*') {
                    $cache:searchTotal = ($cache:settings | Get-JVItem -Path $Item.FullName -Recurse:$Recurse -Strict:$Strict).Count
                    $cache:tempFile = New-TemporaryFile

                    if ($Depth -gt 0 -and $Recurse) {
                        $jvData = Javinizer -Path $Item.FullName -Recurse:$Recurse -Depth:$Depth -Strict:$Strict -HideProgress -IsWeb -IsWebType 'Search' -WebTempPath $cache:tempFile
                    } else {
                        $jvData = Javinizer -Path $Item.FullName -Recurse:$Recurse -Strict:$Strict -HideProgress -IsWeb -IsWebType 'Search' -WebTempPath $cache:tempFile
                    }

                    if ($null -ne $jvData) {
                        $sortedData = ($jvData | Sort-Object { $_.Data.Id })
                        $sortedData | ForEach-Object { $cache:findData.Add($_) }
                    } else {
                        Show-JVToast -Type Error -Message 'No movies matched'
                    }
                } else {
                    $movieId = ($cache:settings | Get-JVItem -Path $Item.FullName).Id
                    <# Set-UDElement -Id 'textbox-sort-manualsearch' -Properties @{
                        value = $movieId
                    } #>

                    $jvData = Javinizer -Path $Item.FullName -Strict:$Strict -HideProgress -IsWeb -IsWebType 'Search'

                    if ($null -ne $jvData) {
                        $sortedData = $jvData
                        $sortedData | ForEach-Object { $cache:findData.Add($_) }
                    } else {
                        Show-JVToast -Type Error -Message "[$movieId] not matched"
                    }
                }

                # We want to clone the data here so we can reset specific metadata to default if desired
                # Since there is no easy way to clone a PSCustomObject, we need to convert the object into a plaintext json so we can then assign it to the new variable
                $tempData = $sortedData | ConvertTo-Json -Depth 32 | ConvertFrom-Json -Depth 32
                #$cache:originalFindData = ($tempData | ConvertFrom-Json -Depth 32) | Sort-Object { $_.Data.Id }
                $tempData | ForEach-Object { $cache:originalFindData.Add($_) }
            } else {
                if ($Item.Mode -like 'd*') {
                    if ($Depth -gt 0) {
                        Javinizer -Path $Item.FullName -Recurse:$Recurse -Depth:$Depth -Strict:$Strict -Update:$Update -Force:$Force -HideProgress -IsWeb -IsWebType 'Sort'
                    } else {
                        Javinizer -Path $Item.FullName -Recurse:$Recurse -Strict:$Strict -Update:$Update -Force:$Force -HideProgress -IsWeb -IsWebType 'Sort'
                    }
                } else {
                    Javinizer -Path $Item.FullName -Strict:$Strict -Update:$Update -Force:$Force -HideProgress -IsWeb -IsWebType 'Sort'
                }
            }
            Update-JVPage -Sort -ClearProgress
            Show-JVProgressModal -Off


        } else {
            Show-JVToast -Type Error -Message 'A job is currently running, please wait'
        }
    }

    end {
        Remove-Item -Path $cache:tempFile -ErrorAction SilentlyContinue
    }

}

function Get-EmbyActors {
    [CmdletBinding()]
    param (
        [String]$Url,
        [String]$ApiKey
    )

    $actressUrl = "$Url/emby/Persons/?api_key=$ApiKey"
    $request = (Invoke-RestMethod -Method Get -Uri $actressUrl -ErrorAction Stop -Verbose:$false).Items | Select-Object Name, Id, @{Name = 'Thumb'; Expression = { if ($null -ne $_.ImageTags.Thumb) { 'Exists' } else { 'NULL' } } }, @{Name = 'Primary'; Expression = { if ($null -ne $_.ImageTags.Primary) { 'Exists' } else { 'NULL' } } }
    Write-Output $request
}

function ConvertTo-Reverse {
    $arr = @($input)
    [array]::Reverse($arr)
    $arr
}

function New-JVAppBar {
    [CmdletBinding()]
    param (
    )

    $drawer = New-UDDrawer -Children {
        New-UDList -SubHeader "Javinizer Web GUI v$($cache:guiVersion)" -Children {
            New-UDListItem -Label 'Sort' -Icon $iconSearchLocation -OnClick {
                Invoke-UDRedirect -Url '/sort'
            }
            New-UDListItem -Label 'Settings' -Icon $iconCog -OnClick {
                Invoke-UDRedirect -Url '/settings'
            }
            New-UDListItem -Label 'Stats' -Icon $iconTable -OnClick {
                Invoke-UDRedirect -Url '/stats'
            }
            New-UDListItem -Label "Console" -Icon $iconTerminal -OnClick {
                Invoke-UDRedirect -Url '/console'
            }
            New-UDListItem -Label "Emby" -Icon $iconServer -OnClick {
                Invoke-UDRedirect -Url '/emby'
            }
            New-UDListItem -Label "About" -Icon $iconQuestion -OnClick {
                Invoke-UDRedirect -Url '/about'
            }
            New-UDListItem -Label "Docs" -Icon $iconBook -OnClick {
                Invoke-UDRedirect -Url 'https://docs.jvlflame.net' -OpenInNewWindow
            }
            New-UDListItem -Label "GitHub" -Icon $iconGithub -OnClick {
                Invoke-UDRedirect -Url 'https://github.com/jvlflame/Javinizer' -OpenInNewWindow
            }
        }
    }

    New-UDStyle -Style '
    .MuiButton-text {
        padding: 6px 8px;
    }
    .MuiButton-label {
        color: white;
    }
    .MuiIconButton-edgeStart {
        position: fixed;
        left: 20px;
    }
    .MuiPaper-root {
        align-items: flex-end;
    }' -Content {
        New-UDAppBar -Position fixed -Drawer $Drawer -Children {
            #New-UDTypography -Text "$Title" -Variant h6
            # New-UDElement -Tag 'div' -Content { "$Title" }


            New-UDButton -Text 'Sort' -Variant text -OnClick {
                Invoke-UDRedirect -Url '/sort'
            }
            New-UDButton -Text 'Settings' -Variant text -OnClick {
                Invoke-UDRedirect -Url '/settings'
                #Show-JVSettingsModal
            }
            New-UDButton -Text 'Stats' -Variant text -OnClick {
                Invoke-UDRedirect -Url '/stats'
            }
        }
    }
}

$Pages += New-UDPage -Name "Sort" -Content {
    New-JVAppBar
    New-UDScrollUp
    $cache:fileBrowserType = 'Sort'
    New-UDStyle -Style '
    .MuiFormHelperText-root {
        margin: 0;
        font-size: 0.75rem;
        margin-top: 3px;
        text-align: left;
        font-family: "Roboto", "Helvetica", "Arial", sans-serif;
        font-weight: 400;
        line-height: initial;
        letter-spacing: 0.03333em;
    }' -Content {
        New-UDGrid -Container -Content {
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                New-UDDynamic -Id 'dynamic-sort-movieselect' -Content {
                    if (($cache:index -eq 0) -and (($cache:findData).Count -eq 0)) {
                        $cache:currentIndex = 0
                    } else {
                        $cache:currentIndex = $cache:index + 1
                    }

                    if (-not ($($cache:findData[$cache:index].Data.Id))) {
                        $baseName = (Get-Item -Path $cache:findData[$cache:index].Path).BaseName
                        $cardTitle = "($cache:currentIndex of $(($cache:findData).Count)) $baseName"
                    } elseif ($($cache:findData[$cache:index].PartNumber)) {
                        $cardTitle = "($cache:currentIndex of $(($cache:findData).Count)) $($cache:findData[$cache:index].Data.Id) - pt$($cache:findData[$cache:index].PartNumber)"
                    } else {
                        $cardTitle = "($cache:currentIndex of $(($cache:findData).Count)) $($cache:findData[$cache:index].Data.Id)"
                    }
                    New-UDCard -Title $cardTitle -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 7 -Content {
                                $findDataArray = @()
                                $counter = 1
                                if ($cache:findData.Count -eq 0) {
                                    $findDataArray += 'Empty'
                                } else {
                                    foreach ($movie in $cache:findData) {
                                        if ($null -eq $movie.Data) {
                                            $entry = "> NOT MATCHED [$counter]"
                                        } else {
                                            $entry = "$($movie.Data.Id) [$counter]"
                                        }
                                        $findDataArray += $entry
                                        $counter++
                                    }
                                }
                                New-UDStyle -Style '
                                .MuiAutocomplete-hasPopupIcon.MuiAutocomplete-hasClearIcon .MuiAutocomplete-inputRoot[class*="MuiOutlinedInput-root"] {
                                    padding-right: 65px;
                                    height: 40px;
                                }

                                .MuiAutocomplete-inputRoot[class*="MuiOutlinedInput-root"] .MuiAutocomplete-input {
                                    padding: 3px 4px;
                                }' -Content {
                                    New-UDAutocomplete -Id 'autocomplete-sort-movieselect' -Options $findDataArray -Value ($findDataArray[$cache:index]) -OnChange {
                                        try {
                                            [Int]$findDataIndex = ((Get-UDElement -Id 'autocomplete-sort-movieselect').value | Select-String -Pattern '\[(\d*)\]').Matches.Groups[1].Value
                                            if ($findDataIndex -eq 0) {
                                                $cache:index = 0
                                            } else {
                                                $cache:index = $findDataIndex - 1
                                            }
                                            Update-JVPage -Sort
                                        } catch {
                                            $index = $cache:index
                                            if ($findDataArray -notcontains 'Empty') {
                                                Show-UDModal -FullWidth -MaxWidth sm -Persistent -Content {
                                                    New-UDTypography -Variant h6 -Text "Remove this movie from the current sort?"
                                                    New-UDList -Children {
                                                        New-UDListItem -Label 'Id' -SubTitle "$($cache:findData[$cache:index].Data.Id)"
                                                        New-UDListItem -Label 'Path' -SubTitle "$($cache:findData[$cache:index].Path)"
                                                    }
                                                } -Footer {
                                                    New-UDButton -Text 'Ok' -OnClick {
                                                        [Int]$findDataIndex = $cache:index
                                                        if ((($cache:findData).Count) -gt 1) {
                                                            # We use a conversion to ArrayList to be able to use the .RemoveAt method to easily
                                                            # remove the selected movie at the current index
                                                            $tempFindData = [System.Collections.ArrayList]$cache:findData
                                                            $tempOriginalFindData = [System.Collections.ArrayList]($cache:originalFindData)
                                                            $tempFindData.RemoveAt($cache:index)
                                                            $tempOriginalFindData.RemoveAt($cache:index)
                                                            $cache:findData = $tempFindData
                                                            $cache:originalFindData = ($tempOriginalFindData)
                                                        } else {
                                                            $cache:findData = @()
                                                            $cache:originalFindData = @()
                                                        }
                                                        if ($findDataIndex -eq 0) {
                                                            $cache:index = 0
                                                        } else {
                                                            $cache:index = $findDataIndex - 1
                                                        }
                                                        Update-JVPage -Sort
                                                        Hide-UDModal
                                                    }
                                                    New-UDButton -Text 'Cancel' -OnClick {
                                                        Set-UDElement -Id 'autocomplete-sort-movieselect' -Properties @{
                                                            value = $findDataArray[$cache:index]
                                                        }
                                                        Hide-UDModal
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 5 -Content {
                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -MediumSize 3 -Content {
                                        New-UDTooltip -TooltipContent { 'Navigate Left' } -Content {
                                            New-UDButton -Icon $iconLeftArrow -FullWidth -OnClick {
                                                if ($cache:index -gt 0) {
                                                    $cache:index -= 1
                                                } else {
                                                    $cache:index = ($cache:findData).Count - 1
                                                }
                                                Update-JVPage -Sort
                                            }
                                        }  -Place top -Effect solid -Type dark
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -MediumSize 3 -Content {
                                        New-UDTooltip -TooltipContent { 'Navigate Right' } -Content {
                                            New-UDButton -Icon $iconRightArrow -FullWidth -OnClick {
                                                if ($cache:index -lt (($cache:findData).Count - 1)) {
                                                    $cache:index += 1
                                                } else {
                                                    $cache:index = 0
                                                }
                                                Update-JVPage -Sort
                                            }
                                        } -Place top -Effect solid -Type dark
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -MediumSize 3 -Content {
                                        New-UDTooltip -TooltipContent { 'Complete sort on selected movie' } -Content {
                                            New-UDButton -Icon $iconForward -FullWidth -OnClick {
                                                $force = (Get-UDElement -Id 'checkbox-sort-force').checked
                                                $update = (Get-UDElement -Id 'checkbox-sort-update').checked
                                                if (!($cache:inProgress)) {
                                                    Show-JVProgressModal -Generic -NoCancel
                                                    $moviePath = $cache:findData[$cache:index].Path
                                                    if ($cache:settings.'location.output' -eq '') {
                                                        $destinationPath = (Get-Item -LiteralPath $moviePath).DirectoryName
                                                    } else {
                                                        $destinationPath = $cache:settings.'location.output'
                                                    }

                                                    try {
                                                        $sortParameters = @{
                                                            Data            = $cache:findData[$cache:index].Data
                                                            Path            = $moviePath
                                                            DestinationPath = $destinationPath
                                                            Settings        = $cache:settings
                                                            Update          = $update
                                                            PartNumber      = $cache:findData[$cache:index].PartNumber
                                                        }

                                                        $sortData = Get-JVSortData @sortParameters
                                                        Set-JVMovie -Data $cache:findData[$cache:index].Data -SortData $sortData.SortData -Path $moviePath -DestinationPath $destinationPath -Settings $cache:settings -Update:$update -Force:$force

                                                        if ((!($update)) -and ($cache:findData[$cache:index].Data.Id -ne '' -and $null -ne $cache:findData[$cache:index].Data.Id)) {
                                                            Write-JVWebLog -HistoryPath $cache:historyCsvPath -OriginalPath $cache:findData[$cache:index].Path -DestinationPath $sortData.SortData.FilePath -Data $cache:findData[$cache:index].Data -AllData $cache:findData[$cache:index].AllData
                                                        }

                                                        # Remove the movie after it's committed
                                                        if ($cache:findData.Count -gt 1) {
                                                            ($cache:findData).RemoveAt($cache:index)
                                                            ($cache:originalFindData).RemoveAt($cache:index)
                                                        } else {
                                                            Update-JVPage -Sort -ClearData
                                                        }

                                                        if ($cache:index -gt 0) {
                                                            $cache:index -= 1
                                                        }
                                                    } catch {
                                                        Show-JVToast -Type Error -Message "$PSItem"
                                                    }
                                                    Update-JVPage -Sort
                                                    Show-JVProgressModal -Off
                                                } else {
                                                    Show-JVToast -Type Error -Message 'A job is currently running, please wait'
                                                }
                                            }
                                        } -Place top -Effect solid -Type dark
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -MediumSize 3 -Content {
                                        New-UDTooltip -TooltipContent { 'Complete sort on all movies' } -Content {
                                            New-UDButton -Icon $iconFastForward -FullWidth -OnClick {
                                                $force = (Get-UDElement -Id 'checkbox-sort-force').checked
                                                $update = (Get-UDElement -Id 'checkbox-sort-update').checked
                                                if (!($cache:inProgress)) {
                                                    Show-JVProgressModal -Sort
                                                    $jvModulePath = $cache:fullModulePath
                                                    $tempSettings = $cache:settings
                                                    $tempHistoryPath = $cache:historyCsvPath
                                                    try {
                                                        $cache:findData | Invoke-JVParallel -IsWeb -IsWebType 'searchsort' -MaxQueue $cache:settings.'throttlelimit' -Throttle $cache:settings.'throttlelimit' -ImportFunctions -ScriptBlock {
                                                            Import-Module $using:jvModulePath
                                                            $settings = $using:tempSettings
                                                            $moviePath = $_.Path
                                                            if ($settings.'location.output' -eq '') {
                                                                $destinationPath = (Get-Item -LiteralPath $moviePath).DirectoryName
                                                            } else {
                                                                $destinationPath = $settings.'location.output'
                                                            }
                                                            if ($null -ne $_.Data) {
                                                                $sortParameters = @{
                                                                    Data            = $_.Data
                                                                    Path            = $moviePath
                                                                    DestinationPath = $destinationPath
                                                                    Update          = $using:update
                                                                    Settings        = $settings
                                                                    PartNumber      = $_.PartNumber
                                                                }
                                                                $sortData = Get-JVSortData @sortParameters

                                                                Set-JVMovie -Data $_.Data -SortData $sortData.SortData -Path $moviePath -DestinationPath $destinationPath -Settings $settings -Update:$using:update -Force:$using:force
                                                                if ((!($update)) -and ($_.Data.Id -ne '' -and $null -ne $_.Data.Id)) {
                                                                    Write-JVWebLog -HistoryPath $using:tempHistoryPath -OriginalPath $moviePath -DestinationPath $sortData.SortData.FilePath -Data $_.Data -AllData $_.AllData
                                                                }
                                                            }
                                                        }
                                                    } catch {
                                                        Show-JVToast -Type Error -Message "$PSItem"
                                                    }
                                                    Update-JVPage -Sort -ClearData -ClearProgress
                                                    Show-JVProgressModal -Off
                                                } else {
                                                    Show-JVToast -Type Error -Message 'A job is currently running, please wait'
                                                }
                                            }
                                        } -Place top -Effect solid -Type dark
                                    }
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                New-UDTooltip -TooltipContent { 'Open grid view' } -Place top -Effect solid -Type dark -Content {
                                    New-UDButton -Text 'Grid View' -FullWidth -OnClick {
                                        Show-UDModal -FullScreen -Content {
                                            New-UDDynamic -Id 'dynamic-sort-gridview' -Content {
                                                New-UDStyle -Style '
                                                    .MuiTypography-h6 {
                                                        text-align: center;
                                                    }
                                                    img {
                                                        width: 100%;
                                                        height: auto;
                                                        display: block;
                                                        margin-left: auto;
                                                        margin-right: auto;
                                                    }' -Content {
                                                    New-UDGrid -Container -Content {
                                                        $count = 0
                                                        foreach ($movie in $cache:findData) {
                                                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -LargeSize 3 -ExtraLargeSize 2 -Content {
                                                                New-UDPaper -Elevation 5 -Content {
                                                                    New-UDGrid -Container -Content {
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                            if ($null -eq $movie.Data.Id -or $movie.Data.Id -eq '') {
                                                                                $id = 'NOT MATCHED'
                                                                            } else {
                                                                                $id = $movie.Data.Id
                                                                            }
                                                                            New-UDTypography -Text "$id" -Variant h6
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                            New-UDImage -Width 450 -Height 300 -Url $movie.Data.CoverUrl
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                            $actors = @()
                                                                            foreach ($actor in $movie.Data.Actress) {
                                                                                $name = ("$($actor.LastName) $($actor.FirstName)").Trim()
                                                                                if ($name -eq '') {
                                                                                    $name = $actor.JapaneseName
                                                                                }
                                                                                $actors += $name
                                                                            }
                                                                            $actorList = ($actors | Sort-Object) -join ' \ '

                                                                            New-UDTextbox -Label 'FileName' -Value $movie.FileName -Disabled -FullWidth
                                                                            New-UDTextbox -Label 'Genre' -Value (($movie.Data.Genre | Sort-Object) -join ' \ ') -Disabled -FullWidth
                                                                            New-UDTextbox -Label 'Actors' -Value $actorList -Disabled -FullWidth
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 9 -SmallSize 9 -Content {
                                                                            New-UDButton -Text 'Select' -Size small -FullWidth -OnClick {
                                                                                $cache:index = $count
                                                                                Update-JVPage -Sort
                                                                                Hide-UDModal
                                                                            }
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -Content {
                                                                            New-UDButton -Icon $iconTrash -Size medium -FullWidth -OnClick {
                                                                                if ((($cache:findData).Count) -gt 1) {
                                                                                    $tempFindData = [System.Collections.ArrayList]$cache:findData
                                                                                    $tempOriginalFindData = [System.Collections.ArrayList]($cache:originalFindData)
                                                                                    $tempFindData.RemoveAt($count)
                                                                                    $tempOriginalFindData.RemoveAt($count)
                                                                                    $cache:findData = $tempFindData
                                                                                    $cache:originalFindData = ($tempOriginalFindData)
                                                                                } else {
                                                                                    $cache:findData = @()
                                                                                    $cache:originalFindData = @()
                                                                                }

                                                                                if ($cache:index -ge ($cache:findData).Count) {
                                                                                    $cache:index = ($cache:findData).Count - 1
                                                                                }

                                                                                Update-JVPage -Sort
                                                                                Sync-UDElement -Id 'dynamic-sort-gridview'
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            $count++
                                                        }
                                                    }
                                                }
                                            }
                                        } -Footer {
                                            New-UDButton -FullWidth -Text 'Close' -OnClick {
                                                Hide-UDModal
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                New-UDDynamic -Id 'dynamic-sort-coverimage' -Content {
                    New-UDStyle -Style '
                            .MuiCardContent-root:last-child {
                                padding-bottom: 10px;
                            }
                            .MuiCardHeader-root {
                                display: none;
                            }' -Content {

                        New-UDCard -Id 'card-sort-coverimage' -Title 'Cover' -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                    New-UDStyle -Style '
                                    img {
                                        width: 100%;
                                        height: auto;
                                        max-height: 645px;
                                        max-width: 960px;
                                        display: block;
                                        margin-left: auto;
                                        margin-right: auto;
                                    }' -Content {
                                        New-UDImage -Url $cache:findData[$cache:index].Data.CoverUrl
                                    }
                                }

                                <# New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                    New-UDStyle -Style '
                                    img {
                                        height: auto;
                                        max-height: 129px;
                                        max-width: 192px;
                                        display: initial;
                                        margin-left: auto;
                                        margin-right: auto;
                                    }' -Content {
                                        foreach ($img in $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                            New-UDImage -Url $img
                                        }
                                    }

                                } #>

                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                    if ($null -ne $cache:findData[$cache:index].Data.TrailerUrl) {
                                        New-UDButton -Icon $iconVideo -Text 'Trailer' -Size small -FullWidth -OnClick {
                                            Show-UDModal -FullWidth -MaxWidth sm -Content {
                                                New-UDPlayer -URL $cache:findData[$cache:index].Data.TrailerUrl -Width '550px'
                                            }
                                        }
                                    }
                                    if ($null -ne $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                        New-UDButton -Icon $iconImage -Text 'Screens' -Size small -FullWidth -OnClick {
                                            Show-UDModal -FullWidth -MaxWidth sm -Content {
                                                New-UDStyle -Style '
                                                    .MuiCardHeader-root {
                                                        display: none;
                                                    }

                                                    img {
                                                        width: auto;
                                                        height: auto;
                                                        max-height: 150px;
                                                    }' -Content {
                                                    New-UDGrid -Container -Content {
                                                        foreach ($img in $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                                            New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 6 -MediumSize 6 -Content {
                                                                New-UDCard -Content {
                                                                    New-UDImage -Url $img -Height 150
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                New-UDCard -Title 'Sort' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 8 -Content {
                            New-UDTextbox -Id 'textbox-sort-filepath' -Placeholder 'Enter a path (Defaults to setting "location.input")' -Value $cache:settings.'location.input' -FullWidth
                        }
                        New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 6 -MediumSize 2 -Content {
                            New-UDTooltip -TooltipContent { "Start sort on the specified directory" } -Content {
                                New-UDButton -Icon $iconSearch -FullWidth -OnClick {
                                    Invoke-JavinizerWeb -Path (Get-UDElement -Id 'textbox-sort-filepath').value
                                }
                            } -Place top -Effect solid -Type dark
                        }
                        New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 6 -MediumSize 2 -Content {
                            New-UDTooltip -TooltipContent { 'Clear current sort' } -Content {
                                New-UDButton -Icon $iconTrash -FullWidth -OnClick {
                                    Show-UDModal -FullWidth -MaxWidth sm -Content {
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                            New-UDTypography -Text "Are you sure you want to clear your current sort? This does not affect your local files."
                                        }
                                    } -Footer {
                                        New-UDButton -Text 'Ok' -OnClick {
                                            Update-JVPage -Sort -ClearData
                                            Hide-UDModal
                                        }
                                        New-UDButton -Text 'Cancel'  -OnClick {
                                            Hide-UDModal
                                        }
                                    }
                                }
                            } -Place top -Effect solid -Type dark
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                            New-UDTooltip -TooltipContent { 'Allows you to use the web GUI to preview and modify metadata before completing the sort' } -Content {
                                New-UDCheckBox -Id 'checkbox-sort-interactive' -Label 'Interactive' -LabelPlacement end -Checked $cache:settings.'web.sort.interactive' -OnChange {
                                    $cache:settings.'web.sort.interactive' = (Get-UDElement -Id 'checkbox-sort-interactive').checked
                                    Update-JVSettings
                                }
                            } -Place right -Effect float -Type dark
                            New-UDTooltip -TooltipContent { 'Performs a recursive sort on the specified directory (searches within folders)' } -Content {
                                New-UDCheckBox -Id 'checkbox-sort-recurse' -Label 'Recurse' -LabelPlacement end -Checked $cache:settings.'web.sort.recurse' -OnChange {
                                    $cache:settings.'web.sort.recurse' = (Get-UDElement -Id 'checkbox-sort-recurse').checked
                                    Update-JVSettings
                                }
                            } -Place right -Effect float -Type dark
                            New-UDTooltip -TooltipContent { 'Forces the filematcher to use the exact filename as the movie ID' } -Content {
                                New-UDCheckBox -Id 'checkbox-sort-strict' -Label 'Strict' -LabelPlacement end -Checked $cache:settings.'web.sort.strict' -OnChange {
                                    $cache:settings.'web.sort.strict' = (Get-UDElement -Id 'checkbox-sort-strict').checked
                                    Update-JVSettings
                                }
                            } -Place right -Effect float -Type dark
                            New-UDTooltip -TooltipContent { 'Runs the sort while only updating the nfo and missing image files' } -Content {
                                New-UDCheckBox -Id 'checkbox-sort-update' -Label 'Update' -LabelPlacement end -Checked $cache:settings.'web.sort.update' -OnChange {
                                    $cache:settings.'web.sort.update' = (Get-UDElement -Id 'checkbox-sort-update').checked
                                    Update-JVSettings
                                }
                            } -Place right -Effect float -Type dark
                            New-UDTooltip -TooltipContent { 'DANGER: Forces overwrite of existing movie/image files if they exist in the target destination' } -Content {
                                New-UDCheckBox -Id 'checkbox-sort-force' -Label 'Force' -LabelPlacement end -Checked $cache:settings.'web.sort.force' -OnChange {
                                    $cache:settings.'web.sort.force' = (Get-UDElement -Id 'checkbox-sort-force').checked
                                    Update-JVSettings
                                }
                            } -Place right -Effect float -Type dark
                            <# New-UDTooltip -TooltipContent { "If this option is enabled, a preview of Javinizer's filematcher output will be displayed instead of sorting the movies" } -Content {
                                New-UDCheckBox -Id 'checkbox-sort-preview' -Label 'Preview' -LabelPlacement end -Checked $cache:settings.'web.sort.preview' -OnChange {
                                    $cache:settings.'web.sort.preview' = (Get-UDElement -Id 'checkbox-sort-preview').checked
                                    Update-JVSettings
                                }
                            } -Place right -Effect float -Type dark #>
                            New-UDTooltip -TooltipContent { 'Specifies the recurse depth of the filematcher search (Set to 0 to disable custom depth)' } -Content {
                                New-UDSelect -Id 'select-sort-recursedepth' -Label 'Recurse Depth' -DefaultValue $cache:settings.'web.sort.recursedepth' -Option {
                                    0..10 | ForEach-Object { New-UDSelectOption -Name "$_" -Value $_ }
                                } -OnChange {
                                    [int]$cache:settings.'web.sort.recursedepth' = (Get-UDElement -Id 'select-sort-recursedepth').value
                                    Update-JVSettings
                                }
                            } -Place right -Effect float -Type dark
                        }
                    }
                }


                New-UDStyle -Style '
                        .MuiCardContent-root {
                            padding: 4px;
                            padding-bottom: 8px;
                        }
                        .MuiTableCell-root {
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap;
                            max-width: 200px;
                            padding: 12px;
                            border-bottom: 1px solid rgba(81, 81, 81, 1);
                        }
                        .MuiTableCell-root:hover {
                            overflow: visible;
                            white-space: normal;
                            height: auto;
                            max-width: 200px;
                        }
                        .MuiTableCell-body {
                            height: 64px;
                        }
                        .MuiExpansionPanelSummary-root {
                            min-height: 20px;
                        }
                        .MuiExpansionPanelSummary-root.Mui-expanded {
                            min-height: 20px;
                        }
                        .MuiExpansionPanelDetails-root {
                            display: flex;
                            padding: initial;
                        }
                        .MuiCardHeader-root {
                            display: none;
                        }
                        .MuiTypography-caption {
                            font-size: initial !important;
                        }
                        .MuiButton-label {
                            justify-content: initial !important;
                        }
                        .MuiButton-root {
                            font-size: inherit !important;
                            text-align: left;
                            text-transform: none;
                            line-height: initial !important;
                        }' -Content {
                    New-UDCard -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                New-UDDynamic -Id 'dynamic-sort-filebrowser' -Content {
                                    $cache:filePath = (Get-UDElement -Id 'textbox-sort-directorypath').value
                                    $search = Get-ChildItem -LiteralPath $cache:filePath | Select-Object Name, Length, FullName, Mode, Extension, LastWriteTime | ConvertTo-Reverse
                                    $searchColumns = @(
                                        New-UDTableColumn -Property Name -Title 'Name' -IncludeInSearch -Render {
                                            if ($EventData.Mode -like 'd*') {
                                                New-UDButton -Icon (New-UDIcon -Icon folder_open_o) -IconAlignment left -Text "$($EventData.Name)" -Variant 'text' -FullWidth -OnClick {
                                                    Set-UDElement -Id 'textbox-sort-directorypath' -Properties @{
                                                        value = $EventData.FullName
                                                    }
                                                    Set-UDElement -Id 'textbox-sort-filepath' -Properties @{
                                                        value = $EventData.FullName
                                                    }

                                                    $cache:tablePageSize = (Get-UDElement -Id 'table-filebrowser').userPageSize
                                                    Sync-UDElement -Id 'dynamic-sort-filebrowser'
                                                }
                                            } else {
                                                New-UDTypography -Variant 'display1' -Text "$($EventData.Name)"
                                            }
                                        }

                                        New-UDTableColumn -Property Length -Title 'Size' -IncludeInSearch -Width 100 -Render {
                                            if ($EventData.Mode -like 'd*') {
                                                New-UDTypography -Variant 'display1' -Text ''
                                            } else {
                                                New-UDTypography -Variant 'display1' -Text "$([Math]::Round($EventData.Length / 1GB, 2)) GB"
                                            }
                                        }

                                        New-UDTableColumn -Property LastWriteTime -Title 'Modified' -IncludeInSearch -Width 175 -Render {
                                            New-UDTypography -Variant 'display1' -Text "$($EventData.LastWriteTime)"
                                        }

                                        New-UDTableColumn -Property FullName -Title "$($cache:fileBrowserType)" -Width 150 -Render {
                                            $includedExtensions = $cache:settings.'match.includedfileextension'
                                            switch ($cache:fileBrowserType) {
                                                'Sort' {
                                                    if (($EventData.Mode -like 'd*') -or (($EventData.Extension -in $includedExtensions) -and ($EventData.Length -ge ($cache:settings.'match.minimumfilesize')) -and ($EventData.Name -notmatch ($cache:settings.'match.excludedfilestring')))) {
                                                        New-UDButton -Icon $iconSearch -IconAlignment left -Text 'Sort' -Variant outlined -OnClick {
                                                            Invoke-JavinizerWeb -Item $EventData
                                                        }
                                                    } else {
                                                        New-UDTypography -Text ''
                                                    }
                                                }

                                                'Edit' {
                                                    #$depthFiles = Get-ChildItem -LiteralPath $EventData.FullName -File | Where-Object { $_.Extension -in ".nfo", ".jpg" }

                                                    if (($EventData.Mode -like 'd*') -or ($EventData.Extension -in ".nfo")) {
                                                        New-UDButton -Icon $iconEdit -IconAlignment left -Text 'Edit' -Variant outlined -OnClick {
                                                            Show-UDToast ($depthFiles.Name | ConvertTo-Json)
                                                            Show-UDToast ($EventData | ConvertTo-Json) -Duration 5000
                                                        }
                                                    } else {
                                                        New-UDTypography -Text ''
                                                    }

                                                    #if ($depthFiles) {

                                                    #}

                                                }
                                            }
                                        }
                                    )
                                    New-UDTable -Id 'table-filebrowser' -Data $search -Columns $searchColumns -Title "Path: $cache:filePath" -Search -PageSize $cache:tablePageSize -ShowPagination -ShowSort
                                } <# -LoadingComponent {
                                    New-UDProgress
                                } #>

                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                        New-UDCard -Title 'Navigation' -Content {
                                            # Prioritize a user-selected path first, if not, then check location.input setting
                                            # If neither are set, default to either C:\ for Windows or root for Linux/MacOs
                                            if ($cache:filePath -eq '' -or $null -eq $cache:filePath) {
                                                if ($null -ne $cache:settings.'location.input' -and $cache:settings.'location.input' -ne '') {
                                                    $dir = $cache:settings.'location.input'
                                                } else {
                                                    if ($IsWindows) {
                                                        $dir = 'C:\'
                                                    } else {
                                                        $dir = '/'
                                                    }
                                                }
                                            } else {
                                                $dir = $cache:filePath
                                            }

                                            New-UDTextbox -Id 'textbox-sort-directorypath' -Placeholder 'Enter a path (Defaults to setting "location.input")' -Value $dir -FullWidth
                                            New-UDTooltip -TooltipContent { 'Navigate to the specified directory' } -Content {
                                                New-UDButton -Icon $iconSearch -OnClick {
                                                    $cache:filePath = (Get-UDElement -Id 'textbox-sort-directorypath').value

                                                    if (!(Test-Path -LiteralPath $cache:filePath)) {
                                                        Show-JVToast -Type Error -Message "[$cache:filePath] is not a valid path"
                                                    }

                                                    Sync-UDElement -Id 'dynamic-sort-filebrowser'
                                                }
                                            } -Place top -Effect solid -Type dark



                                            New-UDTooltip -TooltipContent { 'Navigate up one level' } -Content { New-UDButton -Icon $iconLevelUp -OnClick {
                                                    $dirPath = Get-Item -LiteralPath (Get-UDElement -Id 'textbox-sort-directorypath').value
                                                    if (Test-Path -LiteralPath $dirPath -PathType Container) {
                                                        $tempParent = $dirPath.Parent.FullName
                                                    } else {
                                                        $tempParent = $dirPath.DirectoryName
                                                    }

                                                    if ($null -eq $tempParent) {
                                                        $dirParent = $dirPath
                                                    } else {
                                                        $dirParent = $tempParent
                                                    }

                                                    if ($null -eq $dirParent -or $dirParent -eq '') {
                                                        if ($IsWindows) {
                                                            $dirParent = 'C:\'
                                                        } else {
                                                            $dirParent = '/'
                                                        }
                                                    }

                                                    Set-UDElement -Id 'textbox-sort-directorypath' -Properties @{
                                                        value = $dirParent
                                                    }

                                                    Set-UDElement -Id 'textbox-sort-filepath' -Properties @{
                                                        value = $dirParent
                                                    }

                                                    Sync-UDElement -Id 'dynamic-sort-filebrowser'
                                                }
                                            } -Place top -Effect solid -Type dark
                                        }
                                        New-UDTooltip -TooltipContent { 'Feature not yet available' } -Type dark -Effect solid -Place right -Content {
                                            New-UDTypography -Text 'Edit Mode'
                                            New-UDSwitch -Id 'switch-sort-browsertype' -OnChange {
                                                if ((Get-UDElement -Id 'switch-sort-browsertype').checked) {
                                                    $cache:fileBrowserType = 'Edit'
                                                } else {
                                                    $cache:fileBrowserType = 'Sort'
                                                }
                                                Sync-UDElement -Id 'dynamic-sort-filebrowser'
                                            } -Disabled
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                New-UDDynamic -Id 'dynamic-sort-aggregateddata' -Content {
                    New-UDStyle -Style '
                    .MuiCardContent-root:last-child {
                        padding-bottom: 4px;
                    }
                    .MuiCardHeader-root {
                        display: none;
                    }' -Content {
                        New-UDCard -Title "Aggregated Data" -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 10 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Path -ne ((($cache:originalFindData)[$cache:index]).Path)) {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-filepath' -Icon $iconExclamation -Label 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path -Disabled
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-filepath' -Label 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path -Disabled
                                        }
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-filepath' -Label 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path -Disabled
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 2 -Content {
                                    New-UDTooltip -TooltipContent { 'Preview output' } -Type dark -Place left -Effect solid -Content {
                                        New-UDStyle -Style '
                                        .MuiButton-root {
                                            padding: 10px 16px;
                                        }' -Content {
                                            $update = (Get-UDElement -Id 'checkbox-sort-update').checked
                                            New-UDButton -Text 'Preview' -FullWidth -Variant text -OnClick {
                                                $sortDataParameters = @{
                                                    Data            = $cache:findData[$cache:index].Data
                                                    Path            = $cache:findData[$cache:index].Path
                                                    DestinationPath = $cache:findData[$cache:index].DestinationPath
                                                    Update          = $update
                                                    Settings        = $cache:Settings
                                                    PartNumber      = $cache:findData[$cache:index].PartNumber
                                                }

                                                $sortData = Get-JVSortData @sortDataParameters
                                                Show-UDModal -FullWidth -MaxWidth md -Content {
                                                    New-UDTypography -Variant h6 -Text 'Output Names'
                                                    New-UDList -Children {
                                                        foreach ($item in ($sortData.SortData.PSObject.Properties | Where-Object { $_.Name -like '*name*' })) {
                                                            New-UDListItem -Label ([string]($item.Value)) -SubTitle $item.Name
                                                        }
                                                    }
                                                    New-UDTypography -Variant h6 -Text 'Output Paths'
                                                    New-UDList -Children {
                                                        foreach ($item in ($sortData.SortData.PSObject.Properties | Where-Object { $_.Name -like '*path*' })) {
                                                            New-UDListItem -Label ([string]($item.Value)) -SubTitle $item.Name
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Id } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Id -ne ((($cache:originalFindData)[$cache:index]).Data.Id)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-id' -Icon $iconExclamation -Label 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-id' -Label 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-id' -Label 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.ContentId } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.ContentId -ne ((($cache:originalFindData)[$cache:index]).Data.ContentId)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-contentid' -Icon $iconExclamation -Label 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-contentid' -Label 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-contentid' -Label 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.DisplayName } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.DisplayName -ne ((($cache:originalFindData)[$cache:index]).Data.DisplayName)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-displayname' -Icon $iconExclamation -Label 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-displayname' -Label 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-displayname' -Label 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Title } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Title -ne ((($cache:originalFindData)[$cache:index]).Data.Title)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-title' -Icon $iconExclamation -Label 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-title' -Label 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-title' -Label 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.AlternateTitle } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.AlternateTitle -ne ((($cache:originalFindData)[$cache:index]).Data.AlternateTitle)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-alternatetitle' -Icon $iconExclamation -Label 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-alternatetitle' -Label 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-alternatetitle' -Label 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Description } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Description -ne ((($cache:originalFindData)[$cache:index]).Data.Description)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-description' -Icon $iconExclamation -Label 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-description' -Label 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-description' -Label 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Director } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Director -ne ((($cache:originalFindData)[$cache:index]).Data.Director)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-director' -Icon $iconExclamation -Label 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-director' -Label 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-director' -Label 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.ReleaseDate } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.ReleaseDate -ne ((($cache:originalFindData)[$cache:index]).Data.ReleaseDate)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-releasedate' -Icon $iconExclamation -Label 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-releasedate' -Label 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-releasedate' -Label 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Runtime } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Runtime -ne ((($cache:originalFindData)[$cache:index]).Data.Runtime)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-runtime' -Icon $iconExclamation -Label 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-runtime' -Label 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-runtime' -Label 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Maker } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Maker -ne ((($cache:originalFindData)[$cache:index]).Data.Maker)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-maker' -Icon $iconExclamation -Label 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-maker' -Label 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-maker' -Label 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Label } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Label -ne ((($cache:originalFindData)[$cache:index]).Data.Label)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-label' -Icon $iconExclamation -Label 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-label' -Label 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-label' -Label 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Series } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Series -ne ((($cache:originalFindData)[$cache:index]).Data.Series)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-series' -Icon $iconExclamation -Label 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-series' -Label 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-series' -Label 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Tagline -ne ((($cache:originalFindData)[$cache:index]).Data.Tagline)) {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-tagline' -Icon $iconExclamation -Label 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-tagline' -Label 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                        }
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-tagline' -Label 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Rating } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Rating.Rating -ne ((($cache:originalFindData)[$cache:index]).Data.Rating.Rating)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-rating' -Icon $iconExclamation -Label 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-rating' -Label 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-rating' -Label 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Rating } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.Rating.Votes -ne ((($cache:originalFindData)[$cache:index]).Data.Rating.Votes)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-votes' -Icon $iconExclamation -Label 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-votes' -Label 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-votes' -Label 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 10 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.Genre } -Content {
                                        if ($cache:originalFindData) {
                                            if ($null -ne $cache:findData[$cache:index].Data.Genre) {
                                                if ($null -ne ($cache:originalFindData)[$cache:index].Data.Genre) {
                                                    if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.Genre -DifferenceObject ((($cache:originalFindData)[$cache:index]).Data.Genre)) {
                                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Icon $iconExclamation -Label 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                                    } else {
                                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Label 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                                    }
                                                } else {
                                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Icon $iconExclamation -Label 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                                }
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Label 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Label 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 2 -Content {
                                    New-UDTooltip -TooltipContent { 'Edit Genres' } -Type dark -Place left -Effect solid -Content {
                                        New-UDStyle -Style '
                                        .MuiButton-root {
                                            padding: 10px 16px;
                                        }' -Content {
                                            New-UDButton -Icon $iconEdit -Text 'Edit' -FullWidth -Variant outlined -OnClick {
                                                Show-JVEditorModal -Data $cache:findData[$cache:index].Data.Genre -Title 'Genres' -Type genre
                                            }
                                        }
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 10 -Content {
                                    if ($cache:originalFindData) {
                                        if ($null -ne $cache:findData[$cache:index].Data.Tag) {
                                            if ($null -ne ($cache:originalFindData)[$cache:index].Data.Tag) {
                                                if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.Tag -DifferenceObject ((($cache:originalFindData)[$cache:index]).Data.Tag)) {
                                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Icon $iconExclamation -Label 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                                } else {
                                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Label 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                                }
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Icon $iconExclamation -Label 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Label 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Label 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 2 -Content {
                                    New-UDTooltip -TooltipContent { 'Edit Tags' } -Type dark -Place left -Effect solid -Content {
                                        New-UDStyle -Style '
                                        .MuiPaper-root {
                                            text-align: center;
                                        }
                                        .MuiButton-root {
                                            padding: 10px 16px;
                                        }' -Content {
                                            New-UDButton -Icon $iconEdit -Text 'Edit' -FullWidth -Variant outlined -OnClick {
                                                Show-JVEditorModal -Data $cache:findData[$cache:index].Data.Tag -Title 'Tags' -Type tag
                                            }
                                        }
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.CoverUrl } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.CoverUrl -ne ((($cache:originalFindData)[$cache:index]).Data.CoverUrl)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-coverurl' -Icon $iconExclamation -Label 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-coverurl' -Label 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-coverurl' -Label 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.ScreenshotUrl } -Content {
                                        if ($cache:originalFindData) {
                                            if ($null -ne $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                                if ($null -ne ($cache:originalFindData)[$cache:index].Data.ScreenshotUrl) {
                                                    if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.ScreenshotUrl -DifferenceObject ((($cache:originalFindData)[$cache:index]).Data.ScreenshotUrl)) {
                                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Icon $iconExclamation -Label 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                                    } else {
                                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Label 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                                    }
                                                } else {
                                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Icon $iconExclamation -Label 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                                }
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Label 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Label 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { $cache:findData[$cache:index].Selected.TrailerUrl } -Content {
                                        if ($cache:originalFindData) {
                                            if ($cache:findData[$cache:index].Data.TrailerUrl -ne ((($cache:originalFindData)[$cache:index]).Data.TrailerUrl)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-trailerurl' -Icon $iconExclamation -Label 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl

                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-trailerurl' -Label 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-trailerurl' -Label 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                        }
                                    } -Place top -Type dark -Effect solid
                                }

                                New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                    New-UDTooltip -TooltipContent { 'Apply changes to metadata' } -Content {
                                        New-UDButton -Id 'button-sort-aggregateddata-apply' -Icon $iconCheck -Text 'Apply' -FullWidth -OnClick {
                                            if ($null -eq $cache:findData[$cache:index].Data) {
                                                $cache:findData[$cache:index].Data = [PSCustomObject]@{
                                                    Id             = $null
                                                    ContentId      = $null
                                                    DisplayName    = $null
                                                    Title          = $null
                                                    AlternateTitle = $null
                                                    Description    = $null
                                                    Rating         = $null
                                                    ReleaseDate    = $null
                                                    Runtime        = $null
                                                    Director       = $null
                                                    Maker          = $null
                                                    Label          = $null
                                                    Series         = $null
                                                    Tag            = @()
                                                    Tagline        = $null
                                                    Actress        = @()
                                                    Genre          = $null
                                                    CoverUrl       = $null
                                                    ScreenshotUrl  = @()
                                                    TrailerUrl     = $null
                                                    MediaInfo      = @()
                                                }
                                            }
                                            Set-UDElement -Id 'button-sort-aggregateddata-apply' -Properties @{
                                                Disabled = $true
                                            }
                                            if (!(Test-Path -LiteralPath (Get-UDElement -Id 'textbox-sort-aggregateddata-filepath').value -PathType Leaf)) {
                                                $tempPath = (Get-UDElement -Id 'textbox-sort-aggregateddata-filepath').value
                                                Show-JVToast -Type Error -Message "[$tempPath] is not a valid filepath"
                                                Update-JVPage -Sort
                                            } else {
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-filepath').value -eq '') {
                                                    $cache:findData[$cache:index].Path = $null
                                                } else {
                                                    $cache:findData[$cache:index].Path = (Get-UDElement -Id 'textbox-sort-aggregateddata-filepath').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-id').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Id = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Id = (Get-UDElement -Id 'textbox-sort-aggregateddata-id').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-contentid').value -eq '') {
                                                    $cache:findData[$cache:index].Data.ContentId = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.ContentId = (Get-UDElement -Id 'textbox-sort-aggregateddata-contentid').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-displayname').value -eq '') {
                                                    $cache:findData[$cache:index].Data.DisplayName = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.DisplayName = (Get-UDElement -Id 'textbox-sort-aggregateddata-displayname').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-title').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Title = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Title = (Get-UDElement -Id 'textbox-sort-aggregateddata-title').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-alternatetitle').value -eq '') {
                                                    $cache:findData[$cache:index].Data.AlternateTitle = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.AlternateTitle = (Get-UDElement -Id 'textbox-sort-aggregateddata-alternatetitle').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-description').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Description = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Description = (Get-UDElement -Id 'textbox-sort-aggregateddata-description').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-releasedate').value -eq '') {
                                                    $cache:findData[$cache:index].Data.ReleaseDate = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.ReleaseDate = (Get-UDElement -Id 'textbox-sort-aggregateddata-releasedate').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-runtime').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Runtime = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Runtime = (Get-UDElement -Id 'textbox-sort-aggregateddata-runtime').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-director').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Director = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Director = (Get-UDElement -Id 'textbox-sort-aggregateddata-director').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-maker').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Maker = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Maker = (Get-UDElement -Id 'textbox-sort-aggregateddata-maker').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-label').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Label = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Label = (Get-UDElement -Id 'textbox-sort-aggregateddata-label').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-series').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Series = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Series = (Get-UDElement -Id 'textbox-sort-aggregateddata-series').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-tag').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Tag = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Tag = ((Get-UDElement -Id 'textbox-sort-aggregateddata-tag').value -split '\\').Trim() | Select-Object -Unique
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-tagline').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Tagline = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Tagline = (Get-UDElement -Id 'textbox-sort-aggregateddata-tagline').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-rating').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Rating.Rating = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Rating.Rating = (Get-UDElement -Id 'textbox-sort-aggregateddata-rating').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-votes').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Rating.Votes = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Rating.Votes = (Get-UDElement -Id 'textbox-sort-aggregateddata-votes').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-genre').value -eq '') {
                                                    $cache:findData[$cache:index].Data.Genre = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.Genre = ((Get-UDElement -Id 'textbox-sort-aggregateddata-genre').value -split '\\').Trim() | Select-Object -Unique
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-coverurl').value -eq '') {
                                                    $cache:findData[$cache:index].Data.CoverUrl = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.CoverUrl = (Get-UDElement -Id 'textbox-sort-aggregateddata-coverurl').value
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-screenshoturl').value -eq '') {
                                                    $cache:findData[$cache:index].Data.ScreenshotUrl = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.ScreenshotUrl = ((Get-UDElement -Id 'textbox-sort-aggregateddata-screenshoturl').value -split '\\').Trim()
                                                }
                                                if ((Get-UDElement -Id 'textbox-sort-aggregateddata-trailerurl').value -eq '') {
                                                    $cache:findData[$cache:index].Data.TrailerUrl = $null
                                                } else {
                                                    $cache:findData[$cache:index].Data.TrailerUrl = (Get-UDElement -Id 'textbox-sort-aggregateddata-trailerurl').value
                                                }
                                                Update-JVPage -Sort
                                            }
                                        }
                                    } -Place top -Type dark -Effect solid
                                }

                                New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                    New-UDTooltip -TooltipContent { 'Edit metadata using JSON' } -Content {
                                        New-UDButton -Icon $iconEdit -Text 'Json' -FullWidth -OnClick {
                                            Show-UDModal -FullWidth -MaxWidth md -Persistent -Content {
                                                if ($null -ne $cache:findData[$cache:index].Data) {
                                                    $aggregatedData = $cache:findData[$cache:index].Data | ConvertTo-Json -Depth 32
                                                } else {
                                                    $aggregatedData = [PSCustomObject]@{
                                                        Id             = $null
                                                        ContentId      = $null
                                                        DisplayName    = $null
                                                        Title          = $null
                                                        AlternateTitle = $null
                                                        Description    = $null
                                                        Rating         = $null
                                                        ReleaseDate    = $null
                                                        Runtime        = $null
                                                        Director       = $null
                                                        Maker          = $null
                                                        Label          = $null
                                                        Series         = $null
                                                        Tag            = @()
                                                        Tagline        = $null
                                                        Actress        = @()
                                                        Genre          = $null
                                                        CoverUrl       = $null
                                                        ScreenshotUrl  = @()
                                                        TrailerUrl     = $null
                                                        MediaInfo      = @()
                                                    } | ConvertTo-Json -Depth 32
                                                }
                                                New-UDCodeEditor -Id 'dynamic-sort-aggregateddataeditor' -Language 'json' -Width '117ch' -Height '85ch' -Theme vs-dark -Code $aggregatedData
                                            } -Footer {
                                                New-UDButton -Text 'Ok' -OnClick {
                                                    $cache:findData[$cache:index].Data = (Get-UDElement -Id 'dynamic-sort-aggregateddataeditor').code | ConvertFrom-Json
                                                    Update-JVPage -Sort
                                                    Hide-UDModal
                                                }
                                                New-UDButton -Text 'Reset' -OnClick {
                                                    if (($cache:findData).Length -eq 1) {
                                                        Set-UDElement -Id 'dynamic-sort-aggregateddataeditor' -Properties @{
                                                            code = ($cache:originalFindData).Data | ConvertTo-Json
                                                        }
                                                    } else {
                                                        Set-UDElement -Id 'dynamic-sort-aggregateddataeditor' -Properties @{
                                                            code = (($cache:originalFindData)[$cache:index]).Data | ConvertTo-Json
                                                        }
                                                    }
                                                }

                                                New-UDButton -Text "Cancel" -OnClick {
                                                    Hide-UDModal
                                                }
                                            }
                                        }
                                    } -Place top -Type dark -Effect solid
                                }

                                New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                    New-UDTooltip -TooltipContent { 'Reset metadata to default' } -Content {
                                        New-UDButton -Icon $iconUndo -Text 'Reset' -FullWidth -OnClick {
                                            if (($cache:findData).Length -eq 1) {
                                                $tempData = $cache:OriginalFindData | ConvertTo-Json -Depth 32
                                                $cache:findData = $tempData | ConvertFrom-Json -Depth 32
                                                Update-JVPage -Sort

                                            } else {
                                                $tempData = $cache:OriginalFindData[$cache:index] | ConvertTo-Json -Depth 32
                                                $cache:findData[$cache:index] = $tempData | ConvertFrom-Json -Depth 32
                                                Update-JVPage -Sort
                                            }
                                        }
                                    } -Place top -Type dark -Effect solid
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                    New-UDTooltip -TooltipContent { 'Perform a manual search on the currently selected movie' } -Content {
                                        New-UDButton -Icon $iconSearch -Text 'Manual Search' -FullWidth -OnClick {
                                            Show-UDModal -FullWidth -MaxWidth sm -Content {
                                                New-UDGrid -Container -Content {
                                                    New-UDGrid -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                        New-UDTooltip -TooltipContent { 'Basic search performs a strict ID or combined URL search on scraper(s) of your choice and automatically chooses and aggregates data from the first match' } -Type dark -Place top -Effect solid -Content {
                                                            New-UDButton -FullWidth -Text 'Basic Search' -OnClick {
                                                                Show-UDModal -FullWidth -MaxWidth sm -Persistent -Content {
                                                                    New-UDTypography -Text 'If entering an ID, select the scraper(s) you want to search the ID for. Any selected scraper (including URLs) will need to be included in your metadata priority settings to be matched to the data fields.'
                                                                    New-UDTextbox -Id 'textbox-sort-manualsearch' -Label 'Enter an ID or a comma separated list of URLs' -FullWidth -Multiline -Autofocus
                                                                    New-UDCard -Content {
                                                                        New-UDGrid -Container -Content {
                                                                            foreach ($scraper in $scraperSettings) {
                                                                                New-UDGrid -Item -ExtraSmallSize 8 -SmallSize 4 -MediumSize 4 -Content {
                                                                                    New-UDCheckBox -Id "checkbox-sort-scraper-$scraper" -Label $scraper -Checked $cache:settings."web.sort.manualsearch.$scraper" -OnChange {
                                                                                        $cache:settings."web.sort.manualsearch.$scraper" = (Get-UDElement -Id "checkbox-sort-scraper-$scraper").checked
                                                                                        ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                } -Footer {
                                                                    New-UDButton -Text 'Submit' -OnClick {
                                                                        $searchInput = (Get-UDElement -Id 'textbox-sort-manualsearch').value
                                                                        if (!($cache:inProgress)) {
                                                                            Show-JVProgressModal -Generic
                                                                            if ($searchInput -like '*http*') {
                                                                                $searchInput = ($searchInput -split ',').Trim()
                                                                            }
                                                                            $findParams = @{
                                                                                Find         = $searchInput
                                                                                Dmm          = $cache:settings.'web.sort.manualsearch.dmm'
                                                                                DmmJa        = $cache:settings.'web.sort.manualsearch.dmmja'
                                                                                Jav321Ja     = $cache:settings.'web.sort.manualsearch.jav321ja'
                                                                                Javbus       = $cache:settings.'web.sort.manualsearch.javbus'
                                                                                JavbusJa     = $cache:settings.'web.sort.manualsearch.javbusja'
                                                                                JavbusZh     = $cache:settings.'web.sort.manualsearch.javbuszh'
                                                                                Javlibrary   = $cache:settings.'web.sort.manualsearch.javlibrary'
                                                                                JavlibraryJa = $cache:settings.'web.sort.manualsearch.javlibraryja'
                                                                                JavlibraryZh = $cache:settings.'web.sort.manualsearch.javlibraryzh'
                                                                                R18          = $cache:settings.'web.sort.manualsearch.r18'
                                                                                R18Zh        = $cache:settings.'web.sort.manualsearch.r18zh'
                                                                                Aggregated   = $true
                                                                                Search       = $true
                                                                            }

                                                                            $jvData = Javinizer @findParams

                                                                            if ($null -ne $jvData) {
                                                                                $cache:findData[$cache:index].Data = $jvData.Data
                                                                                $cache:findData[$cache:index].AllData = $jvData.AllData
                                                                                $cache:findData[$cache:index].ManualSearch = $true
                                                                            } else {
                                                                                Show-JVToast -Type Error -Message "Id [$searchInput] not found"
                                                                            }

                                                                            Update-JVPage -Sort
                                                                            Show-JVProgressModal -Off
                                                                        } else {
                                                                            Show-JVToast -Type Error -Message 'A job is currently running, please wait'
                                                                        }
                                                                    }
                                                                    New-UDButton -Text 'Cancel' -OnClick {
                                                                        Hide-UDModal
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                        New-UDTooltip -TooltipContent { 'Advanced search opens an ID/URL search builder that grants you more flexibility in finding and selecting metadata' } -Type dark -Place top -Effect solid -Content {
                                                            New-UDButton -FullWidth -Text 'Advanced Search' -OnClick {
                                                                Show-UDModal -FullWidth -MaxWidth xl -Content {
                                                                    New-UDCard -Title 'Search' -Content {
                                                                        New-UDGrid -Container -Content {
                                                                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                                New-UDDynamic -Id 'dynamic-sort-advsearchinprogress' -Content {
                                                                                    if ($cache:inProgressAdvSearch) {
                                                                                        New-UDTypography -Text "Search is currently running on $cache:searchInput..."
                                                                                        New-UDTypography -Text '' -Variant h1
                                                                                    }
                                                                                } -AutoRefresh -AutoRefreshInterval 1.5
                                                                            }
                                                                            New-UDGrid -Item -ExtraSmallSize 8 -SmallSize 8 -Content {
                                                                                New-UDTextbox -Id 'textbox-sort-advsearch' -FullWidth -Label 'Enter an ID or a comma separated list of URLs' -Autofocus
                                                                            }
                                                                            New-UDGrid -Item -ExtraSmallSize 4 -SmallSize 4 -Content {
                                                                                $cache:advSearchMatched = New-Object System.Collections.ArrayList
                                                                                $cache:advSearchSelected = New-Object System.Collections.ArrayList
                                                                                New-UDButton -Text 'Search' -FullWidth -OnClick {
                                                                                    if ($cache:inProgressAdvSearch -ne $true) {
                                                                                        $cache:inProgressAdvSearch = $true
                                                                                        $cache:searchInput = (Get-UDElement -Id 'textbox-sort-advsearch').value

                                                                                        if ($cache:searchInput -like '*http*') {
                                                                                            $cache:searchInput = ($cache:searchInput -split ',').Trim()
                                                                                        }

                                                                                        $findParams = @{
                                                                                            Find         = $cache:searchInput
                                                                                            Dmm          = $cache:settings.'web.sort.manualsearch.dmm'
                                                                                            DmmJa        = $cache:settings.'web.sort.manualsearch.dmmja'
                                                                                            Jav321Ja     = $cache:settings.'web.sort.manualsearch.jav321ja'
                                                                                            Javbus       = $cache:settings.'web.sort.manualsearch.javbus'
                                                                                            JavbusJa     = $cache:settings.'web.sort.manualsearch.javbusja'
                                                                                            JavbusZh     = $cache:settings.'web.sort.manualsearch.javbuszh'
                                                                                            Javlibrary   = $cache:settings.'web.sort.manualsearch.javlibrary'
                                                                                            JavlibraryJa = $cache:settings.'web.sort.manualsearch.javlibraryja'
                                                                                            JavlibraryZh = $cache:settings.'web.sort.manualsearch.javlibraryzh'
                                                                                            R18          = $cache:settings.'web.sort.manualsearch.r18'
                                                                                            R18Zh        = $cache:settings.'web.sort.manualsearch.r18zh'
                                                                                            AllResults   = $true
                                                                                        }

                                                                                        try {
                                                                                            $matched = Javinizer @findParams
                                                                                            $matched | ForEach-Object {
                                                                                                if ($cache:advSearchMatched.Url -notcontains $_.Url) {
                                                                                                    $cache:advSearchMatched.Add($_)
                                                                                                }
                                                                                            }
                                                                                        } catch {
                                                                                            Show-JVToast -Type Error -Message "$PSItem"
                                                                                        }
                                                                                        $cache:inProgressAdvSearch = $false
                                                                                        Sync-UDElement -Id 'dynamic-sort-advsearch'
                                                                                    } else {
                                                                                        Show-JVToast -Type Error -Message 'A job is currently running, please wait'
                                                                                    }

                                                                                }
                                                                                New-UDButton -Text 'Clear' -FullWidth -OnClick {
                                                                                    $cache:advSearchMatched = New-Object System.Collections.ArrayList
                                                                                    Sync-UDElement -Id 'dynamic-sort-advsearch'
                                                                                }
                                                                            }
                                                                            foreach ($scraper in $scraperSettings) {
                                                                                New-UDGrid -Item -ExtraSmallSize 8 -SmallSize 4 -MediumSize 3 -Content {
                                                                                    New-UDCheckBox -Id "checkbox-sort-advscraper-$scraper" -Label $scraper -Checked $cache:settings."web.sort.manualsearch.$scraper" -OnChange {
                                                                                        $cache:settings."web.sort.manualsearch.$scraper" = (Get-UDElement -Id "checkbox-sort-advscraper-$scraper").checked
                                                                                        ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }

                                                                    New-UDCard -Title 'Select Matches (only select one movie per scraper source)' -Content {
                                                                        New-UDDynamic -Id 'dynamic-sort-advsearch' -Content {
                                                                            New-UDGrid -Container -Content {
                                                                                $count = 0
                                                                                foreach ($movie in $cache:advSearchMatched) {
                                                                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -LargeSize 3 -ExtraLargeSize 2 -Content {
                                                                                        New-UDStyle -Style '
                                                                                        .MuiCardContent-root:last-child {
                                                                                            padding-bottom: 10px;
                                                                                        }
                                                                                        .MuiCardHeader-root {
                                                                                            display: none;
                                                                                        }' -Content {
                                                                                            New-UDCard -Content { #-Elevation 5
                                                                                                New-UDGrid -Container -Content {
                                                                                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                                                        New-UDStyle -Style '
                                                                                                            img {
                                                                                                                display: block;
                                                                                                                margin-left: auto;
                                                                                                                margin-right: auto;
                                                                                                            }' -Content {
                                                                                                            New-UDImage -Url $movie.CoverUrl -Width 300 -Height 200
                                                                                                        }
                                                                                                    }
                                                                                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                                                        $actors = @()
                                                                                                        foreach ($actor in $movie.Actress) {
                                                                                                            $name = ("$($actor.LastName) $($actor.FirstName)").Trim()
                                                                                                            if ($null -eq $name -or $name -eq '') {
                                                                                                                $name = $actor.JapaneseName
                                                                                                            }
                                                                                                            $actors += $name
                                                                                                        }
                                                                                                        $actorList = ($actors | Sort-Object) -join ' \ '

                                                                                                        New-UDTextbox -Value $movie.Source -Disabled -FullWidth
                                                                                                        New-UDTextbox -Value $movie.Id -Disabled -FullWidth
                                                                                                        New-UDTextbox -Value $movie.Title -Disabled -FullWidth
                                                                                                        New-UDTextbox -Value $movie.ReleaseDate -Disabled -FullWidth
                                                                                                        New-UDTextbox -Value $actorList -Disabled -FullWidth
                                                                                                        New-UDTextbox -Value $movie.Url -Disabled -FullWidth
                                                                                                    }
                                                                                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                                                        if ($count -in $cache:advSearchSelected) {
                                                                                                            New-UDButton -Text 'Remove' -Size small -FullWidth -OnClick {
                                                                                                                $cache:advSearchSelected.Remove($count)
                                                                                                                Sync-UDElement -Id 'dynamic-sort-advsearch'
                                                                                                            } -Style @{
                                                                                                                'background-color' = 'darkred'
                                                                                                            }
                                                                                                        } else {
                                                                                                            New-UDButton -Text 'Select' -Size small -FullWidth -OnClick {
                                                                                                                $cache:advSearchSelected.Add($count)
                                                                                                                Sync-UDElement -Id 'dynamic-sort-advsearch'
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                    $count++
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                } -Footer {
                                                                    New-UDButton -Text 'Submit' -OnClick {
                                                                        $selectedData = New-Object System.Collections.ArrayList
                                                                        foreach ($index in $cache:advSearchSelected) {
                                                                            $selectedData.Add($cache:advSearchMatched[$index])
                                                                        }

                                                                        try {
                                                                            $advAggregatedData = Get-JVAggregatedData -Data $selectedData -Settings $cache:Settings
                                                                            $cache:findData[$cache:index].Data = $advAggregatedData.Data
                                                                            $cache:findData[$cache:index].AllData = $selectedData
                                                                            $cache:findData[$cache:index].ManualSearch = $true
                                                                        } catch {
                                                                            Show-JVToast -Type Error -Message "$PSItem"
                                                                        }
                                                                        Update-JVPage -Sort
                                                                        Hide-UDModal
                                                                    }

                                                                    New-UDButton -Text 'Cancel' -OnClick {
                                                                        Hide-UDModal
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } -Place top -Type dark -Effect solid
                                }

                                New-UDGrid -Container -Content {
                                    if ($cache:originalFindData.Count -gt 0) {
                                        if (-not ($cache:findData[$cache:index].ManualSearch)) {
                                            $enabledScrapers = ($cache:settings.PSObject.Properties | Where-Object { $_.Name -like 'scraper.movie*' -and $_.Value -eq $true }).Name | ForEach-Object { ($_ -split '\.')[-1] } | Sort-Object
                                            $succeededScrapers = $cache:originalFindData[$cache:index].AllData.Source
                                        } else {
                                            $enabledScrapers = $cache:findData[$cache:index].AllData.Source
                                            $succeededScrapers = $cache:findData[$cache:index].AllData.Source
                                        }
                                    }

                                    foreach ($source in $enabledScrapers) {
                                        if ($succeededScrapers -contains $source) {
                                            New-UDTooltip -TooltipContent { "View $source data" } -Place top -Type dark -Effect solid -Content {
                                                New-UDButton -Text $source -OnClick {
                                                    $scraperOutput = $cache:originalFindData[$cache:index].AllData | Where-Object { $_.Source -eq $source }
                                                    Show-UDModal -FullWidth -MaxWidth md -Content {
                                                        New-UDGrid -Container -Content {
                                                            foreach ($prop in ($scraperOutput.PSObject.Properties)) {
                                                                New-UDGrid -Item -ExtraSmallSize 2 -SmallSize 2 -Content {
                                                                    switch ($prop.Name) {
                                                                        'source' { }
                                                                        'url' { }
                                                                        'ajaxid' { }
                                                                        'releaseyear' { }
                                                                        'actress' {
                                                                            New-UDButton -Text 'Replace' -Variant outlined -Size medium -OnClick {
                                                                                $cache:findData[$cache:index].Data.($prop.Name) = @($prop.Value)
                                                                                $cache:findData[$cache:index].Selected.($prop.Name) = $source
                                                                                Update-JVPage -Sort
                                                                            }
                                                                        }
                                                                        default {
                                                                            New-UDButton -Text 'Replace' -Variant outlined -Size medium -OnClick {
                                                                                $cache:findData[$cache:index].Data.($prop.Name) = $prop.Value
                                                                                $cache:findData[$cache:index].Selected.($prop.Name) = $source
                                                                                Update-JVPage -Sort
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                New-UDGrid -Item -ExtraSmallSize 10 -SmallSize 10 -Content {
                                                                    switch ($prop.Name) {
                                                                        'screenshoturl' { New-UDTextbox -Id "textbox-sourceview-$($prop.Value)" -FullWidth -Label $prop.Name -Value ($prop.Value -join ' \ ') -Disabled }
                                                                        'tag' { New-UDTextbox -Id "textbox-sourceview-$($prop.Value)" -FullWidth -Label $prop.Name -Value ($prop.Value -join ' \ ') -Disabled }
                                                                        'genre' { New-UDTextbox -Id "textbox-sourceview-$($prop.Value)" -FullWidth -Label $prop.Name -Value ($prop.Value -join ' \ ') -Disabled }
                                                                        'rating' { New-UDTextbox -Id "textbox-sourceview-$($prop.Value)" -FullWidth -Label $prop.Name -Value ($prop.Value | ConvertTo-Json) -Disabled }
                                                                        'actress' { New-UDTextbox -Id "textbox-sourceview-$($prop.Value)" -FullWidth -Label $prop.Name -Value ($prop.Value | ConvertTo-Json) -Disabled }
                                                                        default { New-UDTextbox -Id "textbox-sourceview-$($prop.Value)" -FullWidth -Label $prop.Name -Value $prop.Value -Disabled }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                } -Style @{
                                                    'border-radius'  = '20px'
                                                    'text-transform' = 'lowercase'
                                                }
                                            }
                                        } else {
                                            New-UDButton -Text $source -Style @{
                                                'border-radius'  = '20px'
                                                'text-transform' = 'lowercase'
                                            } -Disabled
                                        }
                                    }
                                }
                            }
                        }
                    }

                    New-UDStyle -Style '
                        .MuiCardContent-root:last-child {
                            padding-bottom: 10px;
                        }

                        .MuiCardContent-root {
                            padding: 0px;
                        }

                        .MuiCardHeader-root {
                            display: table-column;
                        }' -Content {
                        New-UDCard -Title 'Actors' -Content {
                            New-UDGrid -Container -Content {
                                $actressIndex = 0
                                foreach ($actress in $cache:findData[$cache:index].Data.Actress) {
                                    New-UDGrid -ExtraSmallSize 4 -MediumSize 4 -LargeSize 3 -ExtraLargeSize 2 -Content {
                                        New-UDPaper -Elevation 0 -Content {
                                            New-UDGrid -Container -Content {
                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                    New-UDTooltip -TooltipContent { 'Edit this actor' } -Content {
                                                        New-UDButton -Icon $iconEdit -FullWidth -Size small -OnClick {
                                                            Show-UDModal -FullWidth -MaxWidth sm -Content {
                                                                New-UDCard -Title 'Edit Actor' -TitleAlignment center -Content {
                                                                    New-UDGrid -Container -Content {
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                            New-UDTextbox -Id "textbox-sort-actorlastname-$cache:index-$actressIndex" -Label 'LastName' -Value $actress.LastName -FullWidth
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                            New-UDTextbox -Id "textbox-sort-actorfirstname-$cache:index-$actressIndex" -Label 'FirstName' -Value $actress.FirstName -FullWidth
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                            New-UDTextbox -Id "textbox-sort-actorjapanese-$cache:index-$actressIndex" -Label 'JapaneseName' -Value $actress.JapaneseName -FullWidth
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                            New-UDTextbox -Id "textbox-sort-actorthumburl-$cache:index-$actressIndex" -Label 'ThumbUrl' -Value $actress.ThumbUrl -FullWidth
                                                                        }
                                                                    }
                                                                }
                                                                New-UDCard -Title 'Select Existing' -TitleAlignment center -Content {
                                                                    New-UDGrid -Container -Content {
                                                                        New-UDGrid -Item -ExtraSmallSize 9 -SmallSize 9 -Content {
                                                                            New-UDAutocomplete -Id 'autocomplete-sort-actorselect' -Options $cache:actressArray -OnChange {
                                                                                $actressObjectIndex = ((Get-UDElement -Id 'autocomplete-sort-actorselect').value | Select-String -Pattern '\[(\d*)\]').Matches.Groups[1].Value
                                                                                Set-UDElement -Id "textbox-sort-actorlastname-$cache:index-$actressIndex" -Properties @{
                                                                                    value = $cache:actressObject[$actressObjectIndex].LastName
                                                                                }
                                                                                Set-UDElement -Id "textbox-sort-actorfirstname-$cache:index-$actressIndex" -Properties @{
                                                                                    value = $cache:actressObject[$actressObjectIndex].FirstName
                                                                                }
                                                                                Set-UDElement -Id "textbox-sort-actorjapanese-$cache:index-$actressIndex" -Properties @{
                                                                                    value = $cache:actressObject[$actressObjectIndex].JapaneseName
                                                                                }
                                                                                Set-UDElement -Id "textbox-sort-actorthumburl-$cache:index-$actressIndex" -Properties @{
                                                                                    value = $cache:actressObject[$actressObjectIndex].ThumbUrl
                                                                                }
                                                                                Sync-UDElement -Id 'dynamic-sort-editactorimg'
                                                                            }
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -Content {
                                                                            New-UDDynamic -Id 'dynamic-sort-editactorimg' -Content {
                                                                                New-UDImage -Url (Get-UDElement -Id "textbox-sort-actorthumburl-$cache:index-$actressIndex").value -Height 130
                                                                            } -AutoRefresh -AutoRefreshInterval 2
                                                                        }
                                                                    }
                                                                }
                                                            } -Footer {
                                                                New-UDButton -Id 'updateActressBtn' -Text 'Ok' -FullWidth -OnClick {
                                                                    Set-UDElement -Id 'updateActressBtn' -Properties @{
                                                                        Disabled = $true
                                                                    }

                                                                    if ((Get-UDElement -Id "textbox-sort-actorlastname-$cache:index-$actressIndex").value -eq '') {
                                                                        $lastName = $null
                                                                    } else {
                                                                        $lastName = (Get-UDElement -Id "textbox-sort-actorlastname-$cache:index-$actressIndex").value
                                                                    }

                                                                    if ((Get-UDElement -Id "textbox-sort-actorfirstname-$cache:index-$actressIndex").value -eq '') {
                                                                        $firstName = $null
                                                                    } else {
                                                                        $firstName = (Get-UDElement -Id "textbox-sort-actorfirstname-$cache:index-$actressIndex").value
                                                                    }

                                                                    if ((Get-UDElement -Id "textbox-sort-actorjapanese-$cache:index-$actressIndex").value -eq '') {
                                                                        $japaneseName = $null
                                                                    } else {
                                                                        $japaneseName = (Get-UDElement -Id "textbox-sort-actorjapanese-$cache:index-$actressIndex").value
                                                                    }

                                                                    if ((Get-UDElement -Id "textbox-sort-actorthumburl-$cache:index-$actressIndex").value -eq '') {
                                                                        $thumbUrl = $null
                                                                    } else {
                                                                        $thumbUrl = (Get-UDElement -Id "textbox-sort-actorthumburl-$cache:index-$actressIndex").value
                                                                    }

                                                                    $updatedActress = [PSCustomObject]@{
                                                                        LastName     = $lastName
                                                                        FirstName    = $firstName
                                                                        JapaneseName = $japaneseName
                                                                        ThumbUrl     = $thumbUrl
                                                                    }

                                                                    ((($cache:findData)[$cache:index]).Data.Actress)[$actressIndex] = $updatedActress
                                                                    Update-JVPage -Sort
                                                                    Hide-UDModal
                                                                }
                                                                New-UDButton -Text 'Remove' -FullWidth -OnClick {
                                                                    $origJapaneseName = ((Get-UDElement -Id "textbox-sort-origactorjapanesename-$cache:index-$actressIndex").value)
                                                                    (($cache:findData)[$cache:index]).Data.Actress = (($cache:findData)[$cache:index]).Data.Actress | Where-Object { $_.JapaneseName -ne $origJapaneseName }

                                                                    if (($cache:findData[$cache:index].Data.Actress).Count -eq 1) {
                                                                        # We need to reset the single actor as an array or we won't be able to add
                                                                        $tempActress = @()
                                                                        $tempActress += ($cache:findData[$cache:index].Data.Actress)
                                                                        $cache:findData[$cache:index].Data.Actress = $tempActress
                                                                    }

                                                                    if (($cache:findData[$cache:index].Data.Actress).Count -eq 0) {
                                                                        $cache:findData[$cache:index].Data.Actress = $null
                                                                    }
                                                                    Hide-UDModal
                                                                    Update-JVPage -Sort
                                                                }
                                                                New-UDButton -Text 'Cancel' -FullWidth -OnClick {
                                                                    Update-JVPage -Sort
                                                                    Hide-UDModal
                                                                }
                                                            }
                                                        }
                                                    } -Place top -Type dark -Effect solid
                                                }
                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                    New-UDStyle -Style '
                                                    .MuiInputBase-input {
                                                        text-align-last: center;
                                                    }' -Content {
                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                            New-UDTextbox -Id "textbox-sort-origactorname-$cache:index-$actressIndex" -Value ("$($actress.LastName) $($actress.FirstName)").Trim() -Disabled
                                                        }

                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                            New-UDTextbox -Id "textbox-sort-origactorjapanesename-$cache:index-$actressIndex" -Value $actress.JapaneseName -Disabled
                                                        }
                                                    }

                                                }
                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                    New-UDStyle -Style '
                                                        element.style {
                                                            text-align: center;
                                                        }

                                                        img {
                                                            width: 100%;
                                                            height: auto;
                                                            max-height: 160px;
                                                            max-width: 160px;
                                                            display: block;
                                                            margin-left: auto;
                                                            margin-right: auto;
                                                        }' -Content {
                                                        New-UDImage -Url $actress.ThumbUrl -Height 125
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    $actressIndex++
                                }

                                New-UDGrid -ExtraSmallSize 4 -MediumSize 4 -LargeSize 3 -ExtraLargeSize 2 -Content {
                                    New-UDPaper -Elevation 0 -Content {
                                        New-UDGrid -Container -Content {
                                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                New-UDTooltip -TooltipContent { 'Add a new actor' } -Content {
                                                    New-UDButton -Icon $iconEdit -FullWidth -Size small -OnClick {
                                                        Show-UDModal -FullWidth -MaxWidth sm -Content {
                                                            New-UDCard -Title 'Add Actor' -TitleAlignment center -Content {
                                                                New-UDGrid -Container -Content {
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "newtextbox-sort-actorlastname" -Label 'LastName' -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "newtextbox-sort-actorfirstname" -Label 'FirstName' -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "newtextbox-sort-actorjapanese" -Label 'JapaneseName' -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "newtextbox-sort-actorthumburl" -Label 'ThumbUrl' -FullWidth
                                                                    }
                                                                }
                                                            }
                                                            New-UDCard -Title 'Select Existing' -TitleAlignment center -Content {
                                                                New-UDGrid -Container -Content {
                                                                    New-UDGrid -Item -ExtraSmallSize 9 -SmallSize 9 -Content {
                                                                        New-UDAutocomplete -Id 'autocomplete-sort-actorselect' -Options $cache:actressArray -OnChange {
                                                                            $actressObjectIndex = ((Get-UDElement -Id 'autocomplete-sort-actorselect').value | Select-String -Pattern '\[(\d*)\]').Matches.Groups[1].Value
                                                                            Set-UDElement -Id "newtextbox-sort-actorlastname" -Properties @{
                                                                                value = $cache:actressObject[$actressObjectIndex].LastName
                                                                            }
                                                                            Set-UDElement -Id "newtextbox-sort-actorfirstname" -Properties @{
                                                                                value = $cache:actressObject[$actressObjectIndex].FirstName
                                                                            }
                                                                            Set-UDElement -Id "newtextbox-sort-actorjapanese" -Properties @{
                                                                                value = $cache:actressObject[$actressObjectIndex].JapaneseName
                                                                            }
                                                                            Set-UDElement -Id "newtextbox-sort-actorthumburl" -Properties @{
                                                                                value = $cache:actressObject[$actressObjectIndex].ThumbUrl
                                                                            }
                                                                            Sync-UDElement 'dynamic-sort-addactorimage'
                                                                        }
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -Content {
                                                                        New-UDDynamic -Id 'dynamic-sort-addactorimage' -Content {
                                                                            New-UDImage -Url (Get-UDElement -Id "newtextbox-sort-actorthumburl").value -Height 130
                                                                        } -AutoRefresh -AutoRefreshInterval 2
                                                                    }
                                                                }
                                                            }
                                                        } -Footer {
                                                            New-UDButton -Id 'addActressBtn' -Text 'Ok' -FullWidth -OnClick {
                                                                Set-UDElement -Id 'addActressBtn' -Properties @{
                                                                    Disabled = $true
                                                                }

                                                                if ((Get-UDElement -Id "newtextbox-sort-actorlastname").value -eq '') {
                                                                    $lastName = $null
                                                                } else {
                                                                    $lastName = (Get-UDElement -Id "newtextbox-sort-actorlastname").value
                                                                }

                                                                if ((Get-UDElement -Id "newtextbox-sort-actorfirstname").value -eq '') {
                                                                    $firstName = $null
                                                                } else {
                                                                    $firstName = (Get-UDElement -Id "newtextbox-sort-actorfirstname").value
                                                                }

                                                                if ((Get-UDElement -Id "newtextbox-sort-actorjapanese").value -eq '') {
                                                                    $japaneseName = $null
                                                                } else {
                                                                    $japaneseName = (Get-UDElement -Id "newtextbox-sort-actorjapanese").value
                                                                }

                                                                if ((Get-UDElement -Id "newtextbox-sort-actorthumburl").value -eq '') {
                                                                    $thumbUrl = $null
                                                                } else {
                                                                    $thumbUrl = (Get-UDElement -Id "newtextbox-sort-actorthumburl").value
                                                                }

                                                                $newActress = [PSCustomObject]@{
                                                                    LastName     = $lastName
                                                                    FirstName    = $firstName
                                                                    JapaneseName = $japaneseName
                                                                    ThumbUrl     = $thumbUrl
                                                                }

                                                                if ($null -eq $cache:findData[$cache:index].Data.Actress) {
                                                                    $cache:findData[$cache:index].Data.Actress = @()
                                                                }
                                                                ($cache:findData[$cache:index].Data.Actress) += $newActress

                                                                Update-JVPage -Sort
                                                                Hide-UDModal

                                                            }
                                                            New-UDButton -Text 'Cancel' -FullWidth -OnClick {
                                                                Update-JVPage -Sort
                                                                Hide-UDModal
                                                            }
                                                        }
                                                    }
                                                } -Place top -Type dark -Effect solid
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    <# New-UDButton -Text 'Debug' -OnClick {
        Show-UDModal -Content {
            New-UDCard -Content {
                $scraperOutput = $cache:originalFindData[$cache:index].AllData | ConvertTo-Json -Depth 32
                New-UDCodeEditor -Height '100ch' -Width '100ch' -Code $scraperOutput
            }
            New-UDCard -Content {
                $code = $cache:findData | ConvertTo-Json -Depth 32
                New-UDCodeEditor -Height '150ch' -Width '100ch' -Code $code

                $code2 = $cache:originalFindData | ConvertTo-Json -Depth 32
                New-UDCodeEditor -Height '150ch' -Width '100ch' -Code $code2
            }
        }
    } #>
}

$Pages += New-UDPage -Name 'Emby' -Content {
    New-JVAppBar
    New-UDScrollUp
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDTypography -Text "If you use Emby or Jellyfin, you will need to use its API to POST actor images into your server. To use this feature of Javinizer, first define 'emby.baseurl' and 'emby.apikey' on the settings page.
            For better control over starting/stopping this process, I recommend using the `Javinizer -SetEmbyThumbs` from the CLI."
            New-UDPaper -Content {
                New-UDButton -Text 'View Server Actors' -OnClick {
                    if (!($cache:inProgressEmby)) {
                        $cache:inProgressEmby = $true
                        try {
                            Show-JVToast -Type Info -Message 'Attempting to retrieve actors from Emby/Jellyfin, please wait'
                            $cache:embyData = Get-EmbyActors -Url $cache:settings.'emby.url' -ApiKey $cache:settings.'emby.apikey'
                        } catch {
                            Show-JVToast -Type Error -Message "Check that your URL and ApiKey are valid: $PSItem"
                            $cache:inProgressEmby = $false
                        }

                        Update-JVPage -Emby
                        $cache:inProgressEmby = $false
                    } else {
                        Show-JVToast -Type Error -Message 'A job is currently running, please wait'
                    }
                }

                New-UDButton -Text 'Set Missing Thumbs' -OnClick {
                    if (!($cache:inProgressEmby)) {
                        $cache:inProgressEmby = $true
                        try {
                            Get-EmbyActors -Url $cache:settings.'emby.url' -ApiKey $cache:settings.'emby.apikey'
                        } catch {
                            Show-JVToast -Type Error -Message "Check that your URL and ApiKey are valid: $PSItem"
                            $cache:inProgressEmby = $false
                            return
                        }

                        try {
                            Show-JVToast -Type Info -Message "Setting Emby/Jellyfin actor thumbs -- the job will run in the background"
                            Javinizer -SetEmbyThumbs
                            $cache:inProgressEmby = $false
                            Show-JVToast -Type Success -Message "Completed setting Emby/Jellyfin thumbs -- view log for details"
                        } catch {
                            Show-JVToast -Type Error -Message "$PSItem"
                            $cache:inProgressEmby = $false
                            return
                        }
                    } else {
                        Show-JVToast -Type Error -Message 'A job is currently running, please wait'
                    }
                }

                New-UDButton -Text 'Replace All Thumbs' -OnClick {
                    if (!($cache:inProgressEmby)) {
                        $cache:inProgressEmby = $true
                        try {
                            Get-EmbyActors -Url $cache:settings.'emby.url' -ApiKey $cache:settings.'emby.apikey'
                        } catch {
                            Show-JVToast -Type Error -Message "Check that your URL and ApiKey are valid: $PSItem"
                            $cache:inProgressEmby = $false
                            return
                        }

                        try {
                            Show-JVToast -Type Info -Message "Setting Emby/Jellyfin actor thumbs -- the job will run in the background"
                            Javinizer -SetEmbyThumbs -ReplaceAll
                            $cache:inProgressEmby = $false
                            Show-JVToast -Type Success -Message "Completed setting Emby/Jellyfin thumbs -- view log for details"
                        } catch {
                            Show-JVToast -Type Error -Message "$PSItem"
                            $cache:inProgressEmby = $false
                            return
                        }
                    } else {
                        Show-JVToast -Type Error -Message 'A job is currently running, please wait'
                    }
                }
                New-UDDynamic -Id 'dynamic-emby-inprogress' -Content {
                    if ($cache:inProgressEmby) {
                        New-UDProgress -Circular
                    }
                } -AutoRefresh -AutoRefreshInterval 5
            }
        }

        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDDynamic -Id 'dynamic-emby-actortable' -Content {
                New-UDTable -Title $cache:settings.'emby.url' -Data $cache:embyData -Sort -Filter -Search -ShowPagination
            }
            New-UDPaper -Content {
                New-UDDynamic -Id 'dynamic-emby-actorlog' -Content {
                    $embyActorLog = (Get-Content -LiteralPath $cache:logPath | Where-Object { $_ -like '*set-jvembythumbs*' } | ConvertTo-Reverse) -join "`r`n"
                    New-UDCodeEditor -Width '155ch' -Height '50ch' -Theme vs-dark -Code $embyActorLog -ReadOnly
                } -AutoRefresh -AutoRefreshInterval 5
            }
        }
    }
}

$Pages += New-UDPage -Name "Settings" -Content {
    New-JVAppBar
    New-UDScrollUp

    New-UDDynamic -Id 'dynamic-settings-page' -Content {
        New-UDGrid -Container -Content {
            ## Left Column
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                New-UDCard -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 4 -Content {
                            New-UDButton -Icon $iconCheck -Text 'Apply' -Size large -FullWidth -OnClick {
                                if (!($cache:inProgress)) {
                                    Show-JVProgressModal -Generic -NoCancel
                                    $cache:inProgress = $true
                                    foreach ($scraper in $scraperSettings) {
                                        $cache:settings."scraper.movie.$scraper" = (Get-UDElement -Id "checkbox-settings-$scraper").checked
                                    }
                                    foreach ($field in $prioritySettings) {
                                        $cache:settings."sort.metadata.priority.$field" = ((Get-UDElement -Id "textbox-settings-$field").value -split '\\').Trim()
                                    }
                                    foreach ($setting in $locationSettings) {
                                        $cache:settings."location.$setting" = ((Get-UDElement -Id "textbox-settings-location-$setting")).value
                                    }

                                    foreach ($setting in $sortSettings) {
                                        $cache:settings."$setting" = (Get-UDElement -Id $setting).checked
                                    }

                                    foreach ($setting in $embySettings) {
                                        $cache:settings."$setting" = (Get-UDElement -Id $setting).value
                                    }
                                    foreach ($setting in $formatStringSettings) {
                                        if ($setting -eq 'sort.format.posterimg' -or $setting -eq 'sort.metadata.nfo.format.tag' -or $setting -eq 'sort.format.outputfolder') {
                                            $cache:settings."$setting" = ((Get-UDElement -Id "$setting").value -split '\\').Trim()
                                        } else {
                                            $cache:settings."$setting" = (Get-UDElement -Id "$setting").value
                                        }
                                    }
                                    $cache:settings.'throttlelimit' = [Int](Get-UDElement -Id 'autocomplete-settings-throttlelimit').value
                                    $cache:settings.'sort.metadata.requiredfield' = ((Get-UDElement -Id 'textbox-settings-requiredfields').value -split '\\').Trim()
                                    $cache:settings.'scraper.option.idpreference' = (Get-UDElement -Id 'autocomplete-settings-idpreference').value
                                    $cache:settings.'scraper.option.dmm.scrapeactress' = (Get-UDElement -Id 'checkbox-settings-scrapeactress').checked
                                    $cache:settings.'scraper.option.addmaleactors' = (Get-UDElement -Id 'checkbox-settings-addmaleactors').checked
                                    $cache:settings.'match.minimumfilesize' = [Int](Get-UDElement -Id 'textbox-settings-minfilesize').value
                                    $cache:settings.'match.regex' = (Get-UDElement -Id 'checkbox-settings-regexmatch').checked
                                    $cache:settings.'match.regex.string' = (Get-UDElement -Id 'textbox-settings-regexmatchstring').value
                                    $cache:settings.'match.regex.idmatch' = (Get-UDElement -Id 'textbox-settings-regexidmatch').value
                                    $cache:settings.'match.regex.ptmatch' = (Get-UDElement -Id 'textbox-settings-regexptmatch').value
                                    $cache:settings.'sort.maxtitlelength' = [Int](Get-UDElement -Id 'autocomplete-settings-maxtitlelength').value
                                    $cache:settings.'sort.metadata.nfo.translate' = (Get-UDElement -Id 'checkbox-settings-translate').checked
                                    $cache:settings.'sort.metadata.nfo.translate.language' = (Get-UDElement -Id 'autocomplete-settings-translatelanguage').value
                                    $cache:settings.'sort.metadata.nfo.translate.module' = (Get-UDElement -Id 'autocomplete-settings-translatemodule').value
                                    $cache:settings.'sort.metadata.nfo.translate.field' = ((Get-UDElement -Id 'textbox-settings-translatefield').value -split '\\').Trim()
                                    $cache:settings.'sort.metadata.nfo.translate.keeporiginaldescription' = (Get-UDElement -Id 'checkbox-settings-translate-originaldescription').checked
                                    $cache:settings.'admin.log' = (Get-UDElement -Id 'checkbox-settings-adminlog').checked
                                    $cache:settings.'admin.log.level' = (Get-UDElement -Id 'autocomplete-settings-adminloglevel').value
                                    $cache:settings.'web.theme' = (Get-UDElement -Id 'autocomplete-settings-theme').value
                                    $cache:settings | ConvertTo-Json | Out-File $cache:settingsPath
                                    $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json

                                    # Require these settings to be edited in the json due to regex formatting
                                    #$cache:settings.'match.includedfileextension' = ((Get-UDElement -Id 'textbox-settings-includedfileext').value -split '\\')
                                    #$cache:settings.'match.excludedfilestring' = ((Get-UDElement -Id 'textbox-settings-excludedfilestr').value -split '\\')

                                    if (Test-Path -LiteralPath ($cache:settings.'location.log')) {
                                        $cache:logPath = $cache:settings.'location.log'
                                    } elseif (($cache:settings.'location.log') -ne '') {
                                        try {
                                            Copy-Item -Path $cache:defaultLogPath -Destination $cache:settings.'location.log'
                                            $cache:logPath = $cache:settings.'location.log'
                                            Show-JVToast -Type Info -Message "Created missing log path: [$($cache:settings.'location.log')]"
                                        } catch {
                                            Show-JVToast -Type Error -Message "Error setting log location: $PSItem"
                                            return
                                        }
                                    } else {
                                        $cache:logPath = $cache:defaultLogPath
                                    }

                                    if (Test-Path -LiteralPath ($cache:settings.'location.historycsv')) {
                                        $cache:historyCsvPath = $cache:settings.'location.historycsv'
                                    } elseif (($cache:settings.'location.historycsv') -ne '') {
                                        try {
                                            Copy-Item -Path $cache:defaultHistoryPath -Destination $cache:settings.'location.historycsv'
                                            $cache:historyCsvPath = $cache:settings.'location.historycsv'
                                            Show-JVToast -Type Info -Message "Created missing historycsv path: [$($cache:settings.'location.historycsv')]"
                                        } catch {
                                            Show-JVToast -Type Error -Message "Error setting history location: $PSItem"
                                            return
                                        }
                                    } else {
                                        $cache:historyCsvPath = $cache:defaultHistoryPath
                                    }

                                    if (Test-Path -LiteralPath $cache:settings.'location.thumbcsv') {
                                        $cache:thumbCsvPath = $cache:settings.'location.thumbcsv'
                                    } elseif (($cache:settings.'location.thumbcsv') -ne '') {
                                        try {
                                            Copy-Item -Path $cache:defaultThumbPath -Destination $cache:settings.'locationthumbcsv'
                                            $cache:thumbCsvPath = $cache:settings.'location.thumbcsv'
                                            Show-JVToast -Type Info -Message "Created missing thumbcsv path: [$($cache:settings.'location.thumbcsv')]"
                                        } catch {
                                            Show-JVToast -Type Error -Message "Error setting thumb location: $PSItem"
                                            return
                                        }
                                    } else {
                                        $cache:thumbCsvPath = $cache:defaultThumbPath
                                    }

                                    if (Test-Path -LiteralPath $cache:settings.'location.genrecsv') {
                                        $cache:genreCsvPath = $cache:settings.'location.genrecsv'
                                    } elseif (($cache:settings.'location.genrecsv') -ne '') {
                                        try {
                                            Copy-Item -Path $cache:defaultGenrePath -Destination $cache:settings.'location.genrecsv'
                                            $cache:thumbCsvPath = $cache:settings.'location.genrecsv'
                                            Show-JVToast -Type Info -Message "Created missing genrecsv path: [$($cache:settings.'location.genrecsv')]"
                                        } catch {
                                            Show-JVToast -Type Error -Message "Error setting thumb location: $PSItem"
                                            return
                                        }
                                    } else {
                                        $cache:genreCsvPath = $cache:defaultGenrePath
                                    }

                                    if (Test-Path -LiteralPath $cache:settings.'location.tagcsv') {
                                        $cache:tagCsvPath = $cache:settings.'location.tagcsv'
                                    } elseif (($cache:settings.'location.tagcsv') -ne '') {
                                        try {
                                            Copy-Item -Path $cache:defaultTagPath -Destination $cache:settings.'location.tagcsv'
                                            $cache:thumbCsvPath = $cache:settings.'location.tagcsv'
                                            Show-JVToast -Type Info -Message "Created missing tagcsv path: [$($cache:settings.'location.tagcsv')]"
                                        } catch {
                                            Show-JVToast -Type Error -Message "Error setting thumb location: $PSItem"
                                            return
                                        }
                                    } else {
                                        $cache:tagCsvPath = $cache:defaultTagPath
                                    }

                                    if (Test-Path -LiteralPath $cache:settings.'location.uncensorcsv') {
                                        $cache:uncensorCsvPath = $cache:settings.'location.uncensorcsv'
                                    } elseif (($cache:settings.'location.uncensorcsv') -ne '') {
                                        try {
                                            Copy-Item -Path $cache:defaultUncensorPath -Destination $cache:settings.'location.uncensorcsv'
                                            $cache:thumbCsvPath = $cache:settings.'location.uncensorcsv'
                                            Show-JVToast -Type Info -Message "Created missing uncensorcsv path: [$($cache:settings.'location.uncensorcsv')]"
                                        } catch {
                                            Show-JVToast -Type Error -Message "Error setting thumb location: $PSItem"
                                            return
                                        }
                                    } else {
                                        $cache:uncensorCsvPath = $cache:defaultUncensorPath
                                    }

                                    Update-JVPage -Settings
                                    Show-JVProgressModal -Off
                                    Show-JVToast -Type Success -Message "Settings updated"
                                    $cache:inProgress = $false
                                }
                            }
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 4 -Content {
                            New-UDButton -Icon $iconEdit -Text 'Json' -Size large -FullWidth -OnClick {
                                Show-UDModal -FullScreen -Content {
                                    $settingsContent = (Get-Content -LiteralPath $cache:settingsPath) -join "`r`n"
                                    New-UDCodeEditor -Id 'editor-settings-json' -Autosize -Language json -Theme vs-dark -Code $settingsContent
                                } -Header {
                                    "jvSettings.json"
                                } -Footer {
                                    New-UDButton -Text 'Ok' -OnClick {
                                        try {
                                            # Validate that the settings json format before writing
                                            (Get-UDElement -Id 'editor-settings-json').code | ConvertFrom-Json
                                            (Get-UDElement -Id 'editor-settings-json').code | Out-File $cache:settingsPath -Force
                                            Show-JVToast -Type Success -Message "Settings updated"
                                            $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
                                            Update-JVPage -Settings
                                            Hide-UDModal
                                        } catch {
                                            Show-JVToast -Type Error -Message "Error occurred when saving settings: $PSItem"
                                        }
                                    }
                                    New-UDButton -Text "Cancel" -OnClick {
                                        Update-JVPage -Settings
                                        Hide-UDModal
                                    }
                                }
                            }
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 4 -Content {
                            New-UDButton -Icon $iconUndo -Text 'Reload' -Size large -FullWidth -OnClick {
                                if (!($cache:inProgress)) {
                                    Show-JVProgressModal -Generic -NoCancel
                                    $cache:inProgress = $true
                                    if (Test-Path -LiteralPath ($cache:settings.'location.log')) {
                                        $cache:logPath = $cache:settings.'location.log'
                                    } else {
                                        $cache:logPath = $cache:defaultLogPath
                                    }
                                    if (Test-Path -LiteralPath ($cache:settings.'location.historycsv')) {
                                        $cache:historyCsvPath = $cache:settings.'location.historycsv'
                                    } else {
                                        $cache:historyCsvPath = $cache:defaultHistorypath
                                    }
                                    if (Test-Path -LiteralPath $cache:settings.'location.thumbcsv') {
                                        $cache:thumbCsvPath = $cache:settings.'location.thumbcsv'
                                    } else {
                                        $cache:thumbCsvPath = $cache:defaultThumbPath
                                    }

                                    if (Test-Path -LiteralPath $cache:settings.'location.genrecsv') {
                                        $cache:genreCsvPath = $cache:settings.'location.genrecsv'
                                    } else {
                                        $cache:genreCsvPath = $cache:defaultGenrePath
                                    }

                                    if (Test-Path -LiteralPath $cache:settings.'location.tagcsv') {
                                        $cache:tagCsvPath = $cache:settings.'location.tagcsv'
                                    } else {
                                        $cache:tagCsvPath = $cache:defaultTagPath
                                    }

                                    if (Test-Path -LiteralPath $cache:settings.'location.uncensorcsv') {
                                        $cache:uncensorCsvPath = $cache:settings.'location.uncensorcsv'
                                    } else {
                                        $cache:uncensorCsvPath = $cache:defaultUncensorPath
                                    }

                                    $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
                                    $cache:actressObject = Import-Csv $cache:thumbCsvPath | Sort-Object FullName
                                    $cache:actressArray += $cache:actressObject | ForEach-Object { "$($_.FullName) ($($_.JapaneseName)) [$actressIndex]"; $actressIndex++ }
                                    Update-JVPage -Settings
                                    Show-JVProgressModal -Off
                                    $cache:inProgress = $false
                                }
                            }
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                            New-UDButton -Text 'View Javinizer docs' -Variant text -FullWidth -OnClick {
                                Invoke-UDRedirect -OpenInNewWindow -Url 'https://docs.jvlflame.net'
                            }
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                            New-UDButton -Text 'View default settings' -Variant text -FullWidth -OnClick {
                                Invoke-UDRedirect -OpenInNewWindow -Url 'https://github.com/jvlflame/Javinizer/blob/master/src/Javinizer/jvSettings.json'
                            }
                        }
                    }
                }

                ## Scrapers card
                New-UDCard -Title 'Scrapers' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Container -Content {
                            foreach ($scraper in $scraperSettings) {
                                $scraperTooltip = switch ($scraper) {
                                    'AVEntertainment' { 'English AVEntertainment scraper' }
                                    'AVEntertainmentJa' { 'Japanese AVEntertainment scraper' }
                                    'Dmm' { 'English Dmm scraper' }
                                    'DmmJa' { 'Japanese Dmm scraper' }
                                    'Jav321Ja' { 'Japanese Jav321 scraper' }
                                    'Javdb' { 'English JavDB scraper' }
                                    'JavdbZh' { 'Chinese JavDB scraper' }
                                    'Javbus' { 'English Javbus scraper' }
                                    'JavbusJa' { 'Japanese Javbus scraper' }
                                    'JavbusZh' { 'Chinese Javbus scraper' }
                                    'Javlibrary' { 'English Javlibrary scraper' }
                                    'JavlibraryJa' { 'Japanese Javlibrary scraper' }
                                    'JavlibraryZh' { 'Chinese Javlibrary scraper' }
                                    'MgStageJa' { 'Japanese Mgstage scraper' }
                                    'R18' { 'English R18 scraper' }
                                    'R18Zh' { 'Chinese R18 scraper' }
                                    'TokyoHot' { 'English TokyoHot scraper' }
                                    'TokyoHotJa' { 'Japanese TokyoHot scraper' }
                                    'TokyoHotZh' { 'Chinese TokyoHot scraper' }
                                    default { $null }
                                }

                                New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                    if ($scraperTooltip) {
                                        New-UDTooltip -TooltipContent { $scraperTooltip } -Content {
                                            New-UDCheckBox -Label $scraper -Id "checkbox-settings-$scraper" -LabelPlacement end -Checked ($cache:settings."scraper.movie.$scraper")
                                        } -Place right -Type dark -Effect float
                                    } else {
                                        New-UDCheckBox -Label $scraper -Id "checkbox-settings-$scraper" -LabelPlacement end -Checked ($cache:settings."scraper.movie.$scraper")
                                    }
                                }
                            }
                        }

                        New-UDCard -Title 'Options' -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { 'Specifies the maximum limit Javinizer will run sorting threads' } -Content {
                                        New-UDAutocomplete -Id 'autocomplete-settings-throttlelimit' -Label ThrottleLimit -Options @('1', '2', '3', '4', '5', '6', '7', '8', '9', '10') -Value $cache:settings.'throttlelimit' -OnChange {
                                            if ($null -eq (Get-UDElement -Id 'autocomplete-settings-throttlelimit').value) {
                                                Set-UDElement -Id 'autocomplete-settings-throttlelimit' -Properties @{
                                                    value = '3'
                                                }
                                            }
                                        }
                                    } -Place right -Effect float -Type dark

                                    New-UDTooltip -TooltipContent { 'Specifies which ID type to prefer (ID = ID-123, ContentID = ID00123)' } -Content {
                                        New-UDAutocomplete -Id 'autocomplete-settings-idpreference' -Label 'ID Preference' -Options @('id', 'contentid') -Value $cache:settings.'scraper.option.idpreference' -OnChange {
                                            if ($null -eq (Get-UDElement -Id 'autocomplete-settings-idpreference').value) {
                                                Set-UDElement -Id 'autocomplete-settings-idpreference' -Properties @{
                                                    value = 'id'
                                                }
                                            }
                                        }
                                    } -Place right -Effect float -Type dark
                                }

                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDTooltip -TooltipContent { 'Leave this off in 99% of cases, this should only be used if you want dmm to be your primary actress scraper' } -Content {
                                        New-UDCheckBox -Label 'scraper.option.dmm.scrapeactress' -Id 'checkbox-settings-scrapeactress' -LabelPlacement end -Checked ($cache:settings.'scraper.option.dmm.scrapeactress')
                                    } -Place right -Effect float -Type dark

                                    New-UDTooltip -TooltipContent { 'Specifies whether to turn on/off scraping for avdanyuwiki to populate the nfo with male actors' } -Content {
                                        New-UDCheckBox -Label 'scraper.option.addmaleactors' -Id 'checkbox-settings-addmaleactors' -LabelPlacement end -Checked ($cache:settings.'scraper.option.addmaleactors')
                                    } -Place right -Effect float -Type dark
                                }
                            }
                        }
                    }
                }

                ## Scraper priorities card
                New-UDCard -Title "Metadata Priorities" -Content {
                    New-UDGrid -Container -Content {
                        ## Field priorities
                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                            New-UDGrid -Container -Content {
                                foreach ($field in $prioritySettings) {
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTextbox -Label $field -Id "textbox-settings-$field" -Value ($cache:settings."sort.metadata.priority.$field" -join ' \ ') -FullWidth
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Label 'Required Fields' -Id 'textbox-settings-requiredfields' -Value ($cache:settings."sort.metadata.requiredfield" -join ' \ ') -FullWidth
                                }
                            }
                        }
                    }
                }

                New-UDCard -Title 'File Matcher' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTooltip -TooltipContent { 'Specifies the minimum filesize that Javinizer will find when performing a directory search in MB' } -Place right -Effect solid -Type dark -Content {
                                        New-UDTextbox -Label 'match.minimumfilesize (MB)' -Id 'textbox-settings-minfilesize' -Value ([string]$cache:settings.'match.minimumfilesize') -FullWidth
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Label 'match.includedfileextension (Edit in JSON)' -Id 'textbox-settings-includedfileext' -Value ($cache:settings.'match.includedfileextension' -join ' \ ') -FullWidth -Disabled
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Label 'match.excludedfilestring (Edit in JSON)' -Id 'textbox-settings-excludedfilestr' -Value ($cache:settings.'match.excludedfilestring' -join ' \ ') -FullWidth -Disabled
                                }
                            }
                            New-UDCard -Title 'Regex' -Content {
                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTooltip -TooltipContent { 'Specifies that Javinizer will perform the directory search using regex rather than the default matcher.' } -Content {
                                            New-UDCheckBox -Label 'match.regex' -Id 'checkbox-settings-regexmatch' -Checked ($cache:settings.'match.regex')
                                        }  -Place right -Type dark -Effect float
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTextbox -Label 'match.regex.string (Edit in JSON)' -Id 'textbox-settings-regexmatchstring' -Value ($cache:settings.'match.regex.string') -FullWidth -Disabled
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTooltip -TooltipContent { 'Specifies the regex match of the movies ID of the regex string' } -Place right -Effect solid -Type dark -Content {
                                            New-UDTextbox -Label 'match.regex.idmatch' -Id 'textbox-settings-regexidmatch' -Value ($cache:settings.'match.regex.idmatch') -FullWidth
                                        }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTooltip -TooltipContent { 'Specifies the regex match of the movies part number of the regex string' } -Place right -Effect solid -Type dark -Content {
                                            New-UDTextbox -Label 'match.regex.ptmatch' -Id 'textbox-settings-regexptmatch' -Value ($cache:settings.'match.regex.ptmatch') -FullWidth
                                        }
                                    }
                                }
                            }

                            New-UDCard -Title 'Preview' -Content {
                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 10 -SmallSize 10 -Content {
                                        New-UDTextbox -Id 'textbox-settings-preview' 'Enter a directory or filepath' -FullWidth
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 2 -SmallSize 2 -Content {
                                        New-UDButton -Text 'Preview' -Variant outlined -OnClick {
                                            $recurse = (Get-UDElement -Id 'checkbox-sort-recurse').checked
                                            $depth = (Get-UDElement -Id 'select-sort-recursedepth').value
                                            $strict = (Get-UDElement -Id 'checkbox-sort-strict').checked

                                            $previewPath = (Get-UDElement -Id 'textbox-settings-preview').value
                                            if ($depth -gt 1 -and $recurse) {
                                                $previewOutput = Javinizer -Path $previewPath -Recurse:$recurse -Depth:$depth -Strict:$strict -Preview
                                            } else {
                                                $previewOutput = Javinizer -Path $previewPath -Recurse:$recurse -Strict:$strict -Preview
                                            }

                                            $previewOutput = $previewOutput | Select-Object Id, ContentId, FileName, Extension, Length, PartNumber, Directory | Format-Table -Wrap | Out-String
                                            Show-UDModal -FullWidth -MaxWidth md -Content {
                                                New-UDCodeEditor -Id 'dynamic-sort-aggregateddataeditor' -Language shell -Width '117ch' -Height '85ch' -Theme vs-dark -ReadOnly -DisableLineNumbers -Code $previewOutput
                                            }
                                        }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                        New-UDTooltip -TooltipContent { 'Performs a recursive sort on the specified directory (searches within folders)' } -Content {
                                            New-UDCheckBox -Id 'checkbox-sort-recurse' -Label 'Recurse' -LabelPlacement end -Checked $cache:settings.'web.sort.recurse' -OnChange {
                                                $cache:settings.'web.sort.recurse' = (Get-UDElement -Id 'checkbox-sort-recurse').checked
                                                Update-JVSettings
                                            }
                                        } -Place right -Effect float -Type dark
                                        New-UDTooltip -TooltipContent { 'Forces the filematcher to use the exact filename as the movie ID' } -Content {
                                            New-UDCheckBox -Id 'checkbox-sort-strict' -Label 'Strict' -LabelPlacement end -Checked $cache:settings.'web.sort.strict' -OnChange {
                                                $cache:settings.'web.sort.strict' = (Get-UDElement -Id 'checkbox-sort-strict').checked
                                                Update-JVSettings
                                            }
                                        } -Place right -Effect float -Type dark
                                        New-UDTooltip -TooltipContent { 'Specifies the recurse depth of the filematcher search (Set to 0 to disable custom depth)' } -Content {
                                            New-UDSelect -Id 'select-sort-recursedepth' -Label 'Recurse Depth' -DefaultValue $cache:settings.'web.sort.recursedepth' -Option {
                                                0..10 | ForEach-Object { New-UDSelectOption -Name "$_" -Value $_ }
                                            } -OnChange {
                                                [int]$cache:settings.'web.sort.recursedepth' = (Get-UDElement -Id 'select-sort-recursedepth').value
                                                Update-JVSettings
                                            }
                                        } -Place right -Effect float -Type dark
                                    }
                                }
                            }
                        }
                    }
                }
                New-UDCard -Title 'Admin' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -SmallSize 4 -Content {
                            New-UDCheckBox -Id 'checkbox-settings-adminlog' -Label 'admin.log' -LabelPlacement end -Checked ($cache:settings.'admin.log')
                            New-UDTypography -Variant 'body1' -Text 'admin.log.level'

                            New-UDAutocomplete -Id 'autocomplete-settings-adminloglevel' -Options @('debug', 'info', 'warning', 'error') -Value ($cache:settings.'admin.log.level') -OnChange {
                                if ($null -eq (Get-UDElement -Id 'autocomplete-settings-adminloglevel').value) {
                                    Set-UDElement -Id 'autocomplete-settings-adminloglevel' -Properties @{
                                        value = 'info'
                                    }
                                }
                            }
                        }
                        New-UDGrid -Item -SmallSize 8 -Content {
                            # Empty grid
                        }
                        New-UDGrid -Item -SmallSize 4 -Content {
                            New-UDTypography -Variant 'body1' -Text 'Default theme'
                            New-UDAutocomplete -Id 'autocomplete-settings-theme' -Options @('light', 'dark') -Value ($cache:settings.'web.theme') -OnChange {
                                if ($null -eq (Get-UDElement -Id 'autocomplete-settings-theme').value) {
                                    Set-UDElement -Id 'autocomplete-settings-theme' -Properties @{
                                        value = 'light'
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ## Right column
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                New-UDCard -Title 'Locations & Persistent Settings Files' -Content {
                    New-UDGrid -Container -Content {
                        foreach ($setting in $locationSettings) {
                            $locationToolTip = switch ($setting) {
                                'input' { 'Specifies the default -Path that Javinizer will use to sort videos' }
                                'output' { 'Specifies the default -DestinationPath that Javinizer will use to sort videos' }
                                'thumbcsv' { 'Specifies a custom location of the actress thumbnail csv that is used to better match actresses' }
                                'genrecsv' { 'Specifies a custom location of the genre replacement csv that is used to do a string replacement of genres of your choice' }
                                'uncensorcsv' { 'Specifies a custom location of the uncensor csv that is used to do string replacements of censored words in R18 metadata' }
                                'historycsv' { 'Specifies a custom location of the history csv that is used as database of your metadata scrapes' }
                                'tagcsv' { 'Specifies a custom location of the tag csv that is used to do string replacements of tags of your choice' }
                                'log' { 'Specifies a custom location of the log file. This will point to the file within the Javinizer module folder by default.' }
                            }
                            New-UDGrid -Item -ExtraSmallSize 10 -SmallSize 10 -MediumSize 4 -Content {
                                New-UDTooltip -TooltipContent { $locationToolTip } -Place left -Type dark -Effect float -Content {
                                    New-UDTextbox -Label "location.$setting" -Id "textbox-settings-location-$setting" -Value ($cache:settings."location.$setting") -FullWidth
                                }
                            }
                            New-UDGrid -Item -ExtraLargeSize 2 -SmallSize 2 -MediumSize 2 -Content {
                                if ($setting -ne 'input' -and $setting -ne 'output') {
                                    New-UDButton -Text 'Edit' -Variant outlined -OnClick {
                                        Show-UDModal -FullWidth -MaxWidth lg -Persistent -Content {
                                            $cache:locationPath = $cache:settings."location.$setting"
                                            if ($null -ne $cache:locationPath -or $cache:locationPath -ne '') {
                                                $cache:locationPath = switch ($setting) {
                                                    'thumbcsv' { $cache:thumbCsvPath }
                                                    'genrecsv' { $cache:genreCsvPath }
                                                    'uncensorcsv' { $cache:uncensorCsvPath }
                                                    'historycsv' { $cache:historyCsvPath }
                                                    'tagcsv' { $cache:tagCsvPath }
                                                    'log' { $cache:logPath}
                                                }
                                            }

                                            New-UDTypography -Variant h6 -Text "Path: $cache:locationPath"

                                            $cache:locationContent = Get-Content -Path $cache:locationPath -Raw
                                            New-UDCodeEditor -Id 'dynamic-settings-editor' -Width '158ch' -Height '100ch' -Theme vs-dark -Code $cache:locationContent
                                        } -Footer {
                                            New-UDButton -Text 'Ok' -OnClick {
                                                $newData = (Get-UDElement -Id 'dynamic-settings-editor').code

                                                try {
                                                    $newData | Out-File -LiteralPath $cache:locationPath
                                                    Show-JVToast -Type Success -Message "File saved"
                                                } catch {
                                                    Show-JVToast -Type Error -Message "$PSItem"
                                                    return
                                                }

                                                Update-JVPage -Sort
                                                Hide-UDModal
                                            }
                                            New-UDButton -Text 'Reset' -OnClick {
                                                Set-UDElement -Id 'dynamic-settings-editor' -Properties @{
                                                    code = $cache:locationContent
                                                }
                                            }

                                            New-UDButton -Text "Cancel" -OnClick {
                                                Hide-UDModal
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ## Metadata options card
                New-UDCard -Title 'Sort' -Content {
                    New-UDGrid -Container -Content {
                        foreach ($setting in $sortSettings) {
                            $sortTooltip = switch ($setting) {
                                'sort.movetofolder' { 'Specifies to move the movie to its own folder after being sorted' }
                                'sort.renamefile' { 'Specifies to rename the movie file after being sorted' }
                                'sort.movesubtitles' { 'Specifies to automatically move subtitle files with the movie file after being sorted' }
                                'sort.create.nfo' { 'Specifies to create the nfo file when sorting a movie' }
                                'sort.create.nfoperfile' { 'Specifies to create a nfo file for every movie file, this will force the nfo to be renamed using the filename' }
                                'sort.download.actressimg' { 'Specifies to download actress images when sorting a movie' }
                                'sort.download.thumbimg' { 'Specifies to download the thumbnail image when sorting a movie' }
                                'sort.download.posterimg' { 'Specifies to create the poster image when sorting a movie. Sort.download.thumbimg is required for this to function' }
                                'sort.download.screenshotimg' { 'Specifies to download screenshot images when sorting a movie' }
                                'sort.download.trailervid' { 'Specifies to download the trailer video when sorting a movie' }
                                'sort.format.groupactress' { 'Specifies to convert the format string for <ACTORS> when there is more than one actress to "@Group" and if unknown, to "@Unknown"' }
                                'sort.metadata.nfo.mediainfo' { 'Specifies to add media metadata information to the nfo file, this requires the MediaInfo command line application' }
                                'sort.metadata.nfo.altnamerole' { 'Specifies to set the actress role in the nfo as the altname' }
                                'sort.metadata.nfo.addgenericrole' { 'Specifies to set the actress role in the nfo as Actress' }
                                'sort.metadata.nfo.firstnameorder' { 'Specifies to set the actress name order to FirstName LastName' }
                                'sort.metadata.nfo.actresslanguageja' { 'Specifies to prefer Japanese names when creating the metadata nfo' }
                                'sort.metadata.nfo.unknownactress' { 'Specifies to add an "Unknown" actress to sorted movies without any actresses' }
                                'sort.metadata.nfo.actressastag' { 'Specifies to add actresses as tags in the nfo file' }
                                'sort.metadata.nfo.preferactressalias' { 'Specifies to prefer the oldest actress alias to normalize your metadata' }
                                'sort.metadata.nfo.originalpath' { 'Specifies to add an "originalpath" field to the nfo specifying the location the movie was last sorted from' }
                                'sort.metadata.thumbcsv' { 'Specifies to use the thumbnail csv to replace actor names and thumbs when aggregating metadata' }
                                'sort.metadata.thumbcsv.autoadd' { 'Specifies to automatically add missing actor to the thumbnail csv when scraping using the R18 or R18Zh scrapers' }
                                'sort.metadata.thumbcsv.convertalias' { 'Specifies to use the thumbnail csv alias field to replace actresses in the metadata' }
                                'sort.metadata.genrecsv' { 'Specifies to use the genre csv to replace genres in the metadata' }
                                'sort.metadata.genrecsv.autoadd' { 'Specifies to automatically add missing genres to the genre csv' }
                                'sort.metadata.tagcsv' { 'Specifies to use the tag csv to replace tags in the metadata' }
                                'sort.metadata.tagcsv.autoadd' { 'Specifies to automatically add missing tags to the tag csv' }
                                default { $null }
                            }

                            if ($sortTooltip) {
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTooltip -Type dark -Place right -Effect float -TooltipContent { "$sortTooltip" } -Content {
                                        New-UDCheckBox -Label $setting -Id "$setting" -LabelPlacement end -Checked ($cache:settings."$setting")
                                    }
                                }
                            } else {
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDCheckBox -Label $setting -Id "$setting" -LabelPlacement end -Checked ($cache:settings."$setting")
                                }
                            }
                        }
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                $lengthOptions = @()
                                $lengthChoices = 1..500
                                $lengthChoices | ForEach-Object { $lengthOptions += [String]$_ }
                                New-UDTooltip -TooltipContent { 'Specifies the max metadata title length when using it in a format string' } -Place left -Type dark -Effect solid -Content {
                                    New-UDAutocomplete -Id 'autocomplete-settings-maxtitlelength' -Label 'sort.maxtitlelength' -Value ($cache:settings.'sort.maxtitlelength') -Options $lengthOptions -OnChange {
                                        if ($null -eq (Get-UDElement -Id 'autocomplete-settings-maxtitlelength').value) {
                                            Set-UDElement -Id 'autocomplete-settings-maxtitlelength' -Properties @{
                                                value = '100'
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                New-UDCard -Title 'Translate' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                            New-UDTooltip -TooltipContent { 'Specifies to enable the machine translation service.' } -Content {
                                New-UDCheckBox -Label 'sort.metadata.nfo.translate' -Id 'checkbox-settings-translate' -LabelPlacement end -Checked ($cache:settings.'sort.metadata.nfo.translate')
                            } -Place right -Type dark -Effect float
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                            New-UDTextbox -Label 'sort.metadata.nfo.translate.field' -Id 'textbox-settings-translatefield' -Value ($cache:settings.'sort.metadata.nfo.translate.field' -join ' \ ') -FullWidth
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                            New-UDTooltip -TooltipContent { 'Specifies to append the original Japanese description to the nfo file when translating the description.' } -Content {
                                New-UDCheckBox -Label 'sort.metadata.nfo.translate.keeporiginaldescription' -Id 'checkbox-settings-translate-originaldescription' -LabelPlacement end -Checked ($cache:settings.'sort.metadata.nfo.translate.keeporiginaldescription')
                            }  -Place right -Type dark -Effect float
                        }
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                            New-UDAutocomplete -Id 'autocomplete-settings-translatelanguage' -Label 'Translate Language' -Options $translateLanguages -Value ($cache:settings.'sort.metadata.nfo.translate.language') -OnChange {
                                if ($null -eq (Get-UDElement -Id 'autocomplete-settings-translatelanguage').value) {
                                    Set-UDElement -Id 'autocomplete-settings-translatelanguage' -Properties @{
                                        value = 'en'
                                    }
                                }
                            }
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                            New-UDTypography -Text 'DeepL translator requires you to have a developer API key. You can set it via the JSON settings editor.'
                            New-UDAutocomplete -Id 'autocomplete-settings-translatemodule' -Label 'Translate Module' -Options @('googletrans', 'google_trans_new', 'deepl') -Value ($cache:settings.'sort.metadata.nfo.translate.module') -OnChange {
                                if ($null -eq (Get-UDElement -Id 'autocomplete-settings-translatemodule').value) {
                                    Set-UDElement -Id 'autocomplete-settings-translatemodule' -Properties @{
                                        value = 'googletrans'
                                    }
                                }
                            }
                        }
                    }
                }

                New-UDCard -Title 'Format Strings' -Content {
                    New-UDGrid -Container -Content {
                        New-UDTypography -Text 'Available tags are: <ID>
                        <CONTENTID>
                        <DIRECTOR>
                        <TITLE>
                        <RELEASEDATE>
                        <YEAR>
                        <STUDIO>
                        <RUNTIME>
                        <SET>
                        <LABEL>
                        <ACTORS>
                        <ORIGINALTITLE>
                        <FILENAME>
                        <RESOLUTION>'
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                            New-UDGrid -Container -Content {
                                foreach ($setting in $formatStringSettings) {
                                    $formatStringTooltip = switch ($setting) {
                                        'sort.format.delimiter' { 'Specifies the delimiter between actresses when using <ACTORS> in the format string' }
                                        'sort.format.file' { 'Specifies the format string when renaming a file' }
                                        'sort.format.folder' { 'Specifies the format string when creating the folder' }
                                        'sort.format.outputfolder' { 'Specifies an array of format strings when creating an output folder in the destination path. Leaving this blank will omit creating the output folder. Multiple format strings will create a nested output structure' }
                                        'sort.format.posterimg' { 'Specifies an array of format strings when creating the poster image. Multiple strings will allow you to create multiple poster image files' }
                                        'sort.format.thumbimg' { 'Specifies the format string when creating the thumbnail image' }
                                        'sort.format.trailervid' { 'Specifies the format string when creating the trailer video' }
                                        'sort.format.nfo' { 'Specifies the format string when creating the nfo' }
                                        'sort.format.screenshotimg' { 'Specifies the format string when creating the screenshot images' }
                                        'sort.format.screenshotfolder' { 'Specifies the format string when creating the screenshot images folder' }
                                        'sort.format.actressimgfolder' { 'Specifies the format string when creating the actress image folder' }
                                        'sort.metadata.nfo.displayname' { 'Specifies the format string of the displayname in the metadata nfo file' }
                                        'sort.metadata.nfo.format.tag' { 'Specifies an array of format strings to add tags to the aggregated data object' }
                                        'sort.metadata.nfo.format.tagline' { 'Specifies the format string to add a tagline to the aggregated data object' }
                                        'sort.metadata.nfo.format.credits' { 'Specifies an array of format string to add credits to the aggregated data object' }
                                        default { $null }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTooltip -TooltipContent { $formatStringTooltip } -Type dark -Effect solid -Place left -Content {
                                            if ($setting -eq 'sort.format.posterimg' -or $setting -eq 'sort.metadata.nfo.format.tag' -or $setting -eq 'sort.format.outputfolder') {
                                                New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting" -join ' \ ') -FullWidth
                                            } else {
                                                New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        # ! TODO
                        <# New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                New-UDButton -Text 'Preview Output' -OnClick {
                                    Show-UDModal -FullWidth -MaxWidth xl -Content {
                                        New-UDTypography -Variant 'h6' -Text 'Enter a full path to a movie file'
                                        New-UDTextbox -Id 'textbox-settings-previewfile' -Label 'Movie Path'
                                        $data = Javinizer -Find ($cache:settings | Get-JVItem (Get-UDElement -Id 'textbox-settings-previewfile').value) -Javlibrary -R18 -DmmJa -Aggregated
                                        Get-JVSortData
                                    } -Footer {
                                        New-UDButton 'Close' -OnClick {
                                            Hide-UDModal
                                        }
                                    }
                                }
                            } #>
                    }
                }
                New-UDCard -Title 'Emby/Jellyfin' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                            New-UDGrid -Container -Content {
                                foreach ($setting in $embySettings) {
                                    $embyToolTip = switch ($setting) {
                                        'emby.url' { 'Specifies the base URL of your Emby/Jellyfin instance to add actress images. Do not add the trailing slash at the end of the url' }
                                        'emby.apikey' { 'Specifies the API key of your Emby/Jellyfin instance. This will be used to POST actor images to your Emby/Jellyfin instance' }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTooltip -TooltipContent { $embyToolTip } -Place left -Type dark -Effect solid -Content {
                                            New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                New-UDCard -Title 'Javlibrary/Javdb (Edit in JSON)' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                            New-UDGrid -Container -Content {
                                foreach ($setting in $javlibrarySettings) {
                                    $javToolTip = switch ($setting) {
                                        'javlibrary.baseurl' { 'Specifies the base URL of the Javlibrary instance you want to scrape such as b49t.com' }
                                        'javlibrary.browser.useragent' { 'Specifies your browsers user agent when accessing Javlibrary. This can be found by googling your user agent' }
                                        'javlibrary.cookie.cf_chl_2' { 'Specifies the cookie value of the cf_chl_2 cookie when accessing Javlibrary' }
                                        'javlibrary.cookie.cf_chl_prog' { 'Specifies the cookie value of the cf_chl_prog cookie when accessing Javlibrary' }
                                        'javlibrary.cookie.cf_clearance' { 'Specifies the cookie value of the cf_clearance cookie when accessing Javlibrary' }
                                        'javlibrary.cookie.session' { 'Specifies the cookie value of the session cookie when logged into Javlibrary, used to set owned movies' }
                                        'javlibrary.cookie.userid' { 'Specifies the cookie value of the userid cookie when logged into Javlibrary, used to set owned movies' }
                                        'javdb.cookie.session' { 'Specifies the _jdb_session login cookie for javdb to access and scrape fc2 titles' }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTooltip -TooltipContent { $javToolTip } -Place left -Type dark -Effect solid -Content {
                                            New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth -Disabled
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

$Pages += New-UDPage -Name 'Stats' -Content {
    New-JVAppBar
    New-UDScrollUp
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDPaper -Content {
                New-UDButton -Icon $iconUndo -Text 'Reload' -OnClick {
                    if (Test-Path -LiteralPath ($cache:settings.'location.historycsv')) {
                        $cache:historyCsvPath = $cache:settings.'location.historycsv'
                    } else {
                        $cache:historyCsvPath = $cache:defaultHistorypath
                    }
                    Sync-UDElement -Id 'dynamic-history-sorttable'
                }
                New-UDButton -Icon $iconTrash -Text 'Clear' -OnClick {
                    Show-UDModal -FullWidth -MaxWidth sm -Content {
                        New-UDTypography -Variant h6 -Text "WARNING: Are you sure you want to clear your history? This action can not be undone."
                    } -Footer {
                        New-UDButton -Text 'Ok' -OnClick {
                            try {
                                Clear-Content -LiteralPath $cache:historyCsvPath -Force
                                Sync-UDElement -Id 'dynamic-history-sorttable'
                            } catch {
                                Show-JVToast -Type Error -Message "$PSItem"
                            }
                            Hide-UDModal
                        }
                        New-UDButton -Text 'Cancel' -OnClick {
                            Hide-UDModal
                        }
                    }
                }
                New-UDSelect -Id 'select-stats-chartdatacount' -DefaultValue '15' -Label 'Data Count' -Option {
                    $options = @('5', '10', '15', '20', '25', '50', '100')
                    foreach ($option in $options) {
                        New-UDSelectOption -Value $option -Name $option
                    }
                } -OnChange {
                    [int]$cache:chartDataCount = (Get-UDElement -Id 'select-stats-chartdatacount').value
                    Sync-UDElement -Id 'dynamic-history-sorttable'
                }
            }
        }
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDDynamic -Id 'dynamic-history-sorttable' -Content {
                try {
                    # We want to parse for unique titles by ID/Maker so we don't get duplicate data
                    $cache:sortHistory = Import-Csv -LiteralPath $cache:historyCsvPath -Encoding utf8 | Group-Object Id, Maker | ForEach-Object {
                        $_.Group | Select-Object -First 1 | Sort-Object Id, Maker
                    }
                } catch {
                    Show-JVToast -Type Error -Message "$PSItem"
                }

                New-UDGrid -Container -Content {
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title 'Sorted by Day' -Content {
                            $data = ($cache:sortHistory | Select-Object @{Name = 'Timestamp'; Expression = { (Get-Date $_.Timestamp -Format 'yyyy-MM-dd') } } | Group-Object -Property Timestamp)
                            $sortDateOptions = @{
                                Type            = 'line'
                                Data            = $data
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @sortDateOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title 'Movies by Release Date' -Content {
                            $data = ($cache:sortHistory | Select-Object @{Name = 'ReleaseDate'; Expression = { (Get-Date $_.ReleaseDate -Format 'yyyy') } } | Group-Object -Property ReleaseDate)
                            $sortDateOptions = @{
                                Type            = 'bar'
                                Data            = $data
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @sortDateOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title "Top $($cache:chartDataCount) Studios" -Content {
                            $data = ($cache:sortHistory.Maker | Group-Object | Sort-Object -Top $cache:chartDataCount -Descending | Where-Object { $_.Name -ne '' })
                            $makerOptions = @{
                                Type            = 'bar'
                                Data            = $data
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @makerOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title "Top $($cache:chartDataCount) Genres" -Content {
                            $data = (($cache:sortHistory.Genre | ConvertFrom-Json) | Group-Object | Sort-Object -Top $cache:chartDataCount -Descending | Where-Object { $_.Name -ne '' })
                            $genreOptions = @{
                                Type            = 'radar'
                                Data            = $data
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @genreOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title "Top $($cache:chartDataCount) Actors" -Content {
                            $actress = foreach ($actor in ($cache:sortHistory.Actress | ConvertFrom-Json)) {
                                "$($actor.LastName) $($actor.FirstName)".Trim()
                                if ($null -eq $name -or $name -eq '') {
                                    $actor.JapaneseName
                                }
                            }

                            $data = ($actress | Group-Object | Sort-Object -Top $cache:chartDataCount -Descending | Where-Object { $_ -ne '' })
                            $actressOptions = @{
                                Type            = 'radar'
                                Data            = $data
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @actressOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title "Top $($cache:chartDataCount) Directors" -Content {
                            $data = ($cache:sortHistory.Director | Group-Object | Sort-Object -Top $($cache:chartDataCount) -Descending | Where-Object { $_.Name -ne '' })
                            $actressOptions = @{
                                Type            = 'radar'
                                Data            = $data
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @actressOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                        $historyCsvColumns = @(
                            'Timestamp',
                            'Path',
                            'DestinationPath'
                            'Id',
                            'ContentId',
                            'DisplayName',
                            'Title',
                            'AlternateTitle',
                            'Description',
                            'Rating',
                            'Votes',
                            'ReleaseDate',
                            'Maker',
                            'Label',
                            'Runtime',
                            'Director',
                            'Actress',
                            'Genre',
                            'Series',
                            'Tag',
                            'Tagline',
                            'Credits',
                            'CoverUrl',
                            'ScreenshotUrl',
                            'TrailerUrl',
                            'MediaInfo'
                        )

                        $historyTableColumns = @(
                            foreach ($column in $historyCsvColumns) {
                                $filterType = switch ($column) {
                                    default { 'text' }
                                }
                                New-UDTableColumn -Title $column -IncludeInSearch -ShowSort -ShowFilter -IncludeInExport -FilterType $filterType -Property $column
                            }
                        )

                        New-UDStyle -Style '
                        .MuiCardContent-root {
                            padding: 4px;
                            padding-bottom: 8px;
                        }
                        .MuiTableCell-root {
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap;
                            max-width: 200px;
                        }
                        .MuiTableCell-root:hover {
                            overflow: visible;
                            white-space: normal;
                            height: auto;
                            max-width: 200px;
                        }' -Content {
                            New-UDTable -Title $cache:historyCsvPath -Data $cache:sortHistory -Columns $historyTableColumns -Search -ShowPagination -ShowSort -ShowFilter -ShowExport -StickyHeader
                        }
                    }
                }
            }
        }
    }
}

$Pages += New-UDPage -Name 'Console' -Content {
    New-JVAppBar
    New-UDScrollUp
    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
        New-UDCard -Title 'Console' -Content {
            New-UDGrid -Container -Content {
                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                    New-UDTextbox -Id 'textbox-admin-console' -Label 'Enter a command' -FullWidth -Multiline -Autofocus
                }
                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                    New-UDButton -Text 'Run' -FullWidth -OnClick {
                        Show-JVProgressModal -Generic
                        $command = (Get-UDElement -Id 'textbox-admin-console').value
                        try {
                            $output = Invoke-JVParallel -InputObject $command -IsWeb -Quiet:$true -ScriptBlock {
                                try {
                                    Invoke-Expression $_ | Out-String
                                } catch {
                                    Write-Output $PSItem
                                }
                            }
                        } catch {
                            $output = "$PSItem"
                        } finally {
                            Set-UDElement -Id 'editor-admin-consoleoutput' -Properties @{
                                code = [String]$output
                            }
                            Show-JVProgressModal -Off
                        }
                    }
                }
            }
        }

        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDCard -Title 'Console Output' -Content {
                New-UDGrid -Item -Content {
                    New-UDCodeEditor -Language 'powershell' -Width '155ch' -Height '50ch' -Id 'editor-admin-consoleoutput' -ReadOnly -Theme vs-dark
                }
            }
        }

        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDCard -Title $cache:logPath -Content {
                New-UDGrid -Item -Content {
                    New-UDButton -Icon $iconUndo -Text 'Reload' -OnClick {
                        if (Test-Path -LiteralPath ($cache:settings.'location.log')) {
                            $cache:logPath = $cache:settings.'location.log'
                        } else {
                            $cache:logPath = $cache:defaultLogPath
                        }
                        Sync-UDElement -Id 'dynamic-admin-log'
                    }
                    New-UDButton -Icon $iconTrash -Text 'Clear' -OnClick {
                        Show-UDModal -FullWidth -MaxWidth sm -Content {
                            New-UDTypography -Variant h6 -Text "WARNING: Are you sure you want to clear log? This action can not be undone."
                        } -Footer {
                            New-UDButton -Text 'Ok' -OnClick {
                                try {
                                    Clear-Content -LiteralPath $cache:logPath -Force
                                    Sync-UDElement -Id 'dynamic-admin-log'
                                } catch {
                                    Show-JVToast -Type Error -Message "$PSItem"
                                }
                                Hide-UDModal
                            }
                            New-UDButton -Text 'Cancel' -OnClick {
                                Hide-UDModal
                            }
                        }
                    }

                    New-UDDynamic -Id 'dynamic-admin-log' -Content {
                        New-UDGrid -Container -Content {
                            $rawLog = (Get-Content -LiteralPath $cache:logPath)
                            $fullLog = $rawLog -join "`n"
                            New-UDCodeEditor -Id 'editor-admin-log' -Language 'powershell' -Width '155ch' -Height '50ch' -Theme vs-dark -ReadOnly -Code $fullLog
                        }
                    }
                }
            }
        }
    }
}

$Pages += New-UDPage -Name 'About' -Content {
    New-JVAppBar
    New-UDScrollUp
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDCard -Title 'About Javinizer' -Content {
                New-UDGrid -Container -Content {
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                        New-UDButton -Text 'Check for Updates' -OnClick {
                            Update-JVModule -CheckUpdates -IsWeb -GuiVersion $cache:guiVersion
                        }
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                        New-UDList -Content {
                            New-UDListItem -Label $cache:javinizerInfo.Version -SubTitle 'Module Version'
                            New-UDListItem -Label $cache:guiVersion -SubTitle 'GUI Version'
                            New-UDListItem -Label $cache:javinizerInfo.Prerelease -SubTitle 'Prerelease'
                            New-UDListItem -Label $cache:javinizerInfo.Project -SubTitle 'Project' -OnClick {
                                Invoke-UDRedirect -OpenInNewWindow -Url 'https://github.com/jvlflame/Javinizer'
                            }
                            New-UDListItem -Label $cache:javinizerInfo.License -SubTitle 'License' -OnClick {
                                Invoke-UDRedirect -OpenInNewWindow -Url 'https://github.com/jvlflame/Javinizer/blob/master/LICENSE'
                            }
                            New-UDListItem -Label $cache:javinizerInfo.ReleaseNotes -SubTitle 'ReleaseNotes' -OnClick {
                                Invoke-UDRedirect -OpenInNewWindow -Url 'https://github.com/jvlflame/Javinizer/blob/master/.github/CHANGELOG.md'
                            }
                        }
                    }
                }
            }
        }

        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDCard -Title 'ChangeLog' -Content {
                $changeLog = (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/jvlflame/Javinizer/master/.github/CHANGELOG.md' -MaximumRetryCount 3 -RetryIntervalSec 3).Content
                New-UDCodeEditor -ReadOnly -Theme vs-dark -Width '155ch' -Height '100ch' -Language markdown -Code $changeLog
            }
        }
    }
}

$cache:defaultTheme = 'light'
New-UDDashboard -Title "Javinizer Web" -Theme $Theme -Pages $Pages -DefaultTheme $cache:settings.'web.theme'
