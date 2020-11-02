$cache:settingsPath = '/home/Javinizer/src/Javinizer/jvSettings.json'
$cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
$cache:inProgress = $false
$cache:findData = @()
$cache:originalFindData = @()
$cache:filePath = ''
$cache:tablePageSize = $cache:settings.'web.navigation.pagesize'
$cache:index = 0
$iconSearch = New-UDIcon -Icon 'search' -Size lg
$iconRightArrow = New-UDIcon -Icon 'arrow_right' -Size lg
$iconLeftArrow = New-UDIcon -Icon 'arrow_left' -Size lg
$iconLevelUp = New-UDIcon -Icon 'level_up_alt' -Size lg
$iconCheck = New-UDIcon -Icon 'check' -Size lg
$iconTrash = New-UDIcon -Icon 'trash' -Size lg
$iconEdit = New-UDIcon -Icon 'edit' -Size lg
$iconPlus = New-UDIcon -Icon 'plus' -Size lg
$iconUndo = New-UDIcon -Icon 'undo' -Size lg
$iconExclamation = New-UDIcon -Icon 'exclamation_circle' -Style @{
    color = 'red'
}

function JavinizerSearch {
    [CmdletBinding()]
    param(
        [PSObject]$Item,

        [String]$Path
    )

    if (!($cache:inProgress)) {
        $cache:inProgress = $true
        $cache:inSort = $true

        if ($Path) {
            $Item = (Get-Item -LiteralPath $Path)
        }

        if ($Item.Mode -like 'd*') {
            Show-UDToast -Message "Searching [$($Item.FullName)]" -Title 'Multi Sort' -Duration 5000 -Position bottomRight
            $recurse = (Get-UDElement -Id 'RecurseChkbx').checked
            $strict = (Get-UDElement -id 'StrictChkbx').checked
            $cache:searchTotal = ($cache:settings | Get-JVItem -Path $Item.FullName -Recurse:$recurse -Strict:$strict).Count
            $jvData = Javinizer -Path $Item.FullName -Recurse:$recurse -Strict:$strict -IsWeb
            $cache:findData = ($jvData | Where-Object { $null -ne $_.Data })
        } else {
            $movieId = ($cache:settings | Get-JVItem -Path $Item.FullName).Id
            Set-UDElement -Id 'ManualSearchTextbox' -Properties @{
                value = $movieId
            }

            Show-UDToast -Message "Searching for [$($Item.FullName)]" -Title 'Single Sort' -Duration 5000 -Position bottomRight
            $jvData = Javinizer -Path $Item.FullName -Strict:$strict -IsWeb
            if ($null -ne $jvData.Data) {
                $cache:findData = $jvData
            } else {
                Show-UDToast "Id [$movieId] not found" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
            }
        }

        # This original data needs to be converted to json to persist
        # Otherwise the value gets overwritten when applying other changes
        $cache:originalFindData = $cache:findData | ConvertTo-Json -Depth 32

        #if ($null -in $jvData.Data) {
        <# $skipped = ($jvData | Where-Object { $null -eq $_.Data })
        foreach ($moviePath in $skipped) {
            Show-UDToast -Message $moviePath
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

        Set-UDElement -Id 'FileDirSearchTextbox' -Properties @{
            value = $Item.FullName
        }

        SyncPage -Sort
        $cache:totalCount = 0
        $cache:completedCount = 0
        $cache:currentSort = $null
        $cache:currentSortFullName = $null
        $cache:inProgress = $false
        $cache:inSort = $false
    } else {
        Show-UDToast -Message "A job is currently running, please wait." -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
    }
}

function SyncPage {
    param (
        [Switch]$Sort,
        [Switch]$Settings
    )
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

New-UDPage -Name "Javinizer Web" -Content {
    New-UDTabs -RenderOnActive -Tabs {
        New-UDTab -Text 'Sort' -Dynamic -Content {
            # Progress modal
            New-UDDynamic -Content {
                if ($cache:inProgress -eq $true) {
                    if ($cache:inSort -eq $true) {
                        Show-UDModal -Persistent -FullWidth -MaxWidth lg -Content {
                            if ($cache:totalCount -eq 0) {
                                $cache:percentComplete = 0
                            } else {
                                $cache:percentComplete = ($cache:completedCount / $cache:totalCount * 100)
                            }
                            New-UDProgress -PercentComplete $cache:percentComplete
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
                        } -Footer {
                            New-UDButton -Text 'Cancel' -Variant outlined -FullWidth -OnClick {
                                # The runspace that we want to close is created from Invoke-Parallel
                                $cache:runspacepool.Close()
                                $cache:inProgress = $false

                                # Need to wait before reassigning findData after the runspace is closed otherwise it will stay as null
                                Start-Sleep -Seconds 1
                                $cache:findData = @()
                                $cache:originalFindData = @()
                                SyncPage -Sort
                            }
                        }
                    }
                } else {
                    Hide-UDModal
                }
            } -AutoRefresh -AutoRefreshInterval 2

            New-UDGrid -Container -Content {
                New-UDGrid -Item -ExtraSmallSize 6 -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -SmallSize 12 -MediumSize 5 -Content {
                            New-UDDynamic -Content {
                                New-UDCard -Title 'Search' -Content {
                                    New-UDTextbox -Id 'FileDirSearchTextbox' -Placeholder 'Enter a path' -Value $cache:settings.'location.input' -FullWidth
                                    New-UDButton -Icon $iconSearch -Variant outlined -OnClick {
                                        JavinizerSearch -Path (Get-UDElement -Id 'FileDirSearchTextbox').value
                                    }
                                }
                            }
                        }
                        New-UDGrid -Item -SmallSize 12 -MediumSize 7 -Content {
                            New-UDDynamic -Id 'MovieSelect' -Content {
                                if (($cache:index -eq 0) -and (($cache:findData).Count -eq 0)) {
                                    $currentIndex = 0
                                } else {
                                    $currentIndex = $cache:index + 1
                                }
                                New-UDCard -Title "($currentIndex of $(($cache:findData).Count)) $($cache:findData[$cache:index].Data.Id)" -Content {
                                    New-UDTextbox -Placeholder 'Filepath' -Value ($cache:findData[$cache:index].Path) -Disabled -FullWidth
                                    New-UDSelect
                                    New-UDButton -Icon $iconLeftArrow -Variant outlined -OnClick {
                                        if ($cache:index -gt 0) {
                                            $cache:index -= 1
                                        } else {
                                            $cache:index = ($cache:findData).Count - 1
                                        }
                                        SyncPage -Sort
                                    }
                                    New-UDButton -Icon $iconRightArrow -Variant outlined -OnClick {
                                        if ($cache:index -lt (($cache:findData).Count - 1)) {
                                            $cache:index += 1
                                        } else {
                                            $cache:index = 0
                                        }
                                        SyncPage -Sort
                                    }
                                    New-UDButton -Icon $iconCheck -Variant outlined -OnClick {
                                        if (!($cache:inProgress)) {
                                            $cache:inProgress = $true
                                            $moviePath = $cache:findData[$cache:index].Path
                                            if ($cache:settings.'location.output' -eq '') {
                                                $destinationPath = (Get-Item -LiteralPath $moviePath).DirectoryName
                                            } else {
                                                $destinationPath = $cache:settings.'location.output'
                                            }
                                            Set-JVMovie -Data $cache:findData[$cache:index].Data -Path $moviePath -DestinationPath $destinationPath -Settings $cache:settings

                                            # Remove the movie after it's committed
                                            $cache:findData = $cache:findData | Where-Object { $_.Path -ne $moviePath }

                                            if ($cache:index -gt 0) {
                                                $cache:index -= 1
                                            }
                                            SyncPage -Sort
                                            Show-UDToast -Message "[$moviePath] sorted to [$destinationPath]" -Title "Success" -TitleColor green -Duration 5000 -Position bottomRight
                                            $cache:inProgress = $false
                                        } else {
                                            Show-UDToast -Message "A job is currently running, please wait." -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                        }
                                    }
                                }
                            }
                        }
                    }

                    New-UDDynamic -Id 'AggregatedDataCover' -Content {
                        New-UDStyle -Style '
                        .MuiCardHeader-root {
                            display: none;
                        }' -Content {
                            New-UDCard -Title 'Cover' -Content {
                                New-UDImage -Url $cache:findData[$cache:index].Data.CoverUrl
                            }
                            New-UDCard -Title 'Screenshot' -Content {
                                foreach ($img in $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                    New-UDImage -Url $img -Height 100
                                }
                            }
                        }
                    }

                    New-UDCard -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                New-UDDynamic -Id 'FileBrowser' -Content {
                                    $cache:filePath = (Get-UDElement -Id 'DirectoryTextbox').value
                                    $search = Get-ChildItem -LiteralPath $cache:filePath | Select-Object Name, Length, FullName, Mode, Extension, LastWriteTime | ConvertTo-Json | ConvertFrom-Json
                                    $searchColumns = @(
                                        New-UDTableColumn -Property Name -Title 'Name' -Render {
                                            if ($EventData.Mode -like 'd*') {
                                                New-UDButton -Icon (New-UDIcon -Icon folder_open_o) -IconAlignment left -Variant 'outlined' -Text "$($EventData.Name)" -FullWidth -OnClick {
                                                    Set-UDElement -Id 'DirectoryTextbox' -Properties @{
                                                        value = $EventData.FullName
                                                    }
                                                    Sync-UDElement -Id 'FileBrowser'
                                                }
                                            } else {
                                                New-UDTypography -Variant 'display1' -Text "$($EventData.Name)"
                                            }
                                        }
                                        New-UDTableColumn -Property Length -Title 'Size' -Render {
                                            if ($EventData.Mode -like 'd*') {
                                                New-UDTypography -Variant 'display1' -Text ''
                                            } else {
                                                New-UDTypography -Variant 'display1' -Text "$([Math]::Round($EventData.Length / 1GB, 2)) GB"
                                            }
                                        }
                                        New-UDTableColumn -Property LastWriteTime -Title 'Last Modified' -Render {
                                            New-UDTypography -Variant 'display1' -Text "$($EventData.LastWriteTime)"
                                        }
                                        New-UDTableColumn -Property FullName -Title 'Search' -Render {
                                            $includedExtensions = $cache:settings.'match.includedfileextension'
                                            if (($EventData.Mode -like 'd*') -or ($EventData.Extension -in $includedExtensions)) {
                                                New-UDButton -Icon (New-UDIcon -Icon play) -Variant 'outlined' -IconAlignment left -Text 'Search' -OnClick {
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
                                            border-bottom: 3px solid rgba(81, 81, 81, 1);
                                        }
                                        .MuiButton-label {
                                            justify-content: initial !important;
                                        }
                                        .MuiButtonBase-root {
                                            letter-spacing = initial !important;
                                            display: contents;
                                        }
                                        .MuiButton-root {
                                            font-size: initial !important;
                                            text-align: left;
                                            text-transform: none;
                                            line-height: initial !important;
                                        }' -Content {
                                        New-UDTable -Id 'DirectoryTable' -Data $search -Columns $searchColumns -Title "$cache:filePath" -Padding dense -Sort -Search -PageSize $cache:tablePageSize -PageSizeOptions @('')
                                    }
                                }
                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                        New-UDCard -Title 'Navigation' -Content {
                                            if ($cache:filePath -eq '' -or $null -eq $cache:filePath) {
                                                $dir = $cache:settings.'location.input'
                                            } else {
                                                $dir = $cache:filePath
                                            }
                                            New-UDTextbox -Id 'DirectoryTextbox' -Placeholder 'Enter a directory' -Value $dir -FullWidth
                                            New-UDButton -Icon $iconSearch -Variant outlined -OnClick {
                                                $cache:filePath = (Get-UDElement -Id 'DirectoryTextbox').value

                                                if (!(Test-Path -LiteralPath $cache:filePath)) {
                                                    Show-UDToast "[$cache:filePath] is not a valid path" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                                                }

                                                Sync-UDElement -Id 'FileBrowser'
                                            }

                                            New-UDButton -Icon $iconLevelUp -Variant outlined -OnClick {
                                                $dirPath = Get-Item -LiteralPath (Get-UDElement -Id 'DirectoryTextbox').value
                                                if (Test-Path -LiteralPath $dirPath -PathType Container) {
                                                    $dirParent = $dirPath.Parent.FullName
                                                } else {
                                                    $dirParent = $dirPath.DirectoryName
                                                }

                                                Set-UDElement -Id 'DirectoryTextbox' -Properties @{
                                                    value = $dirParent
                                                }

                                                Sync-UDElement -Id 'FileBrowser'
                                            }
                                        }
                                    }

                                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                        New-UDCard -Title 'Manual Search' -Content {
                                            New-UDTextbox -Id 'ManualSearchTextbox' -Placeholder 'Enter an ID/Url' -FullWidth
                                            New-UDButton -Icon $iconSearch -Variant outlined -OnClick {
                                                if (!($cache:inProgress)) {
                                                    $cache:inProgress = $true
                                                    $searchInput = (Get-UDElement -Id 'ManualSearchTextbox').value
                                                    if ($cache:findData.Id -ne (Get-UDElement -Id 'ManualSearchTextbox').value -or $cache:findData -eq $null -or $cache:findData -eq '') {
                                                        Show-UDToast -Message "Searching for [$searchInput]" -Title "Manual sort" -Duration 5000 -Position bottomRight
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
                                                            Show-UDToast -Duration 5000 -Message ($jvData | ConvertTo-Json)
                                                            $cache:findData = [PSCustomObject]@{
                                                                Data = $jvData
                                                            }
                                                        }

                                                        if ($null -eq $cache:findData) {
                                                            Show-UDToast "Id [$searchInput] not found" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                                                        }

                                                        $cache:originalFindData = $cache:findData | ConvertTo-Json
                                                        SyncPage -Sort
                                                        $cache:inProgress = $false
                                                    }
                                                } else {
                                                    Show-UDToast -Message "A job is currently running, please wait" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                                }
                                            }
                                            New-UDButton -Icon $iconTrash -Variant outlined -OnClick {
                                                $cache:findData = @()
                                                $cache:originalFindData = @()
                                                SyncPage -Sort
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
                                        New-UDCheckBox -Id 'RecurseChkbx' -Label 'Recurse' -LabelPlacement end -Checked $cache:settings.'web.sort.recurse' -OnChange {
                                            $cache:settings.'web.sort.recurse' = (Get-UDElement -Id 'RecurseChkbx').checked
                                            ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                        }
                                        New-UDCheckBox -Id 'StrictChkbx' -Label 'Strict' -LabelPlacement end -Checked $cache:settings.'web.sort.strict' -OnChange {
                                            $cache:settings.'web.sort.strict' = (Get-UDElement -Id 'StrictChkbx').checked
                                            ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                New-UDGrid -Item -ExtraSmallSize 6 -Content {
                    New-UDDynamic -Id 'AggregatedData' -Content {
                        New-UDCard -Title "Aggregated Data" -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Id -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Id)) {
                                            New-UDTextbox -Id 'dataId' -Icon $iconExclamation -Label 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                        } else {
                                            New-UDTextbox -Id 'dataId' -Label 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataId' -Label 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.ContentId -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.ContentId)) {
                                            New-UDTextbox -Id 'dataContentId' -Icon $iconExclamation -Label 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                        } else {
                                            New-UDTextbox -Id 'dataContentId' -Label 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataContentId' -Label 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.DisplayName -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.DisplayName)) {
                                            New-UDTextbox -Id 'dataDisplayName' -Icon $iconExclamation -Label 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                        } else {
                                            New-UDTextbox -Id 'dataDisplayName' -Label 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataDisplayName' -Label 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Title -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Title)) {
                                            New-UDTextbox -Id 'dataTitle' -Icon $iconExclamation -Label 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                        } else {
                                            New-UDTextbox -Id 'dataTitle' -Label 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataTitle' -Label 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.AlternateTitle -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.AlternateTitle)) {
                                            New-UDTextbox -Id 'dataAlternateTitle' -Icon $iconExclamation -Label 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                        } else {
                                            New-UDTextbox -Id 'dataAlternateTitle' -Label 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataAlternateTitle' -Label 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Description -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Description)) {
                                            New-UDTextbox -Id 'dataDescription' -Icon $iconExclamation -Label 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                        } else {
                                            New-UDTextbox -Id 'dataDescription' -Label 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataDescription' -Label 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.ReleaseDate -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.ReleaseDate)) {
                                            New-UDTextbox -Id 'dataReleaseDate' -Icon $iconExclamation -Label 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                        } else {
                                            New-UDTextbox -Id 'dataReleaseDate' -Label 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataReleaseDate' -Label 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Runtime -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Runtime)) {
                                            New-UDTextbox -Id 'dataRuntime' -Icon $iconExclamation -Label 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                        } else {
                                            New-UDTextbox -Id 'dataRuntime' -Label 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataRuntime' -Label 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Director -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Director)) {
                                            New-UDTextbox -Id 'dataDirector' -Icon $iconExclamation -Label 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                        } else {
                                            New-UDTextbox -Id 'dataDirector' -Label 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataDirector' -Label 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Maker -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Maker)) {
                                            New-UDTextbox -Id 'dataMaker' -Icon $iconExclamation -Label 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                        } else {
                                            New-UDTextbox -Id 'dataMaker' -Label 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataMaker' -Label 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Label -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Label)) {
                                            New-UDTextbox -Id 'dataLabel' -Icon $iconExclamation -Label 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                        } else {
                                            New-UDTextbox -Id 'dataLabel' -Label 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataLabel' -Label 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Series -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Series)) {
                                            New-UDTextbox -Id 'dataSeries' -Icon $iconExclamation -Label 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                        } else {
                                            New-UDTextbox -Id 'dataSeries' -Label 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataSeries' -Label 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($null -ne $cache:findData[$cache:index].Data.Tag) {
                                            if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.Tag -DifferenceObject ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Tag)) {
                                                New-UDTextbox -Id 'dataTag' -Icon $iconExclamation -Label 'Tag' -FullWidth -Value ($cache:findData[$cache:index].Data.Tag -join ' \ ')
                                            } else {
                                                New-UDTextbox -Id 'dataTag' -Label 'Tag' -FullWidth -Value ($cache:findData[$cache:index].Data.Tag -join ' \ ')
                                            }
                                        } else {
                                            New-UDTextbox -Id 'dataTag' -Label 'Tag' -FullWidth -Value ($cache:findData[$cache:index].Data.Tag -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataTag' -Label 'Tag' -FullWidth -Value ($cache:findData[$cache:index].Data.Tag -join ' \ ')
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Tagline -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Tagline)) {
                                            New-UDTextbox -Id 'dataTagline' -Icon $iconExclamation -Label 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                        } else {
                                            New-UDTextbox -Id 'dataTagline' -Label 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataTagline' -Label 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Rating.Rating -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Rating.Rating)) {
                                            New-UDTextbox -Id 'dataRating' -Icon $iconExclamation -Label 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                        } else {
                                            New-UDTextbox -Id 'dataRating' -Label 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataRating' -Label 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.Rating.Votes -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Rating.Votes)) {
                                            New-UDTextbox -Id 'dataVotes' -Icon $iconExclamation -Label 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                        } else {
                                            New-UDTextbox -Id 'dataVotes' -Label 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataVotes' -Label 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($null -ne $cache:findData[$cache:index].Data.Genre) {
                                            if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.Genre -DifferenceObject ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Genre)) {
                                                New-UDTextbox -Id 'dataGenre' -Icon $iconExclamation -Label 'Genre' -FullWidth -Value ($cache:findData[$cache:index].Data.Genre -join ' \ ')
                                            } else {
                                                New-UDTextbox -Id 'dataGenre' -Label 'Genre' -FullWidth -Value ($cache:findData[$cache:index].Data.Genre -join ' \ ')
                                            }
                                        } else {
                                            New-UDTextbox -Id 'dataGenre' -Label 'Genre' -FullWidth -Value ($cache:findData[$cache:index].Data.Genre -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataGenre' -Label 'Genre' -FullWidth -Value ($cache:findData[$cache:index].Data.Genre -join ' \ ')
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.CoverUrl -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.CoverUrl)) {
                                            New-UDTextbox -Id 'dataCoverUrl' -Icon $iconExclamation -Label 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                        } else {
                                            New-UDTextbox -Id 'dataCoverUrl' -Label 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataCoverUrl' -Label 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($null -ne $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                            if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.ScreenshotUrl -DifferenceObject ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.ScreenshotUrl)) {
                                                New-UDTextbox -Id 'dataScreenshotUrl' -Icon $iconExclamation -Label 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                            } else {
                                                New-UDTextbox -Id 'dataScreenshotUrl' -Label 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                            }
                                        } else {
                                            New-UDTextbox -Id 'dataScreenshotUrl' -Label 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataScreenshotUrl' -Label 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Data.TrailerUrl -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.TrailerUrl)) {
                                            New-UDTextbox -Id 'dataTrailerUrl' -Icon $iconExclamation -Label 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                        } else {
                                            New-UDTextbox -Id 'dataTrailerUrl' -Label 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataTrailerUrl' -Label 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    if ($cache:originalFindData) {
                                        if ($cache:findData[$cache:index].Path -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Path)) {
                                            New-UDTextbox -Id 'dataPath' -Icon $iconExclamation -Label 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path
                                        } else {
                                            New-UDTextbox -Id 'dataPath' -Label 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path
                                        }
                                    } else {
                                        New-UDTextbox -Id 'dataPath' -Label 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path
                                    }
                                }

                                New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                    New-UDButton -Icon $iconCheck -Text 'Apply' -Variant outlined -FullWidth -OnClick {
                                        if (!(Test-Path -LiteralPath (Get-UDElement -Id 'dataPath').value -PathType Leaf)) {
                                            $tempPath = (Get-UDElement -Id 'dataPath').value
                                            Show-UDToast "[$tempPath] is not a valid filepath" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                                            SyncPage -Sort
                                        } else {
                                            $cache:findData[$cache:index].Data.Id = (Get-UDElement -Id 'dataId').value
                                            $cache:findData[$cache:index].Data.ContentId = (Get-UDElement -Id 'dataContentId').value
                                            $cache:findData[$cache:index].Data.DisplayName = (Get-UDElement -Id 'dataDisplayName').value
                                            $cache:findData[$cache:index].Data.Title = (Get-UDElement -Id 'dataTitle').value
                                            $cache:findData[$cache:index].Data.AlternateTitle = (Get-UDElement -Id 'dataAlternateTitle').value
                                            $cache:findData[$cache:index].Data.Description = (Get-UDElement -Id 'dataDescription').value
                                            $cache:findData[$cache:index].Data.ReleaseDate = (Get-UDElement -Id 'dataReleaseDate').value
                                            $cache:findData[$cache:index].Data.Runtime = (Get-UDElement -Id 'dataRuntime').value
                                            $cache:findData[$cache:index].Data.Director = (Get-UDElement -Id 'dataDirector').value
                                            $cache:findData[$cache:index].Data.Maker = (Get-UDElement -Id 'dataMaker').value
                                            $cache:findData[$cache:index].Data.Label = (Get-UDElement -Id 'dataLabel').value
                                            $cache:findData[$cache:index].Data.Series = (Get-UDElement -Id 'dataSeries').value
                                            if ((Get-UDElement -Id 'dataTag').value -eq '') {
                                                $cache:findData[$cache:index].Data.Tag = $null
                                            } else {
                                                $cache:findData[$cache:index].Data.Tag = (Get-UDElement -Id 'dataTag').value -split ' \\ '
                                            }
                                            $cache:findData[$cache:index].Data.Tagline = (Get-UDElement -Id 'dataTagline').value
                                            $cache:findData[$cache:index].Data.Rating.Rating = (Get-UDElement -Id 'dataRating').value
                                            $cache:findData[$cache:index].Data.Rating.Votes = (Get-UDElement -Id 'dataVotes').value
                                            if ((Get-UDElement -Id 'dataGenre').value -eq '') {
                                                $cache:findData[$cache:index].Data.Genre = $null
                                            } else {
                                                $cache:findData[$cache:index].Data.Genre = (Get-UDElement -Id 'dataGenre').value -split ' \\ '
                                            }
                                            $cache:findData[$cache:index].Data.CoverUrl = (Get-UDElement -Id 'dataCoverUrl').value
                                            if ((Get-UDElement -Id 'dataScreenshotUrl').value -eq '') {
                                                $cache:findData[$cache:index].Data.ScreenshotUrl = $null
                                            } else {
                                                $cache:findData[$cache:index].Data.ScreenshotUrl = (Get-UDElement -Id 'dataScreenshotUrl').value -split ' \\ '
                                            }
                                            $cache:findData[$cache:index].Data.TrailerUrl = (Get-UDElement -Id 'dataTrailerUrl').value
                                            $cache:findData[$cache:index].Path = (Get-UDElement -Id 'dataPath').value
                                            #Show-UDToast -Message "[$($cache:findData[$cache:index].Data.Id)] Data was updated" -Title "Success" -TitleColor green -Duration 2000 -Position bottomRight
                                            SyncPage -Sort
                                        }
                                    }
                                }

                                New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                    New-UDButton -Icon $iconEdit -Text 'Edit (JSON)' -Variant outlined -FullWidth -OnClick {
                                        $cache:inProgress = $true
                                        Show-UDModal -FullScreen -Content {
                                            New-UDCodeEditor -Id 'AggregatedDataEditor' -HideCodeLens -Language 'json' -Height '200ch' -Width '250ch' -Theme vs-dark -Code ($cache:findData[$cache:index].Data | ConvertTo-Json)
                                        } -Header {
                                            New-UDTypography -Text (Get-UDElement -Id 'ManualSearchTextbox').value.ToUpper()
                                        } -Footer {
                                            New-UDButton -Text 'Apply and close' -OnClick {
                                                $cache:findData[$cache:index].Data = (Get-UDElement -Id 'AggregatedDataEditor').code | ConvertFrom-Json
                                                SyncPage -Sort
                                                $cache:inProgress = $false
                                                Hide-UDModal
                                                #Show-UDToast -Message "[$($cache:findData[$cache:index].Data.Id)] Data was updated" -Title "Success" -TitleColor green -Duration 2000 -Position bottomRight
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
                                                $cache:inProgress = $false
                                                Hide-UDModal
                                            }
                                        }
                                    }
                                }

                                New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                    New-UDButton -Icon $iconUndo -Text 'Reset' -Variant outlined -FullWidth -OnClick {
                                        if (($cache:findData).Length -eq 1) {
                                            $cache:findData = ($cache:originalFindData | ConvertFrom-Json)
                                            SyncPage -Sort

                                        } else {
                                            ($cache:findData)[$cache:index] = ($cache:originalFindData | ConvertFrom-Json)[$cache:index]
                                            SyncPage -Sort
                                        }
                                        #Show-UDToast -Message "[$($cache:findData[$cache:index].Data.Id)] Data was reset" -Title "Success" -TitleColor green -Duration 2000 -Position bottomRight
                                    }
                                }
                            }
                        }

                        New-UDStyle -Style '
                        .MuiCardContent-root:last-child {
                            padding-bottom: 10px;
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
                                                        New-UDButton -Icon $iconEdit -Variant outlined -FullWidth -OnClick {
                                                            $cache:inProgress = $true
                                                            Show-UDModal -Persistent -FullWidth -MaxWidth lg -Content {
                                                                New-UDCard -Title 'Edit Actress' -TitleAlignment center -Content {
                                                                    New-UDGrid -Container -Content {
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                            New-UDTextbox -Id "actressLastName$cache:index-$actressIndex" -Label 'LastName' -Value $actress.LastName -FullWidth
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                            New-UDTextbox -Id "actressFirstName$cache:index-$actressIndex" -Label 'FirstName' -Value $actress.FirstName -FullWidth
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                            New-UDTextbox -Id "actressJapaneseName$cache:index-$actressIndex" -Label 'JapaneseName' -Value $actress.JapaneseName -FullWidth
                                                                        }
                                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                            New-UDTextbox -Id "actressThumbUrl$cache:index-$actressIndex" -Label 'ThumbUrl' -Value $actress.ThumbUrl -FullWidth
                                                                        }
                                                                    }
                                                                }
                                                            } -Footer {
                                                                New-UDButton -Id 'addActressBtn' -Text 'Apply and close' -Variant outlined -FullWidth -OnClick {
                                                                    Set-UDElement -Id 'addActressBtn' -Properties @{
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
                                                                    $cache:inProgress = $false
                                                                }
                                                                New-UDButton -Text 'Remove' -Variant outlined -FullWidth -OnClick {
                                                                    $origJapaneseName = ((Get-UDElement -Id "origActressJapaneseName$cache:index-$actressIndex").value)
                                                                    (($cache:findData)[$cache:index]).Data.Actress = (($cache:findData)[$cache:index]).Data.Actress | Where-Object { $_.JapaneseName -ne $origJapaneseName }
                                                                    Hide-UDModal
                                                                    SyncPage -Sort
                                                                    $cache:inProgress = $false
                                                                }
                                                                New-UDButton -Text 'Cancel' -Variant outlined -FullWidth -OnClick {
                                                                    SyncPage -Sort
                                                                    Hide-UDModal
                                                                    $cache:inProgress = $false
                                                                }
                                                            }
                                                        }
                                                    }
                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                            New-UDTextbox -Id "origActressName$cache:index-$actressIndex" -Label 'Name' -Value "$($actress.LastName) $($actress.FirstName)" -Disabled
                                                        }

                                                        New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                            New-UDTextbox -Id "origActressJapaneseName$cache:index-$actressIndex" -Label 'JapanseName' -Value $actress.JapaneseName -Disabled
                                                        }

                                                    }
                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                        New-UDImage -Url $actress.ThumbUrl -Height 125
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
                                                    New-UDButton -Icon $iconPlus -Text 'Add' -Variant outlined -FullWidth -OnClick {
                                                        $cache:inProgress = $true
                                                        Show-UDModal -FullWidth -MaxWidth lg -Content {
                                                            New-UDCard -Title 'Add Actress' -TitleAlignment center -Content {
                                                                New-UDGrid -Container -Content {
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "newActressLastName" -Label 'LastName' -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "newActressFirstName" -Label 'FirstName' -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "newActressJapaneseName" -Label 'JapaneseName' -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "newActressThumbUrl" -Label 'ThumbUrl' -FullWidth
                                                                    }
                                                                }
                                                            }
                                                        } -Footer {
                                                            New-UDButton -Id 'addActressBtn' -Text 'Apply and close' -Variant outlined -FullWidth -OnClick {
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

                                                                ((($cache:findData)[$cache:index]).Data.Actress) += $newActress

                                                                SyncPage -Sort
                                                                Hide-UDModal
                                                                $cache:inProgress = $false

                                                            }
                                                            New-UDButton -Text 'Cancel' -Variant outlined -FullWidth -OnClick {
                                                                SyncPage -Sort
                                                                Hide-UDModal
                                                                $cache:inProgress = $false
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


        New-UDTab -Text 'Settings' -Dynamic -Content {
            $locationSettings = @(
                'Input',
                'Output',
                'ThumbCsv',
                'GenreCsv',
                'UncensorCsv',
                'Log'
            )

            $scraperSettings = @(
                'Dmm',
                'DmmJa',
                'Javlibrary',
                'JavlibraryJa',
                'JavlibraryZh',
                'R18',
                'R18Zh',
                'Javbus',
                'JavbusJa',
                'JavbusZh',
                'Jav321Ja'
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
                'javlibrary.cookie.userid'
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
                'sort.metadata.nfo.format.tagline'
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
                'sort.metadata.nfo.translatedescription',
                'sort.metadata.nfo.firstnameorder',
                'sort.metadata.nfo.actresslanguageja',
                'sort.metadata.nfo.unknownactress',
                'sort.metadata.nfo.originalpath',
                'sort.metadata.thumbcsv',
                'sort.metadata.thumbcsv.autoadd',
                'sort.metadata.thumbcsv.convertalias',
                'sort.metadata.genrecsv'
            )

            <# $translateLanguages = @(
                'am',
                'ar',
                'eu',
                'bn',
                'en-GB',
                'pt-BR',
                'bg',
                'ca',
                'chr',
                'hr',
                'cs',
                'da',
                'nl',
                'en',
                'et',
                'fil',
                'fi',
                'fr',
                'de',
                'el',
                'gu',
                'iw',
                'hi',
                'hu',
                'is',
                'id',
                'it',
                'ja',
                'kn',
                'ko',
                'lv',
                'lt',
                'ms',
                'ml',
                'mr',
                'no',
                'pl',
                'pt-PT',
                'ro',
                'ru',
                'sr',
                'zh-CN',
                'sk',
                'sl',
                'es',
                'sw',
                'sv',
                'ta',
                'te',
                'th',
                'zh-TW',
                'tr',
                'ur',
                'uk',
                'vi',
                'cy'
            ) #>

            New-UDDynamic -Id 'SettingsTab' -Content {
                New-UDGrid -Container -Content {
                    ## Left Column
                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                        New-UDCard -Content {
                            New-UDButton -Icon $iconCheck -Text 'Apply' -Size large -Variant outlined -OnClick {
                                foreach ($scraper in $scraperSettings) {
                                    $cache:settings."scraper.movie.$scraper" = (Get-UDElement -Id "SettingChkbx$scraper").checked
                                }
                                foreach ($field in $prioritySettings) {
                                    $cache:settings."sort.metadata.priority.$field" = ((Get-UDElement -Id "SettingTextbox$field").value -split ' \\ ')
                                }
                                foreach ($setting in $locationSettings) {
                                    $cache:settings."location.$setting" = ((Get-UDElement -Id "SettingTextboxLocation$setting")).value
                                }

                                foreach ($setting in $sortSettings) {
                                    $cache:settings."$setting" = (Get-UDElement -Id "$setting").checked
                                }

                                foreach ($setting in $formatStringSettings) {
                                    if ($setting -eq 'sort.format.posterimg' -or $setting -eq 'sort.metadata.nfo.format.tag') {
                                        $cache:settings."$setting" = ((Get-UDElement -Id "$setting").value -split ' \\ ')
                                    } else {
                                        $cache:settings."$setting" = (Get-UDElement -Id "$setting").value
                                    }
                                }

                                $cache:settings.'sort.metadata.requiredfield' = ((Get-UDElement -Id 'sort.metadata.requiredfield').value -split ' \\ ' )
                                $cache:settings.'scraper.option.idpreference' = (Get-UDElement -Id 'scraperoptionidpreference').value
                                $cache:settings.'scraper.option.dmm.scrapeactress' = (Get-UDElement -Id 'scraper.option.dmm.scrapeactress').checked
                                $cache:settings.'match.minimumfilesize' = [Int](Get-UDElement -Id 'match.minimumfilesize').value
                                #$cache:settings.'match.includedfileextension' = ((Get-UDElement -Id 'matchincludedfileextension').value -split '\\')
                                #$cache:settings.'match.excludedfilestring' = ((Get-UDElement -Id 'matchexcludedfilestring').value -split '\\')
                                $cache:settings.'match.regex' = (Get-UDElement -Id 'match.regex').checked
                                $cache:settings.'match.regex.string' = (Get-UDElement -Id 'matchregexstring').value
                                $cache:settings.'match.regex.idmatch' = (Get-UDElement -Id 'matchregexidmatch').value
                                $cache:settings.'match.regex.ptmatch' = (Get-UDElement -Id 'matchregexptmatch').value
                                $cache:settings.'sort.maxtitlelength' = [Int](Get-UDElement -Id 'sort.maxtitlelength').value
                                $cache:settings.'sort.metadata.nfo.translatedescription.language' = (Get-UDElement -Id 'sortmetadatanfotranslatedescriptionlanguage').value
                                $cache:settings.'admin.log' = (Get-UDElement -Id 'admin.log').checked
                                $cache:settings.'admin.log.level' = (Get-UDElement -Id 'adminloglevel').value
                                $cache:settings | ConvertTo-Json | Out-File $cache:settingsPath
                                $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
                                Show-UDToast -Message "Settings updated" -Title "Success" -TitleColor green -Duration 2000 -Position bottomRight

                            }

                            New-UDButton -Icon $iconEdit -Text 'Edit (JSON)' -Size large -Variant outlined -OnClick {
                                $cache:inProgress = $true
                                Show-UDModal -FullScreen -Content {
                                    $settingsContent = (Get-Content -LiteralPath $cache:settingsPath) -join "`r`n"
                                    New-UDCodeEditor -Id 'SettingsEditor' -HideCodeLens -Language 'json' -Height '200ch' -Width '250ch' -Theme vs-dark -Code $settingsContent

                                } -Header {
                                    "jvSettings.json"
                                } -Footer {
                                    New-UDButton -Text 'Apply and close' -OnClick {
                                        (Get-UDElement -Id 'SettingsEditor').code | Out-File $cache:settingsPath -Force
                                        SyncPage -Settings
                                        Hide-UDModal
                                        $cache:inProgress = $false
                                        Show-UDToast -Message "Settings updated" -Title "Success" -TitleColor green -Duration 2000 -Position bottomRight
                                    }
                                    New-UDButton -Text "Cancel" -OnClick {
                                        SyncPage -Settings
                                        Hide-UDModal
                                        $cache:inProgress = $false
                                    }
                                }
                            }
                            New-UDButton -Icon $iconUndo -Text 'Reset' -Size large -Variant outlined -OnClick {
                                $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
                                SyncPage -Settings
                            }
                        }

                        ## Scrapers card
                        New-UDCard -Title 'Scrapers' -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Container -Content {
                                    foreach ($scraper in $scraperSettings) {
                                        New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                            New-UDCheckBox -Label $scraper -Id "SettingChkbx$scraper" -LabelPlacement end -Checked ($cache:settings."scraper.movie.$scraper")
                                        }
                                    }
                                }

                                New-UDCard -Title 'Options' -Content {
                                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                        New-UDCheckBox -Label 'Scrape DMM Actress' -Id 'scraper.option.dmm.scrapeactress' -LabelPlacement end -Checked ($cache:settings.'scraper.option.dmm.scrapeactress')
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                        New-UDTypography -Variant 'body2' -Text 'ID Preference'
                                        New-UDAutocomplete -Id 'scraperoptionidpreference' -Options @('id', 'contentid') -Value ($cache:settings.'scraper.option.idpreference')
                                    }

                                }
                            }
                        }

                        ## Scraper priorities card
                        New-UDCard -Title 'Metadata Priorities' -Content {
                            New-UDGrid -Container -Content {
                                ## Field priorities
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDGrid -Container -Content {
                                        foreach ($field in $prioritySettings) {
                                            New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                                New-UDTextbox -Label $field -Id "SettingTextbox$field" -Value ($cache:settings."sort.metadata.priority.$field" -join ' \ ') -FullWidth
                                            }
                                        }
                                        New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Label 'Required Fields' -Id 'sort.metadata.requiredfield' -Value ($cache:settings."sort.metadata.requiredfield" -join ' \ ') -FullWidth
                                        }
                                    }
                                }
                            }
                        }

                        New-UDCard -Title 'File Matcher' -Content {
                            New-UDGrid -Container -Content {
                                ## Field priorities
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDGrid -Container -Content {
                                        New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Label 'match.minimumfilesize' -Id 'match.minimumfilesize' -Value ($cache:settings.'match.minimumfilesize') -FullWidth
                                        }
                                        New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Label 'match.includedfileextension' -Id 'matchincludedfileextension' -Value ($cache:settings.'match.includedfileextension' -join ' \ ') -FullWidth -Disabled
                                        }
                                        New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Label 'match.excludedfilestring' -Id 'matchexcludedfilestring' -Value ($cache:settings.'match.excludedfilestring' -join ' \ ') -FullWidth -Disabled
                                        }
                                    }
                                    New-UDGrid -Container -Content {
                                        New-UDCard -Title 'Regex' -Content {
                                            New-UDGrid -Container -Content {
                                                New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                                    New-UDCheckBox -Label 'match.regex' -Id 'match.regex' -Checked ($cache:settings.'match.regex')
                                                }
                                                New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                                    New-UDTextbox -Label 'match.regex.string' -Id 'matchregexstring' -Value ($cache:settings.'match.regex.string') -FullWidth -Disabled
                                                }
                                                New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                                    New-UDTextbox -Label 'match.regex.idmatch' -Id 'matchregexidmatch' -Value ($cache:settings.'match.regex.idmatch') -FullWidth
                                                }
                                                New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                                    New-UDTextbox -Label 'match.regex.ptmatch' -Id 'matchregexptmatch' -Value ($cache:settings.'match.regex.ptmatch') -FullWidth
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        New-UDCard -Title 'Admin' -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                    New-UDCheckBox -Id 'admin.log' -Label 'admin.log' -LabelPlacement end -Checked ($cache:settings.'admin.log')
                                }
                                New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                    New-UDTypography -Variant 'body2' -Text 'admin.log.level'
                                    New-UDAutocomplete -Id 'adminloglevel' -Options @('debug', 'info', 'warning', 'error') -Value ($cache:settings.'admin.log.level')
                                }
                            }
                        }
                    }

                    ## Right column
                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                        New-UDCard -Title 'Locations' -Content {
                            New-UDGrid -Container -Content {
                                foreach ($setting in $locationSettings) {
                                    New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTextbox -Label $setting -Id "SettingTextboxLocation$setting" -Value ($cache:settings."location.$setting") -FullWidth
                                    }
                                }
                            }
                        }

                        ## Metadata options card
                        New-UDCard -Title 'Sort' -Content {
                            New-UDGrid -Container -Content {
                                foreach ($setting in $sortSettings) {
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDCheckBox -Label $setting -Id "$setting" -LabelPlacement end -Checked ($cache:settings."$setting")
                                    }
                                }
                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                        #New-UDTypography -Variant 'body2' -Text 'Translate Language'
                                        New-UDTextbox -Id 'sortmetadatanfotranslatedescriptionlanguage' -Label 'Translate Language' -Value ($cache:settings.'sort.metadata.nfo.translatedescription.language') -FullWidth
                                        #New-UDAutocomplete -Id 'sortmetadatanfotranslatedescriptionlanguage' -Options $translateLanguages -Value ($cache:settings.'sort.metadata.nfo.translatedescription.language')
                                    }

                                    New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTextbox -Id 'sort.maxtitlelength' -Label 'sort.maxtitlelength' -Value ($cache:settings.'sort.maxtitlelength') -FullWidth
                                    }
                                }
                            }
                        }

                        New-UDCard -Title 'Format Strings' -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDGrid -Container -Content {
                                        foreach ($setting in $formatStringSettings) {
                                            New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                                if ($setting -eq 'sort.format.posterimg' -or $setting -eq 'sort.metadata.nfo.format.tag') {
                                                    New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting" -join ' \ ') -FullWidth
                                                } else {
                                                    New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        New-UDCard -Title 'Emby/Jellyfin' -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDGrid -Container -Content {
                                        foreach ($setting in $embySettings) {
                                            New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
                                                New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        New-UDCard -Title 'Javlibrary' -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDGrid -Container -Content {
                                        foreach ($setting in $javlibrarySettings) {
                                            New-UDGrid -Item -SmallSize 12 -MediumSize 6 -Content {
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

        New-UDTab -Text 'Log' -Dynamic -Content {
            $rawLog = (Get-Content -LiteralPath '/home/Javinizer/src/Javinizer/jvLog.log')
            $fullLog = $rawLog -join "`n"
            $recentLog = ($rawLog | Select-Object -Last 50) -join "`n"
            #$log = $rawLog[($rawLog.Count - 1)..0] -join "`n"
            #New-UDCheckBox -Id 'logAutoRefreshChkbx' -Label 'Autorefresh' -LabelPlacement end
            #New-UDTextbox -Id 'logAutoRefreshInterval' -Label 'Every how many seconds' -Placeholder '5'
            #$cache:logAutoRefresh = (Get-UDElement -Id "logAutoRefreshChkbx")['checked']
            #$cache:logAutoRefreshInterval = [Int](Get-UDElement -Id 'logAutoRefreshInterval').value
            New-UDButton -Text 'Refresh' -OnClick {
                Sync-UDElement -Id 'LogEditor'
            }
            New-UDButton -Text 'View Full Log' -OnClick {
                $cache:inProgress = $true
                Show-UDModal -FullScreen -Content {
                    New-UDCodeEditor -Id 'FullLogEditor' -HideCodeLens -Language 'powershell' -Height '175ch' -Width '175ch' -Theme vs-dark -ReadOnly -Code $fullLog
                } -Footer {
                    New-UDButton 'Close' -OnClick {
                        Hide-UDModal
                        $cache:inProgress = $false
                    }
                }
            }
            New-UDTypography -Variant h5 -Text "Last 50 Entries"
            New-UDDynamic -Content {
                New-UDGrid -Container -Content {
                    New-UDCodeEditor -Id 'LogEditor' -HideCodeLens -Language 'powershell' -Height '150ch' -Width '250ch' -Theme vs-dark -ReadOnly -Code $recentLog
                }
            }
        }
    }
}
