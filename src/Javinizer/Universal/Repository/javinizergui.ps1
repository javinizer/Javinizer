# Define Javinizer module file paths
#$cache:modulePath = (Get-InstalledModule -Name Javinizer).InstalledLocation
$cache:modulePath = 'X:\git\Projects\JAV-Organizer\src\Javinizer'
#$cache:fullModulePath = Join-Path -Path $cache:modulePath -ChildPath 'Javinizer.psm1'
$cache:fullModulePath = 'X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1'
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

# Set other Javinizer dashboard defaults
$cache:inProgress = $false
$cache:inProgressEmby = $false
$cache:findData = @()
$cache:originalFindData = @()
$cache:filePath = ''
$cache:index = 0
$cache:currentIndex = 0
$actressIndex = 0
$cache:tablePageSize = 5
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

# Set Universal Dashboard configs
$Pages = @()
$cache:defaultTheme = 'dark'
$Theme = @{
    light = @{
        spacing = 4
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
        spacing   = 4
        shape     = @{
            borderRadius = 5
        }
        palette   = @{
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
        overrides = @{
            checkbox = @{
                checkedColor = "#4caf50"
                labelColor   = "#ffffff"
                boxColor     = "#ffffff"
            }
        }
    }
}
function Update-JVPage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Sort,

        [Parameter()]
        [switch]$Settings,

        [Parameter()]
        [switch]$Emby,

        [Parameter()]
        [switch]$ClearData,

        [Parameter()]
        [switch]$ClearProgress
    )
    if ($ClearData) {
        $cache:findData = @()
        $cache:originalFindData = @()
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
            $cache:findData = @()
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
                        New-UDTypography -Variant h6 -Text "Max Threads: $($cache:Settings.'throttlelimit')" -Align center
                        New-UDCard -Content {
                            New-UDList -Content {
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
                        # The runspace that we want to close is created from Invoke-JVParallel
                        $cache:runspacepool.Close()
                        Show-JVProgressModal -Off

                        # Need to wait before reassigning findData after the runspace is closed otherwise it will stay as null
                        Start-Sleep -Seconds 1
                        #$cache:findData = @()
                        #$cache:originalFindData = @()
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

        New-UDTextbox -Id 'textbox-javlibrary-cfduid' -Label '__cfduid' -FullWidth
        New-UDTextbox -Id 'textbox-javlibrary-cfclearance' -Label 'cf_clearance' -FullWidth
        New-UDTextbox -Id 'textbox-javlibrary-useragent' -Label 'user-agent' -FullWidth

    } -Header {
        New-UDTypography -Text 'Enter JAVLibrary Cloudflare Cookies'
    } -Footer {
        New-UDButton -Text 'Ok' -OnClick {

            try {
                $Cfduid = (Get-UDElement -Id 'textbox-javlibrary-cfduid').value
                $Cfclearance = (Get-UDElement -Id 'textbox-javlibrary-cfclearance').value
                $UserAgent = (Get-UDElement -Id 'textbox-javlibrary-useragent').value
                $cache:cfSession = Get-CfSession -Cfduid $cfduid -Cfclearance $cfclearance -UserAgent $useragent -BaseUrl $cache:settings.'javlibrary.baseurl'
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
                    $cookies = $cache:cfSession.Cookies.GetCookies($cache:settings.'javlibrary.baseurl')
                    $cfduid = ($cookies | Where-Object { $_.Name -eq '__cfduid' }).Value
                    $cfclearance = ($cookies | Where-Object { $_.Name -eq 'cf_clearance' }).Value
                    $userAgent = $cache:cfSession.UserAgent
                    $settingsContent = $OriginalSettingsContent
                    $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cfduid": ".*"', "`"javlibrary.cookie.cfduid`": `"$cfduid`""
                    $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cfclearance": ".*"', "`"javlibrary.cookie.cfclearance`": `"$cfclearance`""
                    $settingsContent = $settingsContent -replace '"javlibrary\.browser\.useragent": ".*"', "`"javlibrary.browser.useragent`": `"$userAgent`""
                    $origJson = $originalSettingsContent | ConvertFrom-Json
                    $newJson = $settingsContent | ConvertFrom-Json

                    if (($origJson.'javlibrary.browser.useragent' -ne $newJson.'javlibrary.browser.useragent') -or ($origJson.'javlibrary.cookie.cfduid' -ne $newJson.'javlibrary.cookie.cfduid') -or ($origJson.'javlibrary.cookie.cfclearance' -ne $newJson.'javlibrary.cookie.cfclearance')) {
                        $settingsContent | Out-File -FilePath $cache:SettingsPath
                        Show-JVToast -Type Success -Message "Replaced Javlibrary settings with updated values in [$cache:SettingsPath]"

                    }
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
            Show-UDToast -CloseOnClick -Message $Message -Title 'Info' -Duration 5000 -Position bottomRight
        }

        'Error' {
            Show-UDToast -CloseOnClick -Message $Message -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
        }

        'Success' {
            Show-UDToast -CloseOnClick -Message $Message -Title 'Success' -TitleColor green -Duration 5000 -Position bottomRight
        }
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
        [Switch]$Strict = (Get-UDElement -Id 'checkbox-sort-strict').checked,

        [Parameter()]
        [Switch]$Update = (Get-UDElement -Id 'checkbox-sort-update').checked,

        [Parameter()]
        [Switch]$Interactive = (Get-UDElement -Id 'checkbox-sort-interactive').checked,

        [Parameter()]
        [Switch]$Force = (Get-UDElement -Id 'checkbox-sort-force').checked
    )

    if (!($cache:inProgress)) {
        # Check if javlibrary cloudflare protection is enabled
        if ($cache:settings.'scraper.movie.javlibrary' -or $cache:settings.'scraper.movie.javlibraryja' -or $cache:settings.'scraper.movie.javlibraryzh') {
            if (-not ($cache:cfSession)) {
                try {
                    Invoke-WebRequest -Uri $Settings.'javlibrary.baseurl' -Verbose:$false | Out-Null
                } catch {
                    try {
                        # Test with persisted settings
                        $cache:cfSession = Get-CfSession -Cfduid:$cache:settings.'javlibrary.cookie.cfduid' -Cfclearance:$cache:settings.'javlibrary.cookie.cfclearance' `
                            -UserAgent:$cache:settings.'javlibrary.browser.useragent' -BaseUrl $cache:settings.'javlibrary.baseurl'

                        # Testing with the newly created session sometimes fails if there is no wait time
                        Start-Sleep -Seconds 1
                        Invoke-WebRequest -Uri $cache:settings.'javlibrary.baseurl' -WebSession $cache:cfSession -UserAgent $cache:cfSession.UserAgent -Verbose:$false | Out-Null
                    } catch {
                        # Display the JAVLibrary cloudflare modal due to webrequest error
                        Show-JVCfModal
                        return
                    }
                }
            } else {
                try {
                    Invoke-WebRequest -Uri $cache:settings.'javlibrary.baseurl' -WebSession $cache:cfSession -UserAgent $cache:cfSession.UserAgent -Verbose:$false | Out-Null
                } catch {
                    # Display the JAVLibrary cloudflare modal due to webrequest error
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
                $cache:searchTotal = ($cache:settings | Get-JVItem -Path $Item.FullName -Recurse:$recurse -Strict:$strict).Count
                $jvData = Javinizer -Path $Item.FullName -Recurse:$recurse -Strict:$strict -HideProgress -IsWeb -IsWebType 'Search'
                if ($null -ne $jvData) {
                    $cache:findData = ($jvData | Sort-Object { $_.Data.Id })
                } else {
                    Show-JVToast -Type Error -Message 'No movies matched'
                }
            } else {
                $movieId = ($cache:settings | Get-JVItem -Path $Item.FullName).Id
                Set-UDElement -Id 'textbox-sort-manualsearch' -Properties @{
                    value = $movieId
                }
                $jvData = Javinizer -Path $Item.FullName -Strict:$strict -HideProgress -IsWeb -IsWebType 'Search'
                if ($null -ne $jvData) {
                    $cache:findData = $jvData
                } else {
                    Show-JVToast -Type Error -Message "[$movieId] not matched"
                }
            }

            # We want to clone the data here so we can reset to default if necessary
            $cache:originalFindData = $cache:findData.Clone()

            #if ($null -in $jvData.Data) {
            <# $skipped = ($jvData | Where-Object { $null -eq $_.Data })
                            foreach ($moviePath in $skipped) {
                                Show-UDToast -CloseOnClick -Message $moviePath
                            } #>

            <# Show-UDModal -FullWidth -MaxWidth lg -Content {
                                    New-UDCard -Title 'Skipped movies' -Content {
                                        $skipped = $jvData | Where-Object { $null -eq $_.Data }
                                        New-UDList -Content {
                                            foreach ($moviePath in $skipped) {
                                                New-UDListItem -Label $moviePath
                                            }
                                        }
                                    }
                                }
                            } #>

            Set-UDElement -Id 'textbox-sort-filepath' -Properties @{
                value = $Item.FullName
            }
        } else {
            if ($Item.Mode -like 'd*') {
                Javinizer -Path $Item.FullName -Recurse:$recurse -Strict:$strict -Update:$update -Force:$force -HideProgress -IsWeb -IsWebType 'Sort'
            } else {
                Javinizer -Path $Item.FullName -Strict:$strict -Update:$update -Force:$force -HideProgress -IsWeb -IsWebType 'Sort'
            }
        }
        Update-JVPage -Sort -ClearProgress
        Show-JVProgressModal -Off
    } else {
        Show-JVToast -Type Error -Message 'A job is currently running, please wait'
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



$Pages += New-UDPage -Name "Javinizer" -Content {
    New-UDScrollUp
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
                    New-UDCard -Title "($cache:currentIndex of $(($cache:findData).Count)) $($cache:findData[$cache:index].Data.Id)" -Content {
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

                                            <# if ((($cache:findData).Count) -gt 1) {
                                                $tempFindData = [System.Collections.ArrayList]$cache:findData
                                                $tempOriginalFindData = [System.Collections.ArrayList]($cache:originalFindData | ConvertFrom-Json -Depth 32)
                                                $tempFindData.RemoveAt($cache:index)
                                                $tempOriginalFindData.RemoveAt($cache:index)
                                                $cache:findData = $tempFindData
                                                $cache:originalFindData = ($tempOriginalFindData | ConvertTo-Json -Depth 32)
                                            } else {
                                                $cache:findData = @()
                                                $cache:originalFindData = @()
                                            }
                                            [Int]$findDataIndex = $cache:index #>
                                        }
                                        <# if ($findDataIndex -eq 0) {
                                            $cache:index = 0
                                        } else {
                                            $cache:index = $findDataIndex - 1
                                        }
                                        Update-JVPage -Sort #>
                                    }
                                }

                                <# New-UDSelect -Label 'Current Selection' -Option {
                                    if (($cache:findData).Count -eq 0) {
                                        New-UDSelectOption -Name 'Fuck' -Value 1
                                    } else {
                                        $counter = 0
                                        foreach ($movie in $cache:findData) {
                                            New-UDSelectOption -Name $movie.Data.Id -Value "$counter"
                                            $counter++
                                        }
                                    }
                                } #>
                                #New-UDTextbox -Placeholder 'Filepath' -Value ($cache:findData[$cache:index].Path) -Disabled -FullWidth
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
                                                        $sortData = Get-JVSortData -Data $cache:findData[$cache:index].Data -Path $moviePath -DestinationPath $destinationPath -Settings $cache:settings -Update:$update -Force:$force -PartNumber $cache:findData[$cache:index].PartNumber
                                                        Set-JVMovie -Data $cache:findData[$cache:index].Data -Path $moviePath -DestinationPath $destinationPath -Settings $cache:settings -Update:$update -Force:$force -PartNumber $cache:findData[$cache:index].PartNumber
                                                        if ((!($update)) -and ($null -ne $cache:findData[$cache:index].Data)) {
                                                            Write-JVWebLog -HistoryPath $cache:historyCsvPath -OriginalPath $cache:findData[$cache:index].Path -DestinationPath $sortData.Path.FilePath -Data $cache:findData[$cache:index].Data
                                                        }

                                                        # Remove the movie after it's committed
                                                        $cache:findData = $cache:findData | Where-Object { $_.Path -ne $moviePath }
                                                        $cache:originalFindData = (($cache:originalFindData) | Where-Object { $_.Path -ne $moviePath })

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
                                                                $sortData = Get-JVSortData -Data $_.Data -Path $moviePath -DestinationPath $destinationPath -Settings $settings -Update:$using:update -Force:$using:force -PartNumber $_.PartNumber
                                                                Set-JVMovie -Data $_.Data -Path $moviePath -DestinationPath $destinationPath -Settings $settings -Update:$using:update -Force:$using:force -PartNumber $_.PartNumber
                                                                if ((!($update)) -and ($null -ne $_.Data)) {
                                                                    Write-JVWebLog -HistoryPath $using:tempHistoryPath -OriginalPath $moviePath -DestinationPath $sortData.Path.FilePath -Data $_.Data
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
                                New-UDTooltip -TooltipContent { 'Open grid view' } -Content {
                                    New-UDButton -Text 'Grid View' -FullWidth -OnClick {
                                        Show-UDModal -Persistent -FullWidth -MaxWidth xl -Content {
                                            New-UDDynamic -Id 'dynamic-sort-gridview' -Content {
                                                New-UDGrid -Container -Content {
                                                    $count = 0
                                                    foreach ($movie in $cache:findData) {
                                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -MediumSize 4 -LargeSize 3 -ExtraLargeSize 2 -Content {
                                                            New-UDPaper -Elevation 5 -Content {
                                                                New-UDGrid -Container -Content {
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                        New-UDImage -Width 300 -Height 200 -Url $movie.Data.CoverUrl
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

                                                                        New-UDTextbox -Label 'Id' -Value $movie.Data.Id -Disabled -FullWidth
                                                                        New-UDTextbox -Label 'Genre' -Value (($movie.Data.Genre | Sort-Object) -join ' \ ') -Disabled -FullWidth
                                                                        New-UDTextbox -Label 'Actors' -Value $actorList -Disabled -FullWidth
                                                                        New-UDTextbox -Label 'FilePath' -Value $movie.Path -Disabled -FullWidth
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
                                                                                $tempOriginalFindData = [System.Collections.ArrayList]($cache:originalFindData | ConvertFrom-Json -Depth 32)
                                                                                $tempFindData.RemoveAt($count)
                                                                                $tempOriginalFindData.RemoveAt($count)
                                                                                $cache:findData = $tempFindData
                                                                                $cache:originalFindData = ($tempOriginalFindData | ConvertTo-Json -Depth 32)
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

                                        } -Footer {
                                            New-UDButton -Text 'Cancel' -OnClick {
                                                Hide-UDModal
                                            }
                                        }
                                    }
                                } -Place top -Effect solid -Type dark
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
                                New-UDGrid -ExtraSmallSize 12 -SmallSize 12 -Content {
                                    New-UDStyle -Style '
                                            img {
                                                width: 100%;
                                                height: auto;
                                                max-height: 860px;
                                                max-width: 1280px;
                                            }' -Content {
                                        New-UDImage -Url $cache:findData[$cache:index].Data.CoverUrl
                                    }
                                }
                                New-UDGrid -ExtraSmallSize 12 -SmallSize 12 -Content {
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

                New-UDDynamic -Content {
                    New-UDCard -Title 'Sort' -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 8 -Content {
                                New-UDTextbox -Id 'textbox-sort-filepath' -Placeholder 'Enter a path (Defaults to setting "location.input")' -Value $cache:settings.'location.input' -FullWidth
                            }
                            New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 6 -MediumSize 2 -Content {
                                New-UDTooltip -TooltipContent { "Start Javinizer on the specified directory" } -Content {
                                    New-UDButton -Icon $iconSearch -FullWidth -OnClick {
                                        Invoke-JavinizerWeb -Path (Get-UDElement -Id 'textbox-sort-filepath').value
                                    }
                                } -Place top -Effect solid -Type dark
                            }
                            New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 6 -MediumSize 2 -Content {
                                New-UDTooltip -TooltipContent { 'Clear current sort' } -Content {
                                    New-UDButton -Icon $iconTrash -FullWidth -OnClick {
                                        Show-UDModal -Content {
                                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                                New-UDTypography -Variant h6 -Text "Remove all movies from the current sort? (This does not affect your local files)"
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
                                        ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                    }
                                } -Place right -Effect float -Type dark

                                New-UDTooltip -TooltipContent { 'Performs a recursive sort on the specified directory (searches within folders)' } -Content {
                                    New-UDCheckBox -Id 'checkbox-sort-recurse' -Label 'Recurse' -LabelPlacement end -Checked $cache:settings.'web.sort.recurse' -OnChange {
                                        $cache:settings.'web.sort.recurse' = (Get-UDElement -Id 'checkbox-sort-recurse').checked
                                        ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                    }
                                } -Place right -Effect float -Type dark

                                New-UDTooltip -TooltipContent { 'Forces the filematcher to use the exact filename as the movie ID' } -Content {
                                    New-UDCheckBox -Id 'checkbox-sort-strict' -Label 'Strict' -LabelPlacement end -Checked $cache:settings.'web.sort.strict' -OnChange {
                                        $cache:settings.'web.sort.strict' = (Get-UDElement -Id 'checkbox-sort-strict').checked
                                        ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                    }
                                } -Place right -Effect float -Type dark

                                New-UDTooltip -TooltipContent { 'Runs the sort while only updating the nfo and missing image files' } -Content {
                                    New-UDCheckBox -Id 'checkbox-sort-update' -Label 'Update' -LabelPlacement end -Checked $cache:settings.'web.sort.update' -OnChange {
                                        $cache:settings.'web.sort.update' = (Get-UDElement -Id 'checkbox-sort-update').checked
                                        ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                    }
                                } -Place right -Effect float -Type dark

                                New-UDTooltip -TooltipContent { 'DANGER: Forces overwrite of existing movie/image files' } -Content {
                                    New-UDCheckBox -Id 'checkbox-sort-force' -Label 'Force' -LabelPlacement end -Checked $cache:settings.'web.sort.force' -OnChange {
                                        $cache:settings.'web.sort.force' = (Get-UDElement -Id 'checkbox-sort-force').checked
                                        ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                    }
                                } -Place right -Effect float -Type dark
                                <# New-UDCheckBox -Id 'checkbox-sort-confirm' -Label 'Confirm' -LabelPlacement end -Checked $cache:settings.'web.sort.confirm' -OnChange {
                                    $cache:settings.'web.sort.confirm' = (Get-UDElement -Id 'checkbox-sort-confirm').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                } #>
                            }
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
                                    $search = Get-ChildItem -LiteralPath $cache:filePath | Select-Object Name, Length, FullName, Mode, Extension, LastWriteTime
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

                                        New-UDTableColumn -Property FullName -Title 'Sort' -Width 150 -Render {
                                            $includedExtensions = $cache:settings.'match.includedfileextension'
                                            if (($EventData.Mode -like 'd*') -or (($EventData.Extension -in $includedExtensions) -and ($EventData.Length -ge ($cache:settings.'match.minimumfilesize')) -and ($EventData.Name -notmatch ($cache:settings.'match.excludedfilestring')))) {
                                                New-UDButton -Icon $iconSearch -IconAlignment left -Text 'Sort' -Variant outlined -OnClick {
                                                    Invoke-JavinizerWeb -Item $EventData
                                                }
                                            } else {
                                                New-UDTypography -Text ''
                                            }
                                        }
                                    )

                                    New-UDTable -Id 'table-filebrowser' -Data $search -Columns $searchColumns -Title "$cache:filePath" -Search -PageSize $cache:tablePageSize -ShowPagination
                                }

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
                                            New-UDTooltip -TooltipContent { 'Navigate to specified directory' } -Content {
                                                New-UDButton -Icon $iconSearch -OnClick {
                                                    $cache:filePath = (Get-UDElement -Id 'textbox-sort-directorypath').value

                                                    if (!(Test-Path -LiteralPath $cache:filePath)) {
                                                        Show-JVToast -Type Error -Message "[$cache:filePath] is not a valid path"
                                                    }

                                                    Sync-UDElement -Id 'dynamic-sort-filebrowser'
                                                }
                                            } -Place top -Effect solid -Type dark


                                            New-UDTooltip -TooltipContent { 'Navigate up one level' } -Content {
                                                New-UDButton -Icon $iconLevelUp -OnClick {
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
                                    }
                                    <# New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                        [string]$pageSize = $cache:tablePageSize
                                        New-UDSelect -Id 'select-sort-pagesize' -Label 'Rows per page' -DefaultValue $pageSize -Option {
                                            $pageSizeOptions = @('5', '10', '20', '50', '100')
                                            foreach ($option in $pageSizeOptions) {
                                                New-UDSelectOption -Name $option -Value $option
                                            }
                                        } -OnChange {
                                            $cache:tablePageSize = [int](Get-UDElement -Id 'select-sort-pagesize').value
                                            Sync-UDElement -Id 'dynamic-sort-filebrowser'
                                        }
                                    } #>
                                }
                            }
                        }
                    }
                }
            }

            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                New-UDDynamic -Id 'dynamic-sort-aggregateddata' -Content {
                    New-UDCard -Title "Aggregated Data" -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
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
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Id -ne ((($cache:originalFindData)[$cache:index]).Data.Id)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-id' -Icon $iconExclamation -Label 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-id' -Label 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-id' -Label 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.ContentId -ne ((($cache:originalFindData)[$cache:index]).Data.ContentId)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-contentid' -Icon $iconExclamation -Label 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-contentid' -Label 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-contentid' -Label 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.DisplayName -ne ((($cache:originalFindData)[$cache:index]).Data.DisplayName)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-displayname' -Icon $iconExclamation -Label 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-displayname' -Label 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-displayname' -Label 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Title -ne ((($cache:originalFindData)[$cache:index]).Data.Title)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-title' -Icon $iconExclamation -Label 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-title' -Label 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-title' -Label 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.AlternateTitle -ne ((($cache:originalFindData)[$cache:index]).Data.AlternateTitle)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-alternatetitle' -Icon $iconExclamation -Label 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-alternatetitle' -Label 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-alternatetitle' -Label 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Description -ne ((($cache:originalFindData)[$cache:index]).Data.Description)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-description' -Icon $iconExclamation -Label 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-description' -Label 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-description' -Label 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.ReleaseDate -ne ((($cache:originalFindData)[$cache:index]).Data.ReleaseDate)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-releasedate' -Icon $iconExclamation -Label 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-releasedate' -Label 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-releasedate' -Label 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Runtime -ne ((($cache:originalFindData)[$cache:index]).Data.Runtime)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-runtime' -Icon $iconExclamation -Label 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-runtime' -Label 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-runtime' -Label 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Director -ne ((($cache:originalFindData)[$cache:index]).Data.Director)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-director' -Icon $iconExclamation -Label 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-director' -Label 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-director' -Label 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Maker -ne ((($cache:originalFindData)[$cache:index]).Data.Maker)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-maker' -Icon $iconExclamation -Label 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-maker' -Label 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-maker' -Label 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Label -ne ((($cache:originalFindData)[$cache:index]).Data.Label)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-label' -Icon $iconExclamation -Label 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-label' -Label 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-label' -Label 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Series -ne ((($cache:originalFindData)[$cache:index]).Data.Series)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-series' -Icon $iconExclamation -Label 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-series' -Label 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-series' -Label 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
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
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Rating.Rating -ne ((($cache:originalFindData)[$cache:index]).Data.Rating.Rating)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-rating' -Icon $iconExclamation -Label 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-rating' -Label 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-rating' -Label 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Rating.Votes -ne ((($cache:originalFindData)[$cache:index]).Data.Rating.Votes)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-votes' -Icon $iconExclamation -Label 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-votes' -Label 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-votes' -Label 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
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
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.CoverUrl -ne ((($cache:originalFindData)[$cache:index]).Data.CoverUrl)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-coverurl' -Icon $iconExclamation -Label 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-coverurl' -Label 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-coverurl' -Label 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
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
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.TrailerUrl -ne ((($cache:originalFindData)[$cache:index]).Data.TrailerUrl)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-trailerurl' -Icon $iconExclamation -Label 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl

                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-trailerurl' -Label 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-trailerurl' -Label 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                }
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
                                                $cache:findData[$cache:index].Data.Tag = ((Get-UDElement -Id 'textbox-sort-aggregateddata-tag').value -split '\\').Trim()
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
                                                $cache:findData[$cache:index].Data.Genre = ((Get-UDElement -Id 'textbox-sort-aggregateddata-genre').value -split '\\').Trim()
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
                                        Show-UDModal -FullWidth -MaxWidth lg -Persistent -Content {
                                            if ($null -eq $cache:findData[$cache:index].Data) {
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
                                                }
                                            } else {
                                                $aggregatedData = $cache:findData[$cache:index].Data
                                            }
                                            New-UDCodeEditor -Id 'dynamic-sort-aggregateddataeditor' -HideCodeLens -Language 'json' -Width '155ch' -Height '85ch' -Theme vs-dark -Code ($aggregatedData | ConvertTo-Json)
                                        } -Header {
                                            New-UDTypography -Text (Get-UDElement -Id 'textbox-sort-manualsearch').value.ToUpper()
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
                                New-UDTooltip -TooltipContent { 'Reset metadata changes to default' } -Content {
                                    New-UDButton -Icon $iconUndo -Text 'Reset' -FullWidth -OnClick {
                                        if (($cache:findData).Length -eq 1) {
                                            $cache:findData = ($cache:originalFindData)
                                            Update-JVPage -Sort

                                        } else {
                                            ($cache:findData)[$cache:index] = ($cache:originalFindData)[$cache:index]
                                            Update-JVPage -Sort
                                        }
                                    }
                                } -Place top -Type dark -Effect solid
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                New-UDTooltip -TooltipContent { 'Perform a manual search on the currently selected movie' } -Content {
                                    New-UDButton -Icon $iconSearch -Text 'Manual Search' -FullWidth -OnClick {
                                        Show-UDModal -FullWidth -MaxWidth md -Content {
                                            $scrapers = @(
                                                'aventertainment',
                                                'aventertainmentja'
                                                'dmm',
                                                'dmmja',
                                                'jav321ja',
                                                'javbus',
                                                'javbusja',
                                                'javbuszh',
                                                'javlibrary',
                                                'javlibraryja',
                                                'javlibraryzh',
                                                'mgstageja'
                                                'r18',
                                                'r18zh'
                                            )
                                            New-UDTextbox -Id 'textbox-sort-manualsearch' -Label 'Enter an ID or a comma separated list of URLs' -FullWidth -Multiline -Autofocus
                                            New-UDGrid -Container -Content {
                                                foreach ($scraper in $scrapers) {
                                                    New-UDGrid -Item -ExtraSmallSize 4 -SmallSize 4 -MediumSize 4 -Content {
                                                        New-UDCheckBox -Id "checkbox-sort-scraper-$scraper" -Label $scraper -Checked $cache:settings."web.sort.manualsearch.$scraper" -OnChange {
                                                            $cache:settings."web.sort.manualsearch.$scraper" = (Get-UDElement -Id "checkbox-sort-scraper-$scraper").checked
                                                            ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                                        }
                                                    }
                                                }
                                            }
                                        } -Footer {
                                            New-UDButton -Icon $iconSearch -FullWidth -OnClick {
                                                $searchInput = (Get-UDElement -Id 'textbox-sort-manualsearch').value
                                                if (!($cache:inProgress)) {
                                                    Show-JVProgressModal -Generic
                                                    if ($searchInput -like '*.com*') {
                                                        $searchInput = $searchInput -split ','
                                                        $jvData = (Javinizer -Find $searchInput -Aggregated)
                                                        $cache:findData[$cache:index].Data = $jvData
                                                    } else {
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
                                                        }
                                                        $jvData = (Javinizer @findParams)

                                                        if ($null -ne $jvData) {
                                                            $cache:findData[$cache:index].Data = $jvData
                                                        } else {
                                                            Show-JVToast -Type Error -Message "Id [$searchInput] not found"
                                                        }
                                                    }
                                                    Update-JVPage -Sort
                                                    Show-JVProgressModal -Off
                                                } else {
                                                    Show-JVToast -Type Error -Message "A job is currently running, please wait"
                                                }
                                            }
                                            New-UDButton -Text 'Cancel' -FullWidth -OnClick {
                                                Hide-UDModal
                                            }
                                        }
                                    }
                                } -Place top -Type dark -Effect solid

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
                                                        New-UDButton -Icon $iconEdit -FullWidth -OnClick {
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
                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                        New-UDTextbox -Id "textbox-sort-origactorname-$cache:index-$actressIndex" -Label 'Name' -Value ("$($actress.LastName) $($actress.FirstName)").Trim() -Disabled
                                                    }

                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                        New-UDTextbox -Id "textbox-sort-origactorjapanesename-$cache:index-$actressIndex" -Label 'JapaneseName' -Value $actress.JapaneseName -Disabled
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
                                                    New-UDButton -Icon $iconEdit -FullWidth -OnClick {
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
}

$Pages += New-UDPage -Name 'Emby/Jellyfin' -Content {
    New-UDScrollUp
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDTypography -Text "If you use Emby or Jellyfin, you will need to use its API to POST actor images into your server. To use this feature of Javinizer, first define 'emby.baseurl' and 'emby.apikey' on the settings page."
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
        'R18Zh'
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
        'javlibrary.cookie.cfduid',
        'javlibrary.cookie.cfclearance',
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
        'sort.metadata.nfo.firstnameorder',
        'sort.metadata.nfo.actresslanguageja',
        'sort.metadata.nfo.unknownactress',
        'sort.metadata.nfo.actressastag',
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

    New-UDDynamic -Id 'dynamic-settings-page' -Content {
        New-UDScrollUp
        New-UDGrid -Container -Content {
            ## Left Column
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                New-UDCard -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 4 -Content {
                            New-UDButton -Icon $iconCheck -Text 'Apply' -Size large -FullWidth -OnClick {
                                Show-JVProgressModal -Generic -NoCancel
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
                                Show-JVProgressModal -Generic -NoCancel
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
                                    New-UDTextbox -Label 'match.minimumfilesize (MB)' -Id 'textbox-settings-minfilesize' -Value ($cache:settings.'match.minimumfilesize') -FullWidth
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Label 'match.includedfileextension (Edit in JSON)' -Id 'textbox-settings-includedfileext' -Value ($cache:settings.'match.includedfileextension' -join ' \ ') -FullWidth -Disabled
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Label 'match.excludedfilestring (Edit in JSON)' -Id 'textbox-settings-excludedfilestr' -Value ($cache:settings.'match.excludedfilestring' -join ' \ ') -FullWidth -Disabled
                                }
                            }
                            New-UDGrid -Container -Content {
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
                                            New-UDTextbox -Label 'match.regex.idmatch' -Id 'textbox-settings-regexidmatch' -Value ($cache:settings.'match.regex.idmatch') -FullWidth
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Label 'match.regex.ptmatch' -Id 'textbox-settings-regexptmatch' -Value ($cache:settings.'match.regex.ptmatch') -FullWidth
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                New-UDCard -Title 'Admin' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -SmallSize 6 -Content {
                            New-UDCheckBox -Id 'checkbox-settings-adminlog' -Label 'admin.log' -LabelPlacement end -Checked ($cache:settings.'admin.log')
                        }
                        New-UDGrid -Item -SmallSize 6 -Content {
                            New-UDTypography -Variant 'body2' -Text 'admin.log.level'
                            New-UDAutocomplete -Id 'autocomplete-settings-adminloglevel' -Options @('debug', 'info', 'warning', 'error') -Value ($cache:settings.'admin.log.level')
                        }
                    }
                }
            }

            ## Right column
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                New-UDCard -Title 'Locations & Persistent Settings Files' -Content {
                    New-UDGrid -Container -Content {
                        foreach ($setting in $locationSettings) {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                New-UDTextbox -Label "location.$setting" -Id "textbox-settings-location-$setting" -Value ($cache:settings."location.$setting") -FullWidth
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
                                'sort.create.nfo' { 'Specifies to create the nfo file when sorting a movie' }
                                'sort.create.nfoperfile' { 'Specifies to create a nfo file for every movie file, this will force the nfo to be renamed using the filename' }
                                'sort.download.actressimg' { 'Specifies to download actress images when sorting a movie' }
                                'sort.download.thumbimg' { 'Specifies to download the thumbnail image when sorting a movie' }
                                'sort.download.posterimg' { 'Specifies to create the poster image when sorting a movie. Sort.download.thumbimg is required for this to function' }
                                'sort.download.screenshotimg' { 'Specifies to download screenshot images when sorting a movie' }
                                'sort.download.trailervid' { 'Specifies to download the trailer video when sorting a movie' }
                                'sort.format.groupactress' { 'Specifies to convert the format string for when there is more than one actress to "@Group" and if unknown, to "@Unknown"' }
                                'sort.metadata.nfo.mediainfo' { 'Specifies to add media metadata information to the nfo file, this requires the MediaInfo command line application' }
                                'sort.metadata.nfo.altnamerole' { 'Specifies to set the actress role in the nfo as the altname' }
                                'sort.metadata.nfo.firstnameorder' { 'Specifies to set the actress name order to FirstName LastName' }
                                'sort.metadata.nfo.actresslanguageja' { 'Specifies to prefer Japanese names when creating the metadata nfo' }
                                'sort.metadata.nfo.unknownactress' { 'Specifies to add an "Unknown" actress to sorted movies without any actresses' }
                                'sort.metadata.nfo.actressastag' { 'Specifies to add actresses as tags in the nfo file' }
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
                                New-UDCheckBox -Label 'sort.metadata.nfo.translate.keeporiginaldescription' -Id 'checkbox-settings-translate-originaldescription' -LabelPlacement end -Checked ($cache:settings.'sort.metadata.nfo.translate')
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
                            New-UDAutocomplete -Id 'autocomplete-settings-translatemodule' -Label 'Translate Module' -Options @('googletrans', 'google_trans_new') -Value ($cache:settings.'sort.metadata.nfo.translate.module') -OnChange {
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
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                            New-UDGrid -Container -Content {
                                foreach ($setting in $formatStringSettings) {
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        if ($setting -eq 'sort.format.posterimg' -or $setting -eq 'sort.metadata.nfo.format.tag' -or $setting -eq 'sort.format.outputfolder') {
                                            New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting" -join ' \ ') -FullWidth
                                        } else {
                                            New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
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
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
                                    }
                                }
                            }
                        }
                    }
                }
                New-UDCard -Title 'Javlibrary/Javdb' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                            New-UDGrid -Container -Content {
                                foreach ($setting in $javlibrarySettings) {
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
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

$Pages += New-UDPage -Name 'History' -Content {
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
                        New-UDTypography -Variant h6 -Text "WARNING: Are you sure you want to clear your history? This cannot be undone."
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
            }
        }
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDDynamic -Id 'dynamic-history-sorttable' -Content {
                try {
                    # We want to parse for unique titles by ID/History so we don't get duplicate data
                    $cache:sortHistory = Import-Csv -LiteralPath $cache:historyCsvPath -Encoding utf8 | Group-Object Id, Maker | ForEach-Object {
                        $_.Group | Select-Object Timestamp, Id, Maker, ReleaseDate, Genre, Actress, Director, Series, Path, DestinationPath -First 1 | Sort-Object Id, Maker
                    }
                } catch {
                    Show-JVToast -Type Error -Message "$PSItem"
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
                }
                .MuiTableCell-root:hover {
                    overflow: visible;
                    white-space: normal;
                    height: auto;
                    max-width: 200px;
                }' -Content {
                    New-UDTable -Title $cache:historyCsvPath -Data $cache:sortHistory -Search -ShowPagination -ShowSort -ShowFilter -ShowExport -StickyHeader
                }

                New-UDGrid -Container -Content {
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title 'Sort History' -Content {
                            $sortDateOptions = @{
                                Type            = 'line'
                                Data            = ($cache:sortHistory | Select-Object @{Name = 'Timestamp'; Expression = { (Get-Date $_.Timestamp -Format 'yyyy-MM-dd') } } | Group-Object -Property Timestamp)
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
                            $sortDateOptions = @{
                                Type            = 'line'
                                Data            = ($cache:sortHistory | Select-Object @{Name = 'ReleaseDate'; Expression = { (Get-Date $_.ReleaseDate -Format 'yyyy-MM') } } | Group-Object -Property ReleaseDate)
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @sortDateOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title 'Top 25 Studios' -Content {
                            $makerOptions = @{
                                Type            = 'bar'
                                Data            = ($cache:sortHistory.Maker | Group-Object | Sort-Object -Top 25 -Descending | Where-Object { $_.Name -ne '' })
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @makerOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title 'Top 25 Genres' -Content {
                            $genreOptions = @{
                                Type            = 'radar'
                                Data            = ($cache:sortHistory.Genre -split '\\' | Group-Object | Sort-Object -Top 25 -Descending | Where-Object { $_.Name -ne '' })
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @genreOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title 'Top 25 Actors' -Content {
                            $actressOptions = @{
                                Type            = 'radar'
                                Data            = ($cache:sortHistory.Actress -split '\\' | Group-Object | Sort-Object -Top 25 -Descending | Where-Object { $_.Name -ne '' })
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @actressOptions
                        }
                    }

                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -LargeSize 6 -ExtraLargeSize 4 -Content {
                        New-UDCard -Title 'Top 25 Directors' -Content {
                            $actressOptions = @{
                                Type            = 'radar'
                                Data            = ($cache:sortHistory.Director | Group-Object | Sort-Object -Top 25 -Descending | Where-Object { $_.Name -ne '' })
                                DataProperty    = 'Count'
                                LabelProperty   = 'Name'
                                BackgroundColor = '#4685F4'
                                BorderColor     = '#4685F4'
                            }

                            New-UDChartJS @actressOptions
                        }
                    }
                }
            }
        }
    }
}

$Pages += New-UDPage -Name 'Admin' -Content {
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
                    #$log = $rawLog[($rawLog.Count - 1)..0] -join "`n"
                    #New-UDCheckBox -Id 'logAutoRefreshChkbx' -Label 'Autorefresh' -LabelPlacement end
                    #New-UDTextbox -Id 'logAutoRefreshInterval' -Label 'Every how many seconds' -Label '5'
                    #$cache:logAutoRefresh = (Get-UDElement -Id "logAutoRefreshChkbx")['checked']
                    #$cache:logAutoRefreshInterval = [Int](Get-UDElement -Id 'logAutoRefreshInterval').value
                    <# New-UDButton -Text 'View Full Log' -OnClick {
                                    Show-UDModal -FullScreen -Content {
                                        New-UDCodeEditor -Id 'editor-admin-fulllog' -Language 'powershell' -Width '155ch' -Height '50ch' -Theme 'vs-dark' -ReadOnly -Code $fullLog
                                    } -Footer {
                                        New-UDButton 'Close' -OnClick {
                                            Hide-UDModal
                                        }
                                    }
                                } #>

                    New-UDButton -Icon $iconUndo -Text 'Reload' -OnClick {
                        if (Test-Path -LiteralPath ($cache:settings.'location.log')) {
                            $cache:logPath = $cache:settings.'location.log'
                        } else {
                            $cache:logPath = $cache:defaultLogPath
                        }
                        Sync-UDElement -Id 'dynamic-admin-log'
                    }
                    New-UDButton -Icon $iconTrash -Text 'Clear' -OnClick {
                        Show-UDModal -FullWidth -MaxWidth xl -Content {
                            New-UDTypography -Variant h6 -Text "Clear log?"
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
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDCard -Title 'About Javinizer' -Content {
                $javinizerInfo = Javinizer -Version
                New-UDList -Content {
                    New-UDListItem -Label $javinizerInfo.Version -SubTitle 'Version'
                    New-UDListItem -Label $javinizerInfo.Prerelease -SubTitle 'Prerelease'
                    New-UDListItem -Label $javinizerInfo.Project -SubTitle 'Project'
                    New-UDListItem -Label $javinizerInfo.License -SubTitle 'License'
                    New-UDListItem -Label $javinizerInfo.ReleaseNotes -SubTitle 'ReleaseNotes'
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

New-UDDashboard -Title "Javinizer Web" -Theme $Theme -Pages $Pages -DefaultTheme $cache:defaultTheme
