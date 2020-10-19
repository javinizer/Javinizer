$cache:settingsPath = '/root/.local/share/powershell/Modules/Javinizer/2.1.4/jvSettings.json'
$cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
$cache:inProgress = $false
$cache:findData = @()
$cache:index = 0
$iconSearch = New-UDIcon -Icon 'search' -Size lg
$iconRightArrow = New-UDIcon -Icon 'arrow_right' -Size lg
$iconLeftArrow = New-UDIcon -Icon 'arrow_left' -Size lg
$iconLevelUp = New-UDIcon -Icon 'level_up_alt' -Size lg
$iconCheck = New-UDIcon -Icon 'check' -Size lg
$iconTrash = New-UDIcon -Icon 'trash' -Size lg

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
            Show-UDToast -Message "Searching [$($Item.FullName)]" -Title 'Multi Sort' -Duration 5000
            $recurse = (Get-UDElement -Id 'RecurseChkbx')['checked']
            $strict = (Get-UDElement -id 'StrictChkbx')['checked']
            $cache:searchTotal = ($cache:settings | Get-JVItem -Path $Item.FullName -Recurse:$recurse -Strict:$strict).Count
            $jvData = Javinizer -Path $Item.FullName -Recurse:$recurse -Strict:$strict -IsWeb
            $cache:findData = ($jvData | Where-Object { $null -ne $_.Data })
            Show-UDToast -Message (($cache:sortData).GetType().Name) -Duration 5000
        } else {
            $movieId = ($cache:settings | Get-JVItem -Path $Item.FullName).Id
            Set-UDElement -Id 'ManualSearchTextbox' -Properties @{
                value = $movieId
            }

            Show-UDToast -Message "Searching for [$($Item.FullName)]" -Title 'Single Sort' -Duration 5000
            $jvData = Javinizer -Path $Item.FullName -Strict:$strict -IsWeb
            if ($null -ne $javData.Data) {
                $cache:findData = $jvData
            } else {
                Show-UDToast "Id [$movieId] not found" -BackgroundColor Red -Duration 5000
            }
            $cache:originalFindData = $cache:findData
        }

        <# if ($null -in $jvData.Data) {
        $skipped = ($jvData | Where-Object { $null -eq $_.Data })
        foreach ($moviePath in $skipped) {
            Show-UDToast -Message $moviePath
        }

        Show-UDModal -FullWidth -MaxWidth lg -Content {
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
        Show-UDToast -Message "A job is currently running, please wait." -Duration 5000 -Title "Error" -TitleColor red -Position topCenter
    }
}

function SyncPage {
    param (
        [Switch]$Sort
    )
    if ($Sort) {
        if (($cache:findData).Count -eq 0) {
            $cache:findData = @()
        }
        Sync-UDElement -Id 'AggregatedData'
        Sync-UDElement -Id 'AggregatedDataCover'
        Sync-UDElement -Id 'MovieSelect'
    }
}

New-UDPage -Name "Javinizer Web" -Content {
    New-UDTabs -Tabs {
        New-UDTab -Text 'Multi Sort' -Content {
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
                                #New-UDTypography -Variant body1 -Text ($cache:currentSort -join ', ') -Align center
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
                                SyncPage -Sort
                            }
                        }
                    }
                } else {
                    Hide-UDModal
                }
            } -AutoRefresh -AutoRefreshInterval .5

            New-UDGrid -Container -Content {
                New-UDGrid -Item -ExtraSmallSize 6 -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 5 -Content {
                            New-UDDynamic -Content {
                                New-UDCard -Title 'File/Dir Search' -Content {
                                    New-UDTextbox -Id 'FileDirSearchTextbox' -Placeholder 'Enter a path' -Value $cache:settings.'location.input'
                                    New-UDButton -Icon $iconSearch -Variant outlined -OnClick {
                                        JavinizerSearch -Path (Get-UDElement -Id 'FileDirSearchTextbox').value
                                    }
                                }
                            }
                        }
                        New-UDGrid -Item -ExtraSmallSize 7 -Content {
                            New-UDDynamic -Id 'MovieSelect' -Content {
                                if (($cache:index -eq 0) -and (($cache:findData).Count -eq 0)) {
                                    $currentIndex = 0
                                } else {
                                    $currentIndex = $cache:index + 1
                                }
                                New-UDCard -Title "($currentIndex of $(($cache:findData).Count)) $($cache:findData[$cache:index].Data.Id)" -Content {
                                    New-UDTextbox -Placeholder 'File path' -Value ($cache:findData[$cache:index].Path) -Disabled
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
                                            SyncPage -Sort
                                            Show-UDToast -Message "[$moviePath] sorted to [$destinationPath]" -Title "Success" -TitleColor green -Duration 5000 -Position topCenter
                                            $cache:inProgress = $false
                                        } else {
                                            Show-UDToast -Message "A job is currently running, please wait." -Duration 5000 -Title "Error" -TitleColor red -Position topCenter
                                        }
                                    }
                                }
                            }
                        }
                    }

                    New-UDDynamic -Id 'AggregatedDataCover' -Content {
                        New-UDCard -Title 'Cover Image' -Content {
                            New-UDImage -Url $cache:findData[$cache:index].Data.CoverUrl
                        }
                        New-UDCard -Title 'Screenshot Image' -Content {
                            foreach ($img in $cache:findData[$cache:index].Data.ScreenshotUrl) {
                                New-UDImage -Url $img -Height 100
                            }
                        }
                    }

                    New-UDPaper -Content {
                        New-UDGrid -Container -Content {
                            New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                New-UDDynamic -Id 'FileBrowser' -Content {
                                    $cache:filePath = (Get-UDElement -Id 'DirectoryTextbox').value
                                    $search = Get-ChildItem -LiteralPath $cache:filePath | Select-Object Name, Length, FullName, Mode, Extension | ConvertTo-Json | ConvertFrom-Json

                                    $searchColumns = @(
                                        New-UDTableColumn -Property Name -Title 'Name' -Render {
                                            $Item = $Body | ConvertFrom-Json
                                            if ($Item.Mode -like 'd*') {
                                                New-UDButton -Variant 'outlined' -Text "$($Item.Name)" -OnClick {
                                                    Set-UDElement -Id 'DirectoryTextbox' -Properties @{
                                                        value = $item.FullName
                                                    }
                                                    Sync-UDElement -Id 'FileBrowser'
                                                }
                                            } else {
                                                New-UDTypography -Variant 'display1' -Text "$($Item.Name)"
                                            }
                                        }

                                        New-UDTableColumn -Property FullName -Title 'Search' -Render {
                                            $Item = $Body | ConvertFrom-Json
                                            $includedExtensions = $cache:settings.'match.includedfileextension'
                                            if (($Item.Mode -like 'd*') -or ($Item.Extension -in $includedExtensions)) {
                                                New-UDButton -Icon (New-UDIcon -Icon play) -Variant 'outlined' -IconAlignment left -Text 'Search' -OnClick {
                                                    JavinizerSearch -Item $Item
                                                }
                                            }
                                        }
                                    )
                                    New-UDTable -Id 'DirectoryTable' -Data $search -Columns $searchColumns -Title "Directory: $cache:filePath" -Padding dense -Sort -Search -PageSize 5 -PageSizeOptions @(5, 10, 20, 50, 100)
                                }
                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                        New-UDCard -Title 'Navigation' -Content {
                                            if ($cache:filePath -eq '' -or $null -eq $cache:filePath) {
                                                $dir = $cache:settings.'location.input'
                                            } else {
                                                $dir = $cache:filePath
                                            }
                                            New-UDTextbox -Id 'DirectoryTextbox' -Placeholder 'Enter a directory' -Value $dir -Autofocus
                                            New-UDButton -Icon $iconSearch -Variant outlined -OnClick {
                                                $cache:filePath = (Get-UDElement -Id 'DirectoryTextbox').value
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
                                            New-UDTextbox -Id 'ManualSearchTextbox' -Placeholder 'Enter an ID/Url'
                                            New-UDButton -Icon $iconSearch -Variant outlined -OnClick {
                                                if (!($cache:inProgress)) {
                                                    $cache:inProgress = $true
                                                    $searchInput = (Get-UDElement -Id 'ManualSearchTextbox').value
                                                    if ($cache:findData.Id -ne (Get-UDElement -Id 'ManualSearchTextbox').value -or $cache:findData -eq $null -or $cache:findData -eq '') {
                                                        Show-UDToast -Message "Searching for [$searchInput]" -Duration 5000 -Title "Single sort" -Position topCenter
                                                        if ($searchInput -like '*.com*') {
                                                            $searchInput = $searchInput -split ','
                                                            $cache:findData = (Javinizer -Find $searchInput -Aggregated)
                                                        } else {
                                                            $findParams = @{
                                                                Find         = $searchInput
                                                                Dmm          = $cache:settings.'scraper.movie.dmm'
                                                                DmmJa        = $cache:settings.'scraper.movie.dmmja'
                                                                Jav321Ja     = $cache:settings.'scraper.movie.jav321ja'
                                                                Javbus       = $cache:settings.'scraper.movie.javbus'
                                                                JavbusJa     = $cache:settings.'scraper.movie.javbusja'
                                                                JavbusZh     = $cache:settings.'scraper.movie.javbuszh'
                                                                Javlibrary   = $cache:settings.'scraper.movie.javlibrary'
                                                                Javlibraryja = $cache:settings.'scraper.movie.javlibraryja'
                                                                JavlibraryZh = $cache:settings.'scraper.movie.javlibraryzh'
                                                                R18          = $cache:settings.'scraper.movie.r18'
                                                                R18Zh        = $cache:settings.'scraper.movie.r18zh'
                                                                Aggregated   = $true
                                                            }
                                                            $cache:findData = (Javinizer @findParams)
                                                        }

                                                        if ($null -eq $cache:findData) {
                                                            Show-UDToast "Id [$searchInput] not found" -Duration 5000 -Title 'Error' -TitleColor red -Position topCenter
                                                        }

                                                        $cache:originalFindData = $cache:findData
                                                        SyncPage -Sort
                                                        $cache:inProgress = $false
                                                    }
                                                } else {
                                                    Show-UDToast -Message "A job is currently running, please wait." -Duration 5000 -Title "Error" -TitleColor red -Position topCenter
                                                }
                                            }
                                            New-UDButton -Icon $iconTrash -Variant outlined -OnClick {
                                                $cache:findData = @()
                                                SyncPage -Sort
                                            }
                                        }
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                        New-UDCheckBox -Id 'RecurseChkbx' -Label 'Recurse' -LabelPlacement end
                                        New-UDCheckBox -Id 'StrictChkbx' -Label 'Strict'  -LabelPlacement end
                                    }
                                }
                            }
                        }
                    }
                }

                New-UDGrid -Item -ExtraSmallSize 6 -Content {
                    New-UDDynamic -Id 'AggregatedData' -Content {
                        New-UDCard -Title "Aggregated Data" -Content {
                            New-UDList -Content {
                                #New-UDListItem -Label $cache:findData[$cache:index].Data.Id -SubTitle 'Id'
                                #New-UDListItem -Label $cache:findData.ContentId -SubTitle 'ContentId'
                                #New-UDListItem -Label $cache:findData[$cache:index].Data.DisplayName -SubTitle 'DisplayName'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.Title -SubTitle 'Title'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.AlternateTitle -SubTitle 'AlternateTitle'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.Description -SubTitle 'Description'
                                #New-UDListItem -Label ($cache:findData[$cache:index].Data.Rating | ConvertTo-Json) -SubTitle 'Rating'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.ReleaseDate -SubTitle 'ReleaseDate'
                                #New-UDListItem -Label $cache:findData.ReleaseYear -SubTitle 'ReleaseYear'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.Runtime -SubTitle 'Runtime'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.Director -SubTitle 'Director'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.Maker -SubTitle 'Maker'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.Label -SubTitle 'Label'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.Series -SubTitle 'Series'
                                New-UDListItem -Label ($cache:findData[$cache:index].Data.Tag | ConvertTo-Json) -SubTitle 'Tag'
                                New-UDListItem -Label $cache:findData[$cache:index].Data.Tagline -SubTitle 'Tagline'
                                #New-UDListItem -Label ($cache:findData.Actress | ConvertTo-Json) -SubTitle 'Actress'
                                New-UDListItem -Label ($cache:findData[$cache:index].Data.Genre | ConvertTo-Json) -SubTitle 'Genre'
                                #New-UDListItem -Label $cache:findData.CoverUrl -SubTitle 'CoverUrl'
                                #New-UDListItem -Label ($cache:findData.ScreenshotUrl | ConvertTo-Json) -SubTitle 'ScreenshotUrl'
                                #New-UDListItem -Label $cache:findData[$cache:index].Data.TrailerUrl -SubTitle 'TrailerUrl'
                            }
                            New-UDButton -Text 'Edit' -Variant outlined -OnClick {
                                $cache:inProgress = $true
                                Show-UDModal -FullScreen -Content {
                                    New-UDCodeEditor -Id 'AggregatedDataEditor' -HideCodeLens -Language 'json' -Height '200ch' -Width '250ch' -Theme vs-dark -Code ($cache:findData[$cache:index].Data | ConvertTo-Json)
                                } -Header {
                                    New-UDTypography -Text (Get-UDElement -Id 'ManualSearchTextbox').value.ToUpper()
                                } -Footer {
                                    New-UDButton -Text 'Apply' -OnClick {
                                        $cache:findData[$cache:index].Data = (Get-UDElement -Id 'AggregatedDataEditor').code | ConvertFrom-Json
                                        SyncPage -Sort
                                        $cache:inProgress = $false
                                        Hide-UDModal
                                    }

                                    New-UDButton -Text 'Reset' -OnClick {
                                        Set-UDElement -Id 'AggregatedDataEditor' -Properties @{
                                            code = ($cache:originalFindData[$cache:index].Data | ConvertTo-Json)
                                        }
                                    }

                                    New-UDButton -Text "Close" -OnClick {
                                        $cache:inProgress = $false
                                        Hide-UDModal
                                    }
                                }
                            }
                        }

                        New-UDGrid -Container -Content {
                            New-UDCard -Title "Actresses" -Content {
                                foreach ($actress in $cache:findData[$cache:index].Data.Actress) {
                                    New-UDGrid -ExtraSmallSize 3 -Content {
                                        New-UDCard -Title ("$($actress.LastName) $($actress.FirstName) ($($actress.JapaneseName))").Trim() -Content {
                                            New-UDImage -Url $actress.ThumbUrl -Height 100
                                        }

                                    }

                                }
                            }
                        }
                    }
                }
            }
        }


        New-UDTab -Text 'Settings' -Content {
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

            $translateLanguages = @(
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
            )

            New-UDDynamic -Id 'SettingsTab' -Content {
                New-UDGrid -Container -Content {
                    ## Left Column
                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                        New-UDCard -Content {
                            New-UDButton -Text 'Apply Settings' -OnClick {
                                foreach ($scraper in $scraperSettings) {
                                    $cache:settings."scraper.movie.$scraper" = (Get-UDElement -Id "SettingChkbx$scraper")['checked']
                                }
                                foreach ($field in $prioritySettings) {
                                    $cache:settings."sort.metadata.priority.$field" = ((Get-UDElement -Id "SettingTextbox$field").value -split '\\')
                                }
                                foreach ($setting in $locationSettings) {
                                    $cache:settings."location.$setting" = ((Get-UDElement -Id "SettingTextboxLocation$setting")).value
                                }

                                foreach ($setting in $sortSettings) {
                                    $cache:settings."$setting" = (Get-UDElement -Id "$setting")['checked']
                                }

                                foreach ($setting in $formatStringSettings) {
                                    if ($setting -eq 'sort.format.posterimg' -or $setting -eq 'sort.metadata.nfo.format.tag') {
                                        $cache:settings."$setting" = ((Get-UDElement -Id "$setting").value -split '\\')
                                    } else {
                                        $cache:settings."$setting" = (Get-UDElement -Id "$setting").value
                                    }
                                }

                                $cache:settings.'sort.metadata.requiredfield' = ((Get-UDElement -Id 'sort.metadata.requiredfield').value -split '\\')
                                $cache:settings.'scraper.option.idpreference' = (Get-UDElement -Id 'scraperoptionidpreference').value
                                $cache:settings.'scraper.option.dmm.scrapeactress' = (Get-UDElement -Id 'scraper.option.dmm.scrapeactress')['checked']
                                $cache:settings.'match.minimumfilesize' = [Int](Get-UDElement -Id 'match.minimumfilesize').value
                                #$cache:settings.'match.includedfileextension' = ((Get-UDElement -Id 'matchincludedfileextension').value -split '\\')
                                #$cache:settings.'match.excludedfilestring' = ((Get-UDElement -Id 'matchexcludedfilestring').value -split '\\')
                                $cache:settings.'match.regex' = (Get-UDElement -Id 'match.regex')['checked']
                                $cache:settings.'match.regex.string' = (Get-UDElement -Id 'matchregexstring').value
                                $cache:settings.'match.regex.idmatch' = (Get-UDElement -Id 'matchregexidmatch').value
                                $cache:settings.'match.regex.ptmatch' = (Get-UDElement -Id 'matchregexptmatch').value
                                $cache:settings.'sort.maxtitlelength' = [Int](Get-UDElement -Id 'sort.maxtitlelength').value
                                $cache:settings.'sort.metadata.nfo.translatedescription.language' = (Get-UDElement -Id 'sortmetadatanfotranslatedescriptionlanguage').value
                                $cache:settings.'admin.log' = (Get-UDElement -Id 'admin.log')['checked']
                                $cache:settings.'admin.log.level' = (Get-UDElement -Id 'adminloglevel').value
                                $cache:settings | ConvertTo-Json | Out-File $cache:settingsPath
                                $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
                            }

                            New-UDButton -Text 'Edit Settings (JSON)' -OnClick {
                                Show-UDModal -FullScreen -Content {
                                    $settingsContent = (Get-Content -Path $cache:settingsPath)
                                    New-UDCodeEditor -Id 'editor' -Language 'ini' -Height '150ch' -Width '150ch' -Theme vs-dark -Code $settingsContent
                                } -Header {
                                    "jvSettings.json"
                                } -Footer {
                                    New-UDButton -Text "Close" -OnClick { Hide-UDModal }
                                    New-UDButton -Text 'Apply and close' -OnClick { Hide-UDModal }
                                }
                            }
                            New-UDButton -Text 'Reset' -OnClick {
                                $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
                                Sync-UDElement -Id 'SettingsTab'
                            }

                            New-UDButton -Text 'Reset to Default' -OnClick {

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
                                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                                New-UDTextbox -Label $field -Id "SettingTextbox$field" -Value ($cache:settings."sort.metadata.priority.$field" -join '\')
                                            }
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                            New-UDTextbox -Label 'Required Fields' -Id 'sort.metadata.requiredfield' -Value ($cache:settings."sort.metadata.requiredfield" -join '\')
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
                                        New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                            New-UDTextbox -Label 'match.minimumfilesize' -Id 'match.minimumfilesize' -Value ($cache:settings.'match.minimumfilesize')
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                            New-UDTextbox -Label 'match.includedfileextension' -Id 'matchincludedfileextension' -Value ($cache:settings.'match.includedfileextension' -join '\')
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                            New-UDTextbox -Label 'match.excludedfilestring' -Id 'matchexcludedfilestring' -Value ($cache:settings.'match.excludedfilestring' -join '\')
                                        }
                                    }
                                    New-UDGrid -Container -Content {
                                        New-UDCard -Title 'Regex' -Content {
                                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                                New-UDCheckBox -Label 'match.regex' -Id 'match.regex' -Checked ($cache:settings.'match.regex')
                                            }
                                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                                New-UDTextbox -Label 'match.regex.string' -Id 'matchregexstring' -Value ($cache:settings.'match.regex.string')
                                            }
                                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                                New-UDTextbox -Label 'match.regex.idmatch' -Id 'matchregexidmatch' -Value ($cache:settings.'match.regex.idmatch')
                                            }
                                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                                New-UDTextbox -Label 'match.regex.ptmatch' -Id 'matchregexptmatch' -Value ($cache:settings.'match.regex.ptmatch')
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
                            foreach ($setting in $locationSettings) {
                                New-UDTextbox -Label $setting -Id "SettingTextboxLocation$setting" -Value ($cache:settings."location.$setting")
                            }
                        }

                        ## Metadata options card
                        New-UDCard -Title 'Sort' -Content {
                            New-UDGrid -Container -Content {
                                foreach ($setting in $sortSettings) {
                                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                        New-UDCheckBox -Label $setting -Id "$setting" -LabelPlacement end -Checked ($cache:settings."$setting")
                                    }
                                }
                                New-UDGrid -Container -Content {
                                    New-UDGrid -Item -ExtraSmallSize 4 -Content {
                                        New-UDTypography -Variant 'body2' -Text 'Translate Description Language'
                                        New-UDAutocomplete -Id 'sortmetadatanfotranslatedescriptionlanguage' -Options $translateLanguages -Value ($cache:settings.'sort.metadata.nfo.translatedescription.language')
                                    }
                                    New-UDGrid -Item -ExtraSmallSize 2 -Content {

                                    }
                                    New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                        New-UDTextbox -Id 'sort.maxtitlelength' -Label 'sort.maxtitlelength' -Value ($cache:settings.'sort.maxtitlelength')
                                    }
                                }
                            }
                        }

                        New-UDCard -Title 'Format Strings' -Content {
                            New-UDGrid -Container -Content {
                                New-UDGrid -Item -ExtraSmallSize 12 -Content {
                                    New-UDGrid -Container -Content {
                                        foreach ($setting in $formatStringSettings) {
                                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                                if ($setting -eq 'sort.format.posterimg' -or $setting -eq 'sort.metadata.nfo.format.tag') {
                                                    New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting" -join '\')
                                                } else {
                                                    New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting")
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
                                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                                New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting")
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
                                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                                New-UDTextbox -Label $setting -Id "$setting" -Value ($cache:settings."$setting")
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

        New-UDTab -Text 'Log' -Content {
            <# New-UDPaper -Content {
                New-UDElement -Attributes @{
                    style = @{
                        width = "100%"
                    }
                } -Content {
                    New-UDProgress -Circular
                }
            } #>

            <#             New-UDTable -Data $Data -Padding dense
            $rawLog = (Get-Content -LiteralPath 'C:\ProgramData\Javinizer\src\Javinizer\jvLog.log')
            $log = $rawLog[($rawLog.Count - 1)..0] -join "`n"
            #New-UDCheckBox -Id 'logAutoRefreshChkbx' -Label 'Autorefresh' -LabelPlacement end
            #New-UDTextbox -Id 'logAutoRefreshInterval' -Label 'Every how many seconds' -Placeholder '5'
            #$cache:logAutoRefresh = (Get-UDElement -Id "logAutoRefreshChkbx")['checked']
            #$cache:logAutoRefreshInterval = [Int](Get-UDElement -Id 'logAutoRefreshInterval').value
            New-UDDynamic -Content {
                New-UDGrid -Container -Content {
                    New-UDCodeEditor -Id 'LogEditor' -HideCodeLens -Language 'powershell' -Height '200ch' -Width '250ch' -Theme vs-dark -Code $log
                }
            } -AutoRefresh:$cache:logAutoRefresh -AutoRefreshInterval:$cache:logAutoRefreshInterval #>
        }
    }
}
