# Set defaults
$cache:jvModulePath = "C:\ProgramData\Javinizer\src\Javinizer\Javinizer.psd1"
$cache:findData = @()
$cache:originalFindData = @()
$cache:actressArray = @()
$cache:filePath = ''
$cache:index = 0
$cache:currentIndex = 0
$cache:settingsPath = 'C:\ProgramData\Javinizer\src\Javinizer\jvSettings.json'
$cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
$actressIndex = 0
$cache:actressObject = Import-Csv C:\ProgramData\Javinizer\src\Javinizer\jvThumbs.csv | Sort-Object FullName
$cache:actressArray += $cache:actressObject | ForEach-Object { "$($_.FullName) ($($_.JapaneseName)) [$actressIndex]"; $actressIndex++ }
$cache:inProgress = $false
$cache:tablePageSize = $cache:settings.'web.navigation.pagesize'
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
$iconExclamation = New-UDIcon -Icon 'exclamation_circle' -Style @{
    color = 'red'
}

function SyncPage {
    param (
        [Switch]$Sort,
        [Switch]$Settings,
        [Switch]$ClearData,
        [Switch]$ClearProgress
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
        Sync-UDElement -Id 'AggregatedData'
        Sync-UDElement -Id 'AggregatedDataCover'
        Sync-UDElement -Id 'MovieSelect'
    }

    if ($Settings) {
        Sync-UDElement -Id 'SettingsTab'
    }
}

function InProgress {
    param (
        [Switch]$Sort,
        [Switch]$Generic,
        [Switch]$Off
    )

    if ($Off) {
        $cache:inProgress = $false
        Hide-UDModal
    } else {
        $cache:inProgress = $true
        if ($cache:inProgress -eq $true) {
            if ($Sort) {
                Show-UDModal -Persistent -FullWidth -MaxWidth xl -Content {
                    New-UDDynamic -Content {
                        if ($cache:totalCount -eq 0) {
                            $cache:percentComplete = 0
                        } else {
                            $cache:percentComplete = ($cache:completedCount / $cache:totalCount * 100)
                        }
                        New-UDStyle -Style '
                        .MuiLinearProgress-colorPrimary {
                            background-color: rgb(24, 31, 79);
                            height: 25px;
                        }' -Content {
                            New-UDProgress -PercentComplete $cache:percentComplete
                        }
                        New-UDTypography -Variant h3 -Text "$($cache:completedCount) of $($cache:totalCount)" -Align center
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
                        # The runspace that we want to close is created from Invoke-Parallel
                        $cache:runspacepool.Close()
                        InProgress -Off

                        # Need to wait before reassigning findData after the runspace is closed otherwise it will stay as null
                        Start-Sleep -Seconds 1
                        #$cache:findData = @()
                        #$cache:originalFindData = @()
                        SyncPage -Sort
                    }
                }
            }

            if ($Generic) {
                $cache:inProgressGeneric = $true
                Show-UDModal -Persistent -Content {
                    New-UDSpinner -tagName 'ImpulseSpinner' -color "#00cc00"
                } -Footer {
                    New-UDButton -Text 'Close' -FullWidth -OnClick {
                        InProgress -Off
                    }
                }
            }
        }
    }
}

function JavinizerSearch {
    [CmdletBinding()]
    param(
        [PSObject]$Item,

        [String]$Path
    )

    if (!($cache:inProgress)) {
        InProgress -Sort
        $recurse = (Get-UDElement -Id 'RecurseChkbx').checked
        $strict = (Get-UDElement -Id 'StrictChkbx').checked
        $interactive = (Get-UDElement -Id 'InteractiveChkbx').checked

        if ($interactive) {
            SyncPage -ClearData

            if ($Path) {
                $Item = (Get-Item -LiteralPath $Path)
            }

            if ($Item.Mode -like 'd*') {
                Show-UDToast -CloseOnClick -Message "Searching [$($Item.FullName)]" -Title 'Multi Sort' -Duration 5000 -Position bottomRight
                $cache:searchTotal = ($cache:settings | Get-JVItem -Path $Item.FullName -Recurse:$recurse -Strict:$strict).Count
                $jvData = Javinizer -Path $Item.FullName -Recurse:$recurse -Strict:$strict -IsWeb -IsWebType 'Search'
                $cache:findData = ($jvData | Where-Object { $null -ne $_.Data })
            } else {
                $movieId = ($cache:settings | Get-JVItem -Path $Item.FullName).Id
                Set-UDElement -Id 'ManualSearchTextbox' -Properties @{
                    value = $movieId
                }

                Show-UDToast -CloseOnClick -Message "Searching for [$($Item.FullName)]" -Title 'Single Sort' -Duration 5000 -Position bottomRight
                $jvData = Javinizer -Path $Item.FullName -Strict:$strict -IsWeb -IsWebType 'Search'
                if ($null -ne $jvData.Data) {
                    $cache:findData = $jvData
                } else {
                    Show-UDToast -CloseOnClick "Id [$movieId] not found" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                }
            }

            # This original data needs to be converted to json to persist
            # Otherwise the value gets overwritten when applying other changes
            $cache:originalFindData = $cache:findData | ConvertTo-Json -Depth 32

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

            Set-UDElement -Id 'sortTextbox' -Properties @{
                value = $Item.FullName
            }
        } else {
            if ($Item.Mode -like 'd*') {
                Javinizer -Path $Item.FullName -Recurse:$recurse -Strict:$strict -IsWeb -IsWebType 'Sort'
            } else {
                Javinizer -Path $Item.FullName -Strict:$strict -IsWeb -IsWebType 'Sort'
            }
        }

        SyncPage -Sort -ClearProgress
        InProgress -Off
    } else {
        Show-UDToast -CloseOnClick -Message "A job is currently running, please wait." -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
    }
}

New-UDPage -Name "Javinizer Sort" -Content {
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
                New-UDDynamic -Id 'MovieSelect' -Content {
                    if (($cache:index -eq 0) -and (($cache:findData).Count -eq 0)) {
                        $cache:currentIndex = 0
                    } else {
                        $cache:currentIndex = $cache:index + 1
                    }
                    New-UDCard -Title "($cache:currentIndex of $(($cache:findData).Count)) $($cache:findData[$cache:index].Data.Id)" -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 7 -Content {
                                New-UDTextbox -Placeholder 'Filepath' -Value ($cache:findData[$cache:index].Path) -Disabled -FullWidth
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 5 -Content {
                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -MediumSize 3 -Content {
                                        New-UDButton -Icon $iconLeftArrow -FullWidth -OnClick {
                                            if ($cache:index -gt 0) {
                                                $cache:index -= 1
                                            } else {
                                                $cache:index = ($cache:findData).Count - 1
                                            }
                                            SyncPage -Sort
                                        }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -MediumSize 3 -Content {
                                        New-UDButton -Icon $iconRightArrow -FullWidth -OnClick {
                                            if ($cache:index -lt (($cache:findData).Count - 1)) {
                                                $cache:index += 1
                                            } else {
                                                $cache:index = 0
                                            }
                                            SyncPage -Sort
                                        }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -MediumSize 3 -Content {
                                        New-UDButton -Icon $iconForward -FullWidth -OnClick {
                                            if (!($cache:inProgress)) {
                                                InProgress -Generic
                                                $moviePath = $cache:findData[$cache:index].Path
                                                if ($cache:settings.'location.output' -eq '') {
                                                    $destinationPath = (Get-Item -LiteralPath $moviePath).DirectoryName
                                                } else {
                                                    $destinationPath = $cache:settings.'location.output'
                                                }
                                                Set-JVMovie -Data $cache:findData[$cache:index].Data -Path $moviePath -DestinationPath $destinationPath -Settings $cache:settings

                                                # Remove the movie after it's committed
                                                $cache:findData = $cache:findData | Where-Object { $_.Path -ne $moviePath }
                                                $cache:originalFindData = (($cache:originalFindData | ConvertFrom-Json) | Where-Object { $_.Path -ne $moviePath }) | ConvertTo-Json -Depth 32

                                                if ($cache:index -gt 0) {
                                                    $cache:index -= 1
                                                }
                                                SyncPage -Sort
                                                Show-UDToast -CloseOnClick -Message "[$moviePath] sorted to [$destinationPath]" -Title "Success" -TitleColor green -Duration 5000 -Position bottomRight
                                                InProgress -Off
                                            } else {
                                                Show-UDToast -CloseOnClick -Message "A job is currently running, please wait." -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                            }
                                        }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -MediumSize 3 -Content {
                                        New-UDButton -Icon $iconFastForward -FullWidth -OnClick {
                                            if (!($cache:inProgress)) {
                                                InProgress -Sort
                                                $jvModulePath = $cache:jvModulePath
                                                $tempSettings = $cache:settings
                                                $cache:findData | Invoke-JVParallel -IsWeb -IsWebType 'sort' -MaxQueue $cache:settings.'throttlelimit' -Throttle $cache:settings.'throttlelimit' -ImportFunctions -ScriptBlock {
                                                    Import-Module $using:jvModulePath
                                                    $settings = $using:tempSettings
                                                    $moviePath = $_.Path
                                                    if ($settings.'location.output' -eq '') {
                                                        $destinationPath = (Get-Item -LiteralPath $moviePath).DirectoryName
                                                    } else {
                                                        $destinationPath = $settings.'location.output'
                                                    }
                                                    Set-JVMovie -Data $_.Data -Path $moviePath -DestinationPath $destinationPath -Settings $settings
                                                }

                                                SyncPage -Sort -ClearData -ClearProgress
                                                InProgress -Off
                                            } else {
                                                Show-UDToast -CloseOnClick -Message "A job is currently running, please wait." -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                New-UDDynamic -Id 'AggregatedDataCover' -Content {
                    New-UDStyle -Style '
                            .MuiCardContent-root:last-child {
                                padding-bottom: 10px;
                            }
                            .MuiCardHeader-root {
                                display: none;
                            }' -Content {

                        New-UDCard -Id 'CoverCard' -Title 'Cover' -Content {
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
                                            Show-UDModal -FullWidth -MaxWidth lg -Content {
                                                New-UDPlayer -Url $cache:findData[$cache:index].Data.TrailerUrl -Width '550px'
                                            }
                                        }
                                    }
                                    if ($null -ne $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                        New-UDButton -Icon $iconImage -Text 'Screens' -Size small -FullWidth -OnClick {
                                            Show-UDModal -FullWidth -MaxWidth lg -Content {
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
                                New-UDTextbox -Id 'sortTextbox' -Placeholder 'Enter a path' -Value $cache:settings.'location.input' -FullWidth
                            }
                            New-UDGrid -Item -ExtraSmallSize 4 -SmallSize 12 -MediumSize 4 -Content {
                                New-UDButton -Icon $iconSearch -FullWidth -OnClick {
                                    JavinizerSearch -Path (Get-UDElement -Id 'sortTextbox').value
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                New-UDCheckBox -Id 'InteractiveChkbx' -Label 'Interactive' -LabelPlacement end -Checked $cache:settings.'web.sort.interactive' -OnChange {
                                    $cache:settings.'web.sort.interactive' = (Get-UDElement -Id 'InteractiveChkbx').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                }
                                New-UDCheckBox -Id 'RecurseChkbx' -Label 'Recurse' -LabelPlacement end -Checked $cache:settings.'web.sort.recurse' -OnChange {
                                    $cache:settings.'web.sort.recurse' = (Get-UDElement -Id 'RecurseChkbx').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                }
                                New-UDCheckBox -Id 'StrictChkbx' -Label 'Strict' -LabelPlacement end -Checked $cache:settings.'web.sort.strict' -OnChange {
                                    $cache:settings.'web.sort.strict' = (Get-UDElement -Id 'StrictChkbx').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                }
                                New-UDCheckBox -Id 'UpdateChkbx' -Label 'Update' -LabelPlacement end -Checked $cache:settings.'web.sort.update' -OnChange {
                                    $cache:settings.'web.sort.update' = (Get-UDElement -Id 'UpdateChkbx').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                }
                            }
                        }
                    }
                }

                New-UDStyle -Style '
                        .MuiCardContent-root {
                            padding: 4px;
                            padding-bottom: 8px;
                        }

                        .MuiTableCell-alignLeft {
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap;
                            max-width: 200px;
                        }

                        .MuiTableCell-alignLeft:hover {
                            overflow: visible;
                            white-space: normal;
                            height: auto;
                            max-width: 200px;
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
                        }' -Content {
                    New-UDCard -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                New-UDDynamic -Id 'FileBrowser' -Content {
                                    $cache:filePath = (Get-UDElement -Id 'directoryTextbox').value
                                    $search = Get-ChildItem -LiteralPath $cache:filePath | Select-Object Name, Length, FullName, Mode, Extension, LastWriteTime | ConvertTo-Json | ConvertFrom-Json
                                    $searchColumns = @(

                                        New-UDTableColumn -Id 'tableColumnName' -Property Name -Title 'Name' -Render {
                                            if ($EventData.Mode -like 'd*') {
                                                New-UDButton -Icon (New-UDIcon -Icon folder_open_o) -IconAlignment left -Text "$($EventData.Name)" -FullWidth -OnClick {
                                                    Set-UDElement -Id 'directoryTextbox' -Properties @{
                                                        value = $EventData.FullName
                                                    }
                                                    Set-UDElement -Id 'sortTextbox' -Properties @{
                                                        value = $EventData.FullName
                                                    }
                                                    Sync-UDElement -Id 'FileBrowser'
                                                }
                                            } else {
                                                New-UDTypography -Variant 'display1' -Text "$($EventData.Name)"
                                            }
                                        }
                                        New-UDTableColumn -Id 'tableColumnSize' -Property Length -Title 'Size' -Render {
                                            if ($EventData.Mode -like 'd*') {
                                                New-UDTypography -Variant 'display1' -Text ''
                                            } else {
                                                New-UDTypography -Variant 'display1' -Text "$([Math]::Round($EventData.Length / 1GB, 2)) GB"
                                            }
                                        }
                                        New-UDTableColumn -Id 'tableColumnLastModified' -Property LastWriteTime -Title 'Last Modified' -Render {
                                            New-UDTypography -Variant 'display1' -Text "$($EventData.LastWriteTime)"
                                        }
                                        New-UDTableColumn -Id 'tableColumnSearch' -Property FullName -Title 'Sort' -Render {
                                            $includedExtensions = $cache:settings.'match.includedfileextension'
                                            if (($EventData.Mode -like 'd*') -or ($EventData.Extension -in $includedExtensions)) {
                                                New-UDButton -Icon $iconPlay -IconAlignment left -Text 'Sort' -OnClick {
                                                    JavinizerSearch -Item $EventData
                                                }
                                            } else {
                                                New-UDTypography -Text ''
                                            }
                                        }
                                    )

                                    New-UDStyle -Style '
                                        .MuiTypography-caption {
                                            font-size: initial !important;
                                        }
                                        .MuiButton-outlined {
                                            border: 0;
                                        }
                                        .MuiTableCell-root {
                                            padding: 12px;
                                            border-bottom: 1px solid rgba(81, 81, 81, 1);
                                        }
                                        .MuiButton-label {
                                            justify-content: initial !important;
                                        }
                                        .MuiButtonBase-root {
                                            letter-spacing = initial !important;
                                            display: contents;
                                        }
                                        .MuiButton-root {
                                            font-size: inherit !important;
                                            text-align: left;
                                            text-transform: none;
                                            line-height: initial !important;
                                        }' -Content {
                                        New-UDTable -Id 'DirectoryTable' -Data $search -Columns $searchColumns -Title "$cache:filePath" -Padding dense -Sort -Search -PageSize $cache:tablePageSize -PageSizeOptions @('')
                                    }
                                }

                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                        New-UDCard -Title 'Navigation' -Content {
                                            if ($cache:filePath -eq '' -or $null -eq $cache:filePath) {
                                                $dir = $cache:settings.'location.input'
                                            } else {
                                                $dir = $cache:filePath
                                            }
                                            New-UDTextbox -Id 'directoryTextbox' -Placeholder 'Enter a directory' -Value $dir -FullWidth
                                            New-UDButton -Icon $iconSearch -OnClick {
                                                $cache:filePath = (Get-UDElement -Id 'directoryTextbox').value

                                                if (!(Test-Path -LiteralPath $cache:filePath)) {
                                                    Show-UDToast -CloseOnClick "[$cache:filePath] is not a valid path" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                                                }

                                                Sync-UDElement -Id 'FileBrowser'
                                            }

                                            New-UDButton -Icon $iconLevelUp -OnClick {
                                                $dirPath = Get-Item -LiteralPath (Get-UDElement -Id 'directoryTextbox').value
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

                                                Set-UDElement -Id 'directoryTextbox' -Properties @{
                                                    value = $dirParent
                                                }

                                                Sync-UDElement -Id 'FileBrowser'
                                            }
                                        }
                                    }

                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                        New-UDCard -Title 'Manual Search' -Content {
                                            New-UDTextbox -Id 'ManualSearchTextbox' -Placeholder 'Enter an ID/Url' -FullWidth
                                            New-UDButton -Icon $iconSearch -OnClick {
                                                if (!($cache:inProgress)) {
                                                    InProgress -Generic
                                                    $searchInput = (Get-UDElement -Id 'ManualSearchTextbox').value
                                                    if ($cache:findData.Id -ne (Get-UDElement -Id 'ManualSearchTextbox').value -or $cache:findData -eq $null -or $cache:findData -eq '') {
                                                        Show-UDToast -CloseOnClick -Message "Searching for [$searchInput]" -Title "Manual sort" -Duration 5000 -Position bottomRight
                                                        if ($searchInput -like '*.com*') {
                                                            $searchInput = $searchInput -split ','
                                                            $jvData = (Javinizer -Find $searchInput -Aggregated)
                                                            $cache:findData = [PSCustomObject]@{
                                                                Data = $jvData
                                                            }
                                                        } else {
                                                            $findParams = @{
                                                                Find         = $searchInput
                                                                Dmm          = if ($cache:settings.'scraper.movie.dmm' -eq 1) { $true } else { $false }
                                                                DmmJa        = if ($cache:settings.'scraper.movie.dmmja' -eq 1) { $true } else { $false }
                                                                Jav321Ja     = if ($cache:settings.'scraper.movie.jav321ja' -eq 1) { $true } else { $false }
                                                                Javbus       = if ($cache:settings.'scraper.movie.javbus' -eq 1) { $true } else { $false }
                                                                JavbusJa     = if ($cache:settings.'scraper.movie.javbusja' -eq 1) { $true } else { $false }
                                                                JavbusZh     = if ($cache:settings.'scraper.movie.javbuszh' -eq 1) { $true } else { $false }
                                                                Javlibrary   = if ($cache:settings.'scraper.movie.javlibrary' -eq 1) { $true } else { $false }
                                                                Javlibraryja = if ($cache:settings.'scraper.movie.javlibraryja' -eq 1) { $true } else { $false }
                                                                JavlibraryZh = if ($cache:settings.'scraper.movie.javlibraryzh' -eq 1) { $true } else { $false }
                                                                R18          = if ($cache:settings.'scraper.movie.r18' -eq 1) { $true } else { $false }
                                                                R18Zh        = if ($cache:settings.'scraper.movie.r18zh' -eq 1) { $true } else { $false }
                                                                Aggregated   = $true
                                                            }
                                                            $jvData = (Javinizer @findParams)
                                                            Show-UDToast -CloseOnClick -Duration 5000 -Message ($jvData | ConvertTo-Json)
                                                            $cache:findData = [PSCustomObject]@{
                                                                Data = $jvData
                                                            }
                                                        }

                                                        if ($null -eq $cache:findData) {
                                                            Show-UDToast -CloseOnClick "Id [$searchInput] not found" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                                                        }

                                                        $cache:originalFindData = $cache:findData | ConvertTo-Json
                                                        SyncPage -Sort
                                                        InProgress -Off
                                                    }
                                                } else {
                                                    Show-UDToast -CloseOnClick -Message "A job is currently running, please wait" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                                }
                                            }
                                            New-UDButton -Icon $iconTrash -OnClick {
                                                SyncPage -Sort -ClearData
                                            }
                                        }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                        [String]$pageSize = $cache:tablePageSize
                                        New-UDSelect -Id 'PageSizeSelect' -Label 'PageSize' -DefaultValue $pageSize -Option {
                                            $pageSizeOptions = @('5', '10', '20', '50', '100')
                                            foreach ($option in $pageSizeOptions) {
                                                New-UDSelectOption -Name $option -Value $option
                                            }
                                        } -OnChange {
                                            $cache:tablePageSize = (Get-UDElement -Id 'PageSizeSelect').value
                                            Sync-UDElement -Id 'FileBrowser'
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                New-UDDynamic -Id 'AggregatedData' -Content {
                    New-UDCard -Title "Aggregated Data" -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Id -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Id)) {
                                        New-UDTextbox -Id 'dataId' -Icon $iconExclamation -Placeholder 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                    } else {
                                        New-UDTextbox -Id 'dataId' -Placeholder 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataId' -Placeholder 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.ContentId -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.ContentId)) {
                                        New-UDTextbox -Id 'dataContentId' -Icon $iconExclamation -Placeholder 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                    } else {
                                        New-UDTextbox -Id 'dataContentId' -Placeholder 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataContentId' -Placeholder 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.DisplayName -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.DisplayName)) {
                                        New-UDTextbox -Id 'dataDisplayName' -Icon $iconExclamation -Placeholder 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                    } else {
                                        New-UDTextbox -Id 'dataDisplayName' -Placeholder 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataDisplayName' -Placeholder 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Title -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Title)) {
                                        New-UDTextbox -Id 'dataTitle' -Icon $iconExclamation -Placeholder 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                    } else {
                                        New-UDTextbox -Id 'dataTitle' -Placeholder 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataTitle' -Placeholder 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.AlternateTitle -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.AlternateTitle)) {
                                        New-UDTextbox -Id 'dataAlternateTitle' -Icon $iconExclamation -Placeholder 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                    } else {
                                        New-UDTextbox -Id 'dataAlternateTitle' -Placeholder 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataAlternateTitle' -Placeholder 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Description -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Description)) {
                                        New-UDTextbox -Id 'dataDescription' -Icon $iconExclamation -Placeholder 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                    } else {
                                        New-UDTextbox -Id 'dataDescription' -Placeholder 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataDescription' -Placeholder 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.ReleaseDate -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.ReleaseDate)) {
                                        New-UDTextbox -Id 'dataReleaseDate' -Icon $iconExclamation -Placeholder 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                    } else {
                                        New-UDTextbox -Id 'dataReleaseDate' -Placeholder 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataReleaseDate' -Placeholder 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Runtime -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Runtime)) {
                                        New-UDTextbox -Id 'dataRuntime' -Icon $iconExclamation -Placeholder 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                    } else {
                                        New-UDTextbox -Id 'dataRuntime' -Placeholder 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataRuntime' -Placeholder 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Director -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Director)) {
                                        New-UDTextbox -Id 'dataDirector' -Icon $iconExclamation -Placeholder 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                    } else {
                                        New-UDTextbox -Id 'dataDirector' -Placeholder 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataDirector' -Placeholder 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Maker -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Maker)) {
                                        New-UDTextbox -Id 'dataMaker' -Icon $iconExclamation -Placeholder 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                    } else {
                                        New-UDTextbox -Id 'dataMaker' -Placeholder 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataMaker' -Placeholder 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Label -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Label)) {
                                        New-UDTextbox -Id 'dataLabel' -Icon $iconExclamation -Placeholder 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                    } else {
                                        New-UDTextbox -Id 'dataLabel' -Placeholder 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataLabel' -Placeholder 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Series -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Series)) {
                                        New-UDTextbox -Id 'dataSeries' -Icon $iconExclamation -Placeholder 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                    } else {
                                        New-UDTextbox -Id 'dataSeries' -Placeholder 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataSeries' -Placeholder 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($null -ne $cache:findData[$cache:index].Data.Tag) {
                                        if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.Tag -DifferenceObject ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Tag)) {
                                            New-UDTextbox -Id 'dataTag' -Icon $iconExclamation -Placeholder 'Tag' -FullWidth -Value ($cache:findData[$cache:index].Data.Tag -join ' \ ')
                                        } else {
                                            New-UDTextbox -Id 'dataTag' -Placeholder 'Tag' -FullWidth -Value ($cache:findData[$cache:index].Data.Tag -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataTag' -Placeholder 'Tag' -FullWidth -Value ($cache:findData[$cache:index].Data.Tag -join ' \ ')
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataTag' -Placeholder 'Tag' -FullWidth -Value ($cache:findData[$cache:index].Data.Tag -join ' \ ')
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Tagline -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Tagline)) {
                                        New-UDTextbox -Id 'dataTagline' -Icon $iconExclamation -Placeholder 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                    } else {
                                        New-UDTextbox -Id 'dataTagline' -Placeholder 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataTagline' -Placeholder 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Rating.Rating -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Rating.Rating)) {
                                        New-UDTextbox -Id 'dataRating' -Icon $iconExclamation -Placeholder 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                    } else {
                                        New-UDTextbox -Id 'dataRating' -Placeholder 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataRating' -Placeholder 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Rating.Votes -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Rating.Votes)) {
                                        New-UDTextbox -Id 'dataVotes' -Icon $iconExclamation -Placeholder 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                    } else {
                                        New-UDTextbox -Id 'dataVotes' -Placeholder 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataVotes' -Placeholder 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($null -ne $cache:findData[$cache:index].Data.Genre) {
                                        if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.Genre -DifferenceObject ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Genre)) {
                                            New-UDTextbox -Id 'dataGenre' -Icon $iconExclamation -Placeholder 'Genre' -FullWidth -Value ($cache:findData[$cache:index].Data.Genre -join ' \ ')
                                        } else {
                                            New-UDTextbox -Id 'dataGenre' -Placeholder 'Genre' -FullWidth -Value ($cache:findData[$cache:index].Data.Genre -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataGenre' -Placeholder 'Genre' -FullWidth -Value ($cache:findData[$cache:index].Data.Genre -join ' \ ')
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataGenre' -Placeholder 'Genre' -FullWidth -Value ($cache:findData[$cache:index].Data.Genre -join ' \ ')
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.CoverUrl -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.CoverUrl)) {
                                        New-UDTextbox -Id 'dataCoverUrl' -Icon $iconExclamation -Placeholder 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                    } else {
                                        New-UDTextbox -Id 'dataCoverUrl' -Placeholder 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataCoverUrl' -Placeholder 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($null -ne $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                        if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.ScreenshotUrl -DifferenceObject ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.ScreenshotUrl)) {
                                            New-UDTextbox -Id 'dataScreenshotUrl' -Icon $iconExclamation -Placeholder 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                        } else {
                                            New-UDTextbox -Id 'dataScreenshotUrl' -Placeholder 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataScreenshotUrl' -Placeholder 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataScreenshotUrl' -Placeholder 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.TrailerUrl -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.TrailerUrl)) {
                                        New-UDTextbox -Id 'dataTrailerUrl' -Icon $iconExclamation -Placeholder 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl

                                    } else {
                                        New-UDTextbox -Id 'dataTrailerUrl' -Placeholder 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataTrailerUrl' -Placeholder 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Path -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Path)) {
                                        New-UDTextbox -Id 'dataPath' -Icon $iconExclamation -Placeholder 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path
                                    } else {
                                        New-UDTextbox -Id 'dataPath' -Placeholder 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path
                                    }
                                } else {
                                    New-UDTextbox -Id 'dataPath' -Placeholder 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path
                                }
                            }

                            New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                New-UDButton -Id 'settingsApplyBtn' -Icon $iconCheck -Text 'Apply' -FullWidth -OnClick {
                                    Set-UDElement -Id 'settingsApplyBtn' -Properties @{
                                        Disabled = $true
                                    }
                                    if (!(Test-Path -LiteralPath (Get-UDElement -Id 'dataPath').value -PathType Leaf)) {
                                        $tempPath = (Get-UDElement -Id 'dataPath').value
                                        Show-UDToast -CloseOnClick "[$tempPath] is not a valid filepath" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                                        SyncPage -Sort
                                    } else {
                                        if ((Get-UDElement -Id 'dataId').value -eq '') {
                                            $cache:findData[$cache:index].Data.Id = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Id = (Get-UDElement -Id 'dataId').value
                                        }
                                        if ((Get-UDElement -Id 'dataContentId').value -eq '') {
                                            $cache:findData[$cache:index].Data.ContentId = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.ContentId = (Get-UDElement -Id 'dataContentId').value
                                        }
                                        if ((Get-UDElement -Id 'dataDisplayName').value -eq '') {
                                            $cache:findData[$cache:index].Data.DisplayName = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.DisplayName = (Get-UDElement -Id 'dataDisplayName').value
                                        }
                                        if ((Get-UDElement -Id 'dataTitle').value -eq '') {
                                            $cache:findData[$cache:index].Data.Title = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Title = (Get-UDElement -Id 'dataTitle').value
                                        }
                                        if ((Get-UDElement -Id 'dataAlternateTitle').value -eq '') {
                                            $cache:findData[$cache:index].Data.AlternateTitle = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.AlternateTitle = (Get-UDElement -Id 'dataAlternateTitle').value
                                        }
                                        if ((Get-UDElement -Id 'dataDescription').value -eq '') {
                                            $cache:findData[$cache:index].Data.Description = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Description = (Get-UDElement -Id 'dataDescription').value
                                        }
                                        if ((Get-UDElement -Id 'dataReleaseDate').value -eq '') {
                                            $cache:findData[$cache:index].Data.ReleaseDate = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.ReleaseDate = (Get-UDElement -Id 'dataReleaseDate').value
                                        }
                                        if ((Get-UDElement -Id 'dataRuntime').value -eq '') {
                                            $cache:findData[$cache:index].Data.Runtime = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Runtime = (Get-UDElement -Id 'dataRuntime').value
                                        }
                                        if ((Get-UDElement -Id 'dataDirector').value -eq '') {
                                            $cache:findData[$cache:index].Data.Director = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Director = (Get-UDElement -Id 'dataDirector').value
                                        }
                                        if ((Get-UDElement -Id 'dataMaker').value -eq '') {
                                            $cache:findData[$cache:index].Data.Maker = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Maker = (Get-UDElement -Id 'dataMaker').value
                                        }
                                        if ((Get-UDElement -Id 'dataLabel').value -eq '') {
                                            $cache:findData[$cache:index].Data.Label = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Label = (Get-UDElement -Id 'dataLabel').value
                                        }
                                        if ((Get-UDElement -Id 'dataSeries').value -eq '') {
                                            $cache:findData[$cache:index].Data.Series = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Series = (Get-UDElement -Id 'dataSeries').value
                                        }
                                        if ((Get-UDElement -Id 'dataTag').value -eq '') {
                                            $cache:findData[$cache:index].Data.Tag = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Tag = (Get-UDElement -Id 'dataTag').value -split ' \\ '
                                        }
                                        if ((Get-UDElement -Id 'dataTagline').value -eq '') {
                                            $cache:findData[$cache:index].Data.Tagline = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Tagline = (Get-UDElement -Id 'dataTagline').value
                                        }
                                        if ((Get-UDElement -Id 'dataRating').value -eq '') {
                                            $cache:findData[$cache:index].Data.Rating.Rating = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Rating.Rating = (Get-UDElement -Id 'dataRating').value
                                        }
                                        if ((Get-UDElement -Id 'dataVotes').value -eq '') {
                                            $cache:findData[$cache:index].Data.Rating.Votes = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Rating.Votes = (Get-UDElement -Id 'dataVotes').value
                                        }
                                        if ((Get-UDElement -Id 'dataGenre').value -eq '') {
                                            $cache:findData[$cache:index].Data.Genre = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.Genre = (Get-UDElement -Id 'dataGenre').value -split ' \\ '
                                        }
                                        if ((Get-UDElement -Id 'dataCoverUrl').value -eq '') {
                                            $cache:findData[$cache:index].Data.CoverUrl = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.CoverUrl = (Get-UDElement -Id 'dataCoverUrl').value
                                        }
                                        if ((Get-UDElement -Id 'dataScreenshotUrl').value -eq '') {
                                            $cache:findData[$cache:index].Data.ScreenshotUrl = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.ScreenshotUrl = (Get-UDElement -Id 'dataScreenshotUrl').value -split ' \\ '
                                        }
                                        if ((Get-UDElement -Id 'dataTrailerUrl').value -eq '') {
                                            $cache:findData[$cache:index].Data.TrailerUrl = $null
                                        } else {
                                            $cache:findData[$cache:index].Data.TrailerUrl = (Get-UDElement -Id 'dataTrailerUrl').value
                                        }
                                        if ((Get-UDElement -Id 'dataPath').value -eq '') {
                                            $cache:findData[$cache:index].Path = $null
                                        } else {
                                            $cache:findData[$cache:index].Path = (Get-UDElement -Id 'dataPath').value
                                        }
                                        SyncPage -Sort
                                    }
                                }
                            }

                            New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                New-UDButton -Icon $iconEdit -Text 'Json' -FullWidth -OnClick {
                                    Show-UDModal -FullScreen -Content {
                                        New-UDCodeEditor -Id 'AggregatedDataEditor' -HideCodeLens -Language 'json' -Height '170ch' -Width '200ch' -Theme vs-dark -Code ($cache:findData[$cache:index].Data | ConvertTo-Json)
                                    } -Header {
                                        New-UDTypography -Text (Get-UDElement -Id 'ManualSearchTextbox').value.ToUpper()
                                    } -Footer {
                                        New-UDButton -Text 'Ok' -OnClick {
                                            $cache:findData[$cache:index].Data = (Get-UDElement -Id 'AggregatedDataEditor').code | ConvertFrom-Json
                                            SyncPage -Sort
                                            Hide-UDModal
                                        }

                                        New-UDButton -Text 'Reset' -OnClick {
                                            if (($cache:findData).Length -eq 1) {
                                                Set-UDElement -Id 'AggregatedDataEditor' -Properties @{
                                                    code = ($cache:originalFindData | ConvertFrom-Json).Data | ConvertTo-Json
                                                }
                                            } else {
                                                Set-UDElement -Id 'AggregatedDataEditor' -Properties @{
                                                    code = (($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data | ConvertTo-Json
                                                }
                                            }
                                        }

                                        New-UDButton -Text "Cancel" -OnClick {
                                            Hide-UDModal
                                        }
                                    }
                                }
                            }

                            New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                New-UDButton -Icon $iconUndo -Text 'Reset' -FullWidth -OnClick {
                                    if (($cache:findData).Length -eq 1) {
                                        $cache:findData = ($cache:originalFindData | ConvertFrom-Json)
                                        SyncPage -Sort

                                    } else {
                                        ($cache:findData)[$cache:index] = ($cache:originalFindData | ConvertFrom-Json)[$cache:index]
                                        SyncPage -Sort
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
                        New-UDCard -Title 'Actresses' -Content {
                            New-UDGrid -Container -Content {
                                $actressIndex = 0
                                foreach ($actress in $cache:findData[$cache:index].Data.Actress) {
                                    New-UDGrid -ExtraSmallSize 4 -MediumSize 4 -LargeSize 3 -ExtraLargeSize 2 -Content {
                                        New-UDPaper -Elevation 0 -Content {
                                            New-UDGrid -Container -Content {
                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                    New-UDButton -Icon $iconEdit -FullWidth -OnClick {
                                                        Show-UDModal -Persistent -FullWidth -MaxWidth lg -Content {
                                                            New-UDCard -Title 'Edit Actress' -TitleAlignment center -Content {
                                                                New-UDGrid -Container -Content {
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "actressLastName$cache:index-$actressIndex" -Placeholder 'LastName' -Value $actress.LastName -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "actressFirstName$cache:index-$actressIndex" -Placeholder 'FirstName' -Value $actress.FirstName -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "actressJapaneseName$cache:index-$actressIndex" -Placeholder 'JapaneseName' -Value $actress.JapaneseName -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "actressThumbUrl$cache:index-$actressIndex" -Placeholder 'ThumbUrl' -Value $actress.ThumbUrl -FullWidth
                                                                    }
                                                                }
                                                            }
                                                            New-UDCard -Title 'Select Existing' -TitleAlignment center -Content {
                                                                New-UDGrid -Container -Content {
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                        New-UDAutocomplete -Id 'actressAutoComplete' -Options $cache:actressArray -OnChange {
                                                                            $actressObjectIndex = ((Get-UDElement -Id 'actressAutoComplete').value | Select-String -Pattern '\[(\d*)\]').Matches.Groups[1].Value
                                                                            Set-UDElement -Id "actressLastName$cache:index-$actressIndex" -Properties @{
                                                                                value = $cache:actressObject[$actressObjectIndex].LastName
                                                                            }
                                                                            Set-UDElement -Id "actressFirstName$cache:index-$actressIndex" -Properties @{
                                                                                value = $cache:actressObject[$actressObjectIndex].FirstName
                                                                            }
                                                                            Set-UDElement -Id "actressJapaneseName$cache:index-$actressIndex" -Properties @{
                                                                                value = $cache:actressObject[$actressObjectIndex].JapaneseName
                                                                            }
                                                                            Set-UDElement -Id "actressThumbUrl$cache:index-$actressIndex" -Properties @{
                                                                                value = $cache:actressObject[$actressObjectIndex].ThumbUrl
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } -Footer {
                                                            New-UDButton -Id 'updateActressBtn' -Text 'Ok' -FullWidth -OnClick {
                                                                Set-UDElement -Id 'updateActressBtn' -Properties @{
                                                                    Disabled = $true
                                                                }

                                                                if ((Get-UDElement -Id "actressLastName$cache:index-$actressIndex").value -eq '') {
                                                                    $lastName = $null
                                                                } else {
                                                                    $lastName = (Get-UDElement -Id "actressLastName$cache:index-$actressIndex").value
                                                                }

                                                                if ((Get-UDElement -Id "actressFirstName$cache:index-$actressIndex").value -eq '') {
                                                                    $firstName = $null
                                                                } else {
                                                                    $firstName = (Get-UDElement -Id "actressFirstName$cache:index-$actressIndex").value
                                                                }

                                                                if ((Get-UDElement -Id "actressJapaneseName$cache:index-$actressIndex").value -eq '') {
                                                                    $japaneseName = $null
                                                                } else {
                                                                    $japaneseName = (Get-UDElement -Id "actressJapaneseName$cache:index-$actressIndex").value
                                                                }

                                                                if ((Get-UDElement -Id "actressThumbUrl$cache:index-$actressIndex").value -eq '') {
                                                                    $thumbUrl = $null
                                                                } else {
                                                                    $thumbUrl = (Get-UDElement -Id "actressThumbUrl$cache:index-$actressIndex").value
                                                                }

                                                                $updatedActress = [PSCustomObject]@{
                                                                    LastName     = $lastName
                                                                    FirstName    = $firstName
                                                                    JapaneseName = $japaneseName
                                                                    ThumbUrl     = $thumbUrl
                                                                }

                                                                ((($cache:findData)[$cache:index]).Data.Actress)[$actressIndex] = $updatedActress
                                                                SyncPage -Sort
                                                                Hide-UDModal
                                                            }
                                                            New-UDButton -Text 'Remove' -FullWidth -OnClick {
                                                                $origJapaneseName = ((Get-UDElement -Id "origActressJapaneseName$cache:index-$actressIndex").value)
                                                                (($cache:findData)[$cache:index]).Data.Actress = (($cache:findData)[$cache:index]).Data.Actress | Where-Object { $_.JapaneseName -ne $origJapaneseName }

                                                                if (($cache:findData[$cache:index].Data.Actress).Count -eq 1) {
                                                                    # Reset the single actress as an Array of objects
                                                                    $tempActress = @()
                                                                    $tempActress += ($cache:findData[$cache:index].Data.Actress)
                                                                    $cache:findData[$cache:index].Data.Actress = $tempActress
                                                                }

                                                                if (($cache:findData[$cache:index].Data.Actress).Count -eq 0) {
                                                                    $cache:findData[$cache:index].Data.Actress = $null
                                                                }
                                                                Hide-UDModal
                                                                SyncPage -Sort
                                                            }
                                                            New-UDButton -Text 'Cancel' -FullWidth -OnClick {
                                                                SyncPage -Sort
                                                                Hide-UDModal
                                                            }
                                                        }
                                                    }
                                                }
                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                        New-UDTextbox -Id "origActressName$cache:index-$actressIndex" -Placeholder 'Name' -Value ("$($actress.LastName) $($actress.FirstName)").Trim() -Disabled
                                                    }

                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                        New-UDTextbox -Id "origActressJapaneseName$cache:index-$actressIndex" -Placeholder 'JapaneseName' -Value $actress.JapaneseName -Disabled
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
                                                New-UDButton -Icon $iconEdit -FullWidth -OnClick {
                                                    Show-UDModal -FullWidth -MaxWidth lg -Content {
                                                        New-UDCard -Title 'Add Actress' -TitleAlignment center -Content {
                                                            New-UDGrid -Container -Content {
                                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                    New-UDTextbox -Id "newActressLastName" -Placeholder 'LastName' -FullWidth
                                                                }
                                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                    New-UDTextbox -Id "newActressFirstName" -Placeholder 'FirstName' -FullWidth
                                                                }
                                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                    New-UDTextbox -Id "newActressJapaneseName" -Placeholder 'JapaneseName' -FullWidth
                                                                }
                                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                    New-UDTextbox -Id "newActressThumbUrl" -Placeholder 'ThumbUrl' -FullWidth
                                                                }
                                                            }
                                                        }
                                                        New-UDCard -Title 'Select Existing' -TitleAlignment center -Content {
                                                            New-UDGrid -Container -Content {
                                                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                                                    New-UDAutocomplete -Id 'actressAutoComplete' -Options $cache:actressArray -OnChange {
                                                                        $actressObjectIndex = ((Get-UDElement -Id 'actressAutoComplete').value | Select-String -Pattern '\[(\d*)\]').Matches.Groups[1].Value
                                                                        Set-UDElement -Id "newActressLastName" -Properties @{
                                                                            value = $cache:actressObject[$actressObjectIndex].LastName
                                                                        }
                                                                        Set-UDElement -Id "newActressFirstName" -Properties @{
                                                                            value = $cache:actressObject[$actressObjectIndex].FirstName
                                                                        }
                                                                        Set-UDElement -Id "newActressJapaneseName" -Properties @{
                                                                            value = $cache:actressObject[$actressObjectIndex].JapaneseName
                                                                        }
                                                                        Set-UDElement -Id "newActressThumbUrl" -Properties @{
                                                                            value = $cache:actressObject[$actressObjectIndex].ThumbUrl
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    } -Footer {
                                                        New-UDButton -Id 'addActressBtn' -Text 'Ok' -FullWidth -OnClick {
                                                            Set-UDElement -Id 'addActressBtn' -Properties @{
                                                                Disabled = $true
                                                            }

                                                            if ((Get-UDElement -Id "newActressLastName").value -eq '') {
                                                                $lastName = $null
                                                            } else {
                                                                $lastName = (Get-UDElement -Id "newActressLastName").value
                                                            }

                                                            if ((Get-UDElement -Id "newActressFirstName").value -eq '') {
                                                                $firstName = $null
                                                            } else {
                                                                $firstName = (Get-UDElement -Id "newActressFirstName").value
                                                            }

                                                            if ((Get-UDElement -Id "newActressJapaneseName").value -eq '') {
                                                                $japaneseName = $null
                                                            } else {
                                                                $japaneseName = (Get-UDElement -Id "newActressJapaneseName").value
                                                            }

                                                            if ((Get-UDElement -Id "newActressThumbUrl").value -eq '') {
                                                                $thumbUrl = $null
                                                            } else {
                                                                $thumbUrl = (Get-UDElement -Id "newActressThumbUrl").value
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

                                                            SyncPage -Sort
                                                            Hide-UDModal

                                                        }
                                                        New-UDButton -Text 'Cancel' -FullWidth -OnClick {
                                                            SyncPage -Sort
                                                            Hide-UDModal
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
    }
}
