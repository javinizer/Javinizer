$cache:actressArray = @()
$cache:actressObject = Import-Csv $cache:thumbCsvPath | Sort-Object FullName
$cache:actressArray += $cache:actressObject | ForEach-Object { "$($_.FullName) ($($_.JapaneseName)) [$actressIndex]"; $actressIndex++ }
$cache:inProgress = $false
$cache:inProgressEmby = $false
$cache:findData = @()
$cache:originalFindData = @()
$cache:filePath = ''
$cache:index = 0
$cache:currentIndex = 0
$actressIndex = 0
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
        [Parameter()]
        [Switch]$Sort,

        [Parameter()]
        [Switch]$Settings,

        [Parameter()]
        [Switch]$ClearData,

        [Parameter()]
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
        Sync-UDElement -Id 'dynamic-sort-aggregateddata'
        Sync-UDElement -Id 'dynamic-sort-coverimage'
        Sync-UDElement -Id 'dynamic-sort-movieselect'
    }

    if ($Settings) {
        Sync-UDElement -Id 'dynamic-settings-page'
    }
}

function InProgress {
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
                        # The runspace that we want to close is created from Invoke-JVParallel
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
                                InProgress -Off
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
                                InProgress -Off
                            }
                        }
                    }
                }
            }
        }
    }
}

function JavinizerSearch {
    [CmdletBinding()]
    param(
        [Parameter()]
        [PSObject]$Item,

        [Parameter()]
        [String]$Path
    )

    if (!($cache:inProgress)) {
        InProgress -Sort
        $recurse = (Get-UDElement -Id 'checkbox-sort-recurse').checked
        $strict = (Get-UDElement -Id 'checkbox-sort-strict').checked
        $update = (Get-UDElement -Id 'checkbox-sort-update').checked
        $interactive = (Get-UDElement -Id 'checkbox-sort-interactive').checked
        $force = (Get-UDElement -Id 'checkbox-sort-force').checked

        if ($interactive) {
            SyncPage -ClearData
            if ($Path) {
                $Item = (Get-Item -LiteralPath $Path)
            }
            if ($Item.Mode -like 'd*') {
                # Show-UDToast -CloseOnClick -Message "Searching [$($Item.FullName)]" -Title 'Multi Sort' -Duration 5000 -Position bottomRight
                $cache:searchTotal = ($cache:settings | Get-JVItem -Path $Item.FullName -Recurse:$recurse -Strict:$strict).Count
                $jvData = Javinizer -Path $Item.FullName -Recurse:$recurse -Strict:$strict -HideProgress -IsWeb -IsWebType 'Search'
                if ($null -ne $jvData) {
                    #$cache:findData = ($jvData | Where-Object { $null -ne $_.Data })
                    $cache:findData = ($jvData | Sort-Object { $_.Data.Id })
                } else {
                    Show-UDToast -CloseOnClick "No movies matched" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                }
            } else {
                $movieId = ($cache:settings | Get-JVItem -Path $Item.FullName).Id
                Set-UDElement -Id 'textbox-sort-manualsearch' -Properties @{
                    value = $movieId
                }
                # Show-UDToast -CloseOnClick -Message "Searching for [$($Item.FullName)]" -Title 'Single Sort' -Duration 5000 -Position bottomRight
                $jvData = Javinizer -Path $Item.FullName -Strict:$strict -HideProgress -IsWeb -IsWebType 'Search'
                if ($null -ne $jvData) {
                    $cache:findData = $jvData
                } else {
                    Show-UDToast -CloseOnClick "[$movieId] not matched" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
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
        SyncPage -Sort -ClearProgress
        InProgress -Off
    } else {
        Show-UDToast -CloseOnClick -Message "A job is currently running, please wait." -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
    }
}

New-UDPage -Name "Sort" -Content {
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
                                            SyncPage -Sort
                                        } catch {
                                            $index = $cache:index
                                            if ($findDataArray -notcontains 'Empty') {
                                                Show-UDModal -FullWidth -MaxWidth xl -Persistent -Content {
                                                    New-UDTypography -Variant h6 -Text "Remove this movie from the current sort?"
                                                    New-UDList -Children {
                                                        New-UDListItem -Label 'Id' -SubTitle "$($cache:findData[$cache:index].Data.Id)"
                                                        New-UDListItem -Label 'Path' -SubTitle "$($cache:findData[$cache:index].Path)"
                                                    }
                                                } -Footer {
                                                    New-UDButton -Text 'Ok' -OnClick {
                                                        [Int]$findDataIndex = $cache:index
                                                        if ((($cache:findData).Count) -gt 1) {
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
                                                        if ($findDataIndex -eq 0) {
                                                            $cache:index = 0
                                                        } else {
                                                            $cache:index = $findDataIndex - 1
                                                        }
                                                        SyncPage -Sort
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
                                        SyncPage -Sort #>
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
                                            $force = (Get-UDElement -Id 'checkbox-sort-force').checked
                                            $update = (Get-UDElement -Id 'checkbox-sort-update').checked
                                            if (!($cache:inProgress)) {
                                                InProgress -Generic -NoCancel
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
                                                        Write-JVWebLog -HistoryPath $cache:historyPath -OriginalPath $cache:findData[$cache:index].Path -DestinationPath $sortData.Path.FilePath -Data $cache:findData[$cache:index].Data
                                                    }
                                                    # Remove the movie after it's committed
                                                    $cache:findData = $cache:findData | Where-Object { $_.Path -ne $moviePath }
                                                    $cache:originalFindData = (($cache:originalFindData | ConvertFrom-Json) | Where-Object { $_.Path -ne $moviePath }) | ConvertTo-Json -Depth 32

                                                    if ($cache:index -gt 0) {
                                                        $cache:index -= 1
                                                    }
                                                } catch {
                                                    Show-UDToast -CloseOnClick -Message "$PSItem" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                                }
                                                SyncPage -Sort
                                                InProgress -Off
                                            } else {
                                                Show-UDToast -CloseOnClick -Message "A job is currently running, please wait." -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                            }
                                        }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 3 -SmallSize 3 -MediumSize 3 -Content {
                                        New-UDButton -Icon $iconFastForward -FullWidth -OnClick {
                                            $force = (Get-UDElement -Id 'checkbox-sort-force').checked
                                            $update = (Get-UDElement -Id 'checkbox-sort-update').checked
                                            if (!($cache:inProgress)) {
                                                InProgress -Sort
                                                $jvModulePath = $cache:fullModulePath
                                                $tempSettings = $cache:settings
                                                $tempHistoryPath = $cache:historyPath
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
                                                    Show-UDToast -CloseOnClick -Message "$PSItem" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
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
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                New-UDButton -Text 'Grid View' -FullWidth -OnClick {
                                    Show-UDModal -FullScreen -Content {
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

                                                                    New-UDTextbox -Placeholder 'Id' -Value $movie.Data.Id -Disabled -FullWidth
                                                                    New-UDTextbox -Placeholder 'Genre' -Value (($movie.Data.Genre | Sort-Object) -join ' \ ') -Disabled -FullWidth
                                                                    New-UDTextbox -Placeholder 'Actors' -Value $actorList -Disabled -FullWidth
                                                                    New-UDTextbox -Placeholder 'FilePath' -Value $movie.Path -Disabled -FullWidth
                                                                }
                                                                New-UDGrid -Item -ExtraSmallSize 9 -SmallSize 9 -Content {
                                                                    New-UDButton -Text 'Select' -Size small -FullWidth -OnClick {
                                                                        $cache:index = $count
                                                                        SyncPage -Sort
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

                                                                        SyncPage -Sort
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
                                            Show-UDModal -FullWidth -MaxWidth lg -Content {
                                                New-UDPlayer -URL $cache:findData[$cache:index].Data.TrailerUrl -Width '550px'
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
                                New-UDTextbox -Id 'textbox-sort-filepath' -Placeholder 'Enter a path' -Value $cache:settings.'location.input' -FullWidth
                            }
                            New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 6 -MediumSize 2 -Content {
                                New-UDButton -Icon $iconSearch -FullWidth -OnClick {
                                    JavinizerSearch -Path (Get-UDElement -Id 'textbox-sort-filepath').value
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 6 -SmallSize 6 -MediumSize 2 -Content {
                                New-UDButton -Icon $iconTrash -FullWidth -OnClick {
                                    Show-UDModal -FullWidth -MaxWidth lg -Content {
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                            New-UDTypography -Variant h6 -Text "Remove all movies from the current sort?"
                                        }
                                    } -Footer {
                                        New-UDButton -Text 'Ok' -OnClick {
                                            SyncPage -Sort -ClearData
                                            Hide-UDModal
                                        }
                                        New-UDButton -Text 'Cancel'  -OnClick {
                                            Hide-UDModal
                                        }
                                    }
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                New-UDCheckBox -Id 'checkbox-sort-interactive' -Label 'Interactive' -LabelPlacement end -Checked $cache:settings.'web.sort.interactive' -OnChange {
                                    $cache:settings.'web.sort.interactive' = (Get-UDElement -Id 'checkbox-sort-interactive').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                }
                                New-UDCheckBox -Id 'checkbox-sort-recurse' -Label 'Recurse' -LabelPlacement end -Checked $cache:settings.'web.sort.recurse' -OnChange {
                                    $cache:settings.'web.sort.recurse' = (Get-UDElement -Id 'checkbox-sort-recurse').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                }
                                New-UDCheckBox -Id 'checkbox-sort-strict' -Label 'Strict' -LabelPlacement end -Checked $cache:settings.'web.sort.strict' -OnChange {
                                    $cache:settings.'web.sort.strict' = (Get-UDElement -Id 'checkbox-sort-strict').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                }
                                New-UDCheckBox -Id 'checkbox-sort-update' -Label 'Update' -LabelPlacement end -Checked $cache:settings.'web.sort.update' -OnChange {
                                    $cache:settings.'web.sort.update' = (Get-UDElement -Id 'checkbox-sort-update').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                }
                                New-UDCheckBox -Id 'checkbox-sort-force' -Label 'Force' -LabelPlacement end -Checked $cache:settings.'web.sort.force' -OnChange {
                                    $cache:settings.'web.sort.force' = (Get-UDElement -Id 'checkbox-sort-force').checked
                                    ($cache:settings | ConvertTo-Json) | Out-File -LiteralPath $cache:settingsPath
                                }
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
                                New-UDDynamic -Id 'dynamic-sort-filebrowser' -Content {
                                    $cache:filePath = (Get-UDElement -Id 'textbox-sort-directorypath').value
                                    $search = Get-ChildItem -LiteralPath $cache:filePath | Select-Object Name, Length, FullName, Mode, Extension, LastWriteTime | ConvertTo-Json | ConvertFrom-Json
                                    $searchColumns = @(
                                        New-UDTableColumn -Property Name -Title 'Name' -Render {
                                            if ($EventData.Mode -like 'd*') {
                                                New-UDButton -Icon (New-UDIcon -Icon folder_open_o) -IconAlignment left -Text "$($EventData.Name)" -Variant 'text' -FullWidth -OnClick {
                                                    Set-UDElement -Id 'textbox-sort-directorypath' -Properties @{
                                                        value = $EventData.FullName
                                                    }
                                                    Set-UDElement -Id 'textbox-sort-filepath' -Properties @{
                                                        value = $EventData.FullName
                                                    }
                                                    Sync-UDElement -Id 'dynamic-sort-filebrowser'
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
                                        New-UDTableColumn -Property FullName -Title 'Sort' -Render {
                                            $includedExtensions = $cache:settings.'match.includedfileextension'
                                            if (($EventData.Mode -like 'd*') -or (($EventData.Extension -in $includedExtensions) -and ($EventData.Length -ge ($cache:settings.'match.minimumfilesize')) -and ($EventData.Name -notmatch ($cache:settings.'match.excludedfilestring')))) {
                                                New-UDButton -Icon $iconPlay -IconAlignment left -Text 'Sort' -Variant 'text' -OnClick {
                                                    JavinizerSearch -Item $EventData
                                                }
                                            } else {
                                                New-UDTypography -Text ''
                                            }
                                        }
                                    )

                                    <#  .MuiButton-outlined {
                                        border: 0;
                                    }
                                    .MuiButtonBase-root {
                                            letter-spacing = initial !important;
                                            display: contents;
                                        }
                                    #>

                                    New-UDStyle -Style '
                                        .MuiTypography-caption {
                                            font-size: initial !important;
                                        }

                                        .MuiTableCell-root {
                                            padding: 12px;
                                            border-bottom: 1px solid rgba(81, 81, 81, 1);
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
                                        New-UDTable -Data $search -Columns $searchColumns -Title "$cache:filePath" -Padding dense -Sort -Search -PageSize $cache:tablePageSize -PageSizeOptions @('')
                                    }
                                }

                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                                        New-UDCard -Title 'Navigation' -Content {
                                            if ($cache:filePath -eq '' -or $null -eq $cache:filePath) {
                                                $dir = $cache:settings.'location.input'
                                            } else {
                                                $dir = $cache:filePath
                                            }
                                            New-UDTextbox -Id 'textbox-sort-directorypath' -Placeholder 'Enter a directory' -Value $dir -FullWidth
                                            New-UDButton -Icon $iconSearch -OnClick {
                                                $cache:filePath = (Get-UDElement -Id 'textbox-sort-directorypath').value

                                                if (!(Test-Path -LiteralPath $cache:filePath)) {
                                                    Show-UDToast -CloseOnClick "[$cache:filePath] is not a valid path" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                                                }

                                                Sync-UDElement -Id 'dynamic-sort-filebrowser'
                                            }

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

                                                Set-UDElement -Id 'textbox-sort-directorypath' -Properties @{
                                                    value = $dirParent
                                                }

                                                Set-UDElement -Id 'textbox-sort-filepath' -Properties @{
                                                    value = $dirParent
                                                }

                                                Sync-UDElement -Id 'dynamic-sort-filebrowser'
                                            }
                                        }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                        [String]$pageSize = $cache:tablePageSize
                                        New-UDSelect -Id 'select-sort-pagesize' -Label 'PageSize' -DefaultValue $pageSize -Option {
                                            $pageSizeOptions = @('5', '10', '20', '50', '100')
                                            foreach ($option in $pageSizeOptions) {
                                                New-UDSelectOption -Name $option -Value $option
                                            }
                                        } -OnChange {
                                            $cache:tablePageSize = (Get-UDElement -Id 'select-sort-pagesize').value
                                            Sync-UDElement -Id 'dynamic-sort-filebrowser'
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
                    New-UDCard -Title "Aggregated Data" -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Path -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Path)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-filepath' -Icon $iconExclamation -Placeholder 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-filepath' -Placeholder 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-filepath' -Placeholder 'FilePath' -FullWidth -Value $cache:findData[$cache:index].Path
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Id -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Id)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-id' -Icon $iconExclamation -Placeholder 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-id' -Placeholder 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-id' -Placeholder 'Id' -FullWidth -Value $cache:findData[$cache:index].Data.Id
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.ContentId -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.ContentId)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-contentid' -Icon $iconExclamation -Placeholder 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-contentid' -Placeholder 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-contentid' -Placeholder 'ContentId' -FullWidth -Value $cache:findData[$cache:index].Data.ContentId
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.DisplayName -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.DisplayName)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-displayname' -Icon $iconExclamation -Placeholder 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-displayname' -Placeholder 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-displayname' -Placeholder 'DisplayName' -FullWidth -Value $cache:findData[$cache:index].Data.DisplayName
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Title -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Title)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-title' -Icon $iconExclamation -Placeholder 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-title' -Placeholder 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-title' -Placeholder 'Title' -FullWidth -Value $cache:findData[$cache:index].Data.Title
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.AlternateTitle -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.AlternateTitle)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-alternatetitle' -Icon $iconExclamation -Placeholder 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-alternatetitle' -Placeholder 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-alternatetitle' -Placeholder 'AlternateTitle' -FullWidth -Value $cache:findData[$cache:index].Data.AlternateTitle
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Description -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Description)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-description' -Icon $iconExclamation -Placeholder 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-description' -Placeholder 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-description' -Placeholder 'Description' -FullWidth -Value $cache:findData[$cache:index].Data.Description
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.ReleaseDate -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.ReleaseDate)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-releasedate' -Icon $iconExclamation -Placeholder 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-releasedate' -Placeholder 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-releasedate' -Placeholder 'ReleaseDate' -FullWidth -Value $cache:findData[$cache:index].Data.ReleaseDate
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Runtime -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Runtime)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-runtime' -Icon $iconExclamation -Placeholder 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-runtime' -Placeholder 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-runtime' -Placeholder 'Runtime' -FullWidth -Value $cache:findData[$cache:index].Data.Runtime
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Director -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Director)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-director' -Icon $iconExclamation -Placeholder 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-director' -Placeholder 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-director' -Placeholder 'Director' -FullWidth -Value $cache:findData[$cache:index].Data.Director
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Maker -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Maker)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-maker' -Icon $iconExclamation -Placeholder 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-maker' -Placeholder 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-maker' -Placeholder 'Maker' -FullWidth -Value $cache:findData[$cache:index].Data.Maker
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Label -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Label)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-label' -Icon $iconExclamation -Placeholder 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-label' -Placeholder 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-label' -Placeholder 'Label' -FullWidth -Value $cache:findData[$cache:index].Data.Label
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Series -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Series)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-series' -Icon $iconExclamation -Placeholder 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-series' -Placeholder 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-series' -Placeholder 'Series' -FullWidth -Value $cache:findData[$cache:index].Data.Series
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($null -ne $cache:findData[$cache:index].Data.Tag) {
                                        if ($null -ne ($cache:originalFindData | ConvertFrom-Json)[$cache:index].Data.Tag) {
                                            if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.Tag -DifferenceObject ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Tag)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Icon $iconExclamation -Placeholder 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Placeholder 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Icon $iconExclamation -Placeholder 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Placeholder 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-tag' -Placeholder 'Tag' -FullWidth -Value (($cache:findData[$cache:index].Data.Tag | Sort-Object) -join ' \ ')
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Tagline -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Tagline)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-tagline' -Icon $iconExclamation -Placeholder 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-tagline' -Placeholder 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-tagline' -Placeholder 'Tagline' -FullWidth -Value $cache:findData[$cache:index].Data.Tagline
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Rating.Rating -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Rating.Rating)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-rating' -Icon $iconExclamation -Placeholder 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-rating' -Placeholder 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-rating' -Placeholder 'Rating' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Rating
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.Rating.Votes -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Rating.Votes)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-votes' -Icon $iconExclamation -Placeholder 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-votes' -Placeholder 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-votes' -Placeholder 'Votes' -FullWidth -Value $cache:findData[$cache:index].Data.Rating.Votes
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($null -ne $cache:findData[$cache:index].Data.Genre) {
                                        if ($null -ne ($cache:originalFindData | ConvertFrom-Json)[$cache:index].Data.Genre) {
                                            if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.Genre -DifferenceObject ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.Genre)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Icon $iconExclamation -Placeholder 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Placeholder 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Icon $iconExclamation -Placeholder 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Placeholder 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-genre' -Placeholder 'Genre' -FullWidth -Value (($cache:findData[$cache:index].Data.Genre | Sort-Object) -join ' \ ')
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.CoverUrl -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.CoverUrl)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-coverurl' -Icon $iconExclamation -Placeholder 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-coverurl' -Placeholder 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-coverurl' -Placeholder 'CoverUrl' -FullWidth -Value $cache:findData[$cache:index].Data.CoverUrl
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($null -ne $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                        if ($null -ne ($cache:originalFindData | ConvertFrom-Json)[$cache:index].Data.ScreenshotUrl) {
                                            if (Compare-Object -ReferenceObject $cache:findData[$cache:index].Data.ScreenshotUrl -DifferenceObject ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.ScreenshotUrl)) {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Icon $iconExclamation -Placeholder 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                            } else {
                                                New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Placeholder 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                            }
                                        } else {
                                            New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Icon $iconExclamation -Placeholder 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                        }
                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Placeholder 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-screenshoturl' -Placeholder 'ScreenshotUrl' -FullWidth -Value ($cache:findData[$cache:index].Data.ScreenshotUrl -join ' \ ')
                                }
                            }
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                if ($cache:originalFindData) {
                                    if ($cache:findData[$cache:index].Data.TrailerUrl -ne ((($cache:originalFindData | ConvertFrom-Json)[$cache:index]).Data.TrailerUrl)) {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-trailerurl' -Icon $iconExclamation -Placeholder 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl

                                    } else {
                                        New-UDTextbox -Id 'textbox-sort-aggregateddata-trailerurl' -Placeholder 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                    }
                                } else {
                                    New-UDTextbox -Id 'textbox-sort-aggregateddata-trailerurl' -Placeholder 'TrailerUrl' -FullWidth -Value $cache:findData[$cache:index].Data.TrailerUrl
                                }
                            }

                            New-UDGrid -Item -ExtraSmallSize 4 -Content {
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
                                        Show-UDToast -CloseOnClick "[$tempPath] is not a valid filepath" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                                        SyncPage -Sort
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
                                        SyncPage -Sort
                                    }
                                }
                            }

                            New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                New-UDButton -Icon $iconEdit -Text 'Json' -FullWidth -OnClick {
                                    Show-UDModal -FullScreen -Content {
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
                                        New-UDCodeEditor -Id 'dynamic-sort-aggregateddataeditor' -HideCodeLens -Language 'json' -Height '170ch' -Width '155ch' -Theme vs-dark -Code ($aggregatedData | ConvertTo-Json)
                                    } -Header {
                                        New-UDTypography -Text (Get-UDElement -Id 'textbox-sort-manualsearch').value.ToUpper()
                                    } -Footer {
                                        New-UDButton -Text 'Ok' -OnClick {
                                            $cache:findData[$cache:index].Data = (Get-UDElement -Id 'dynamic-sort-aggregateddataeditor').code | ConvertFrom-Json
                                            SyncPage -Sort
                                            Hide-UDModal
                                        }
                                        New-UDButton -Text 'Reset' -OnClick {
                                            if (($cache:findData).Length -eq 1) {
                                                Set-UDElement -Id 'dynamic-sort-aggregateddataeditor' -Properties @{
                                                    code = ($cache:originalFindData | ConvertFrom-Json).Data | ConvertTo-Json
                                                }
                                            } else {
                                                Set-UDElement -Id 'dynamic-sort-aggregateddataeditor' -Properties @{
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
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                                New-UDButton -Icon $iconSearch -Text 'Manual Search' -FullWidth -OnClick {
                                    Show-UDModal -FullWidth -MaxWidth xl -Content {
                                        $scrapers = @(
                                            'aventertainment',
                                            'aventertainmentja',
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
                                        )
                                        New-UDTextbox -Id 'textbox-sort-manualsearch' -Placeholder 'Enter an ID or a comma separated list of URLs' -FullWidth -MultiLine -Autofocus
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
                                                InProgress -Generic
                                                #Show-UDToast -CloseOnClick -Message "Searching for [$searchInput]" -Title "Manual Search" -Duration 5000 -Position bottomRight
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
                                                        Aggregated   = $true
                                                    }
                                                    $jvData = (Javinizer @findParams)

                                                    if ($null -ne $jvData) {
                                                        $cache:findData[$cache:index].Data = $jvData
                                                    } else {
                                                        Show-UDToast -CloseOnClick "Id [$searchInput] not found" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                                                    }
                                                }
                                                SyncPage -Sort
                                                InProgress -Off
                                            } else {
                                                Show-UDToast -CloseOnClick -Message "A job is currently running, please wait" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                            }
                                        }
                                        New-UDButton -Text 'Cancel' -FullWidth -OnClick {
                                            Hide-UDModal
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
                                                    New-UDButton -Icon $iconEdit -FullWidth -OnClick {
                                                        Show-UDModal -FullWidth -MaxWidth lg -Content {
                                                            New-UDCard -Title 'Edit Actor' -TitleAlignment center -Content {
                                                                New-UDGrid -Container -Content {
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "textbox-sort-actorlastname-$cache:index-$actressIndex" -Placeholder 'LastName' -Value $actress.LastName -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "textbox-sort-actorfirstname-$cache:index-$actressIndex" -Placeholder 'FirstName' -Value $actress.FirstName -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "textbox-sort-actorjapanese-$cache:index-$actressIndex" -Placeholder 'JapaneseName' -Value $actress.JapaneseName -FullWidth
                                                                    }
                                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                        New-UDTextbox -Id "textbox-sort-actorthumburl-$cache:index-$actressIndex" -Placeholder 'ThumbUrl' -Value $actress.ThumbUrl -FullWidth
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
                                                                SyncPage -Sort
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
                                                        New-UDTextbox -Id "textbox-sort-origactorname-$cache:index-$actressIndex" -Placeholder 'Name' -Value ("$($actress.LastName) $($actress.FirstName)").Trim() -Disabled
                                                    }

                                                    New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                        New-UDTextbox -Id "textbox-sort-origactorjapanesename-$cache:index-$actressIndex" -Placeholder 'JapaneseName' -Value $actress.JapaneseName -Disabled
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
                                                        New-UDCard -Title 'Add Actor' -TitleAlignment center -Content {
                                                            New-UDGrid -Container -Content {
                                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                    New-UDTextbox -Id "newtextbox-sort-actorlastname" -Placeholder 'LastName' -FullWidth
                                                                }
                                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                    New-UDTextbox -Id "newtextbox-sort-actorfirstname" -Placeholder 'FirstName' -FullWidth
                                                                }
                                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                    New-UDTextbox -Id "newtextbox-sort-actorjapanese" -Placeholder 'JapaneseName' -FullWidth
                                                                }
                                                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                                                    New-UDTextbox -Id "newtextbox-sort-actorthumburl" -Placeholder 'ThumbUrl' -FullWidth
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
