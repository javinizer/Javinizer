New-UDPage -Name "Settings" -Content {
    $locationSettings = @(
        'input',
        'output',
        'thumbcsv',
        'genrecsv',
        'uncensorcsv',
        'log',
        'historycsv'
    )

    $scraperSettings = @(
        'AVEntertainment',
        'AVEntertainmentJa'
        'Dmm',
        'DmmJa',
        'Javlibrary',
        'JavlibraryJa',
        'JavlibraryZh',
        'MGStageJa',
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
        'sort.metadata.nfo.originalpath',
        'sort.metadata.thumbcsv',
        'sort.metadata.thumbcsv.autoadd',
        'sort.metadata.thumbcsv.convertalias',
        'sort.metadata.genrecsv'
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
                                InProgress -Generic -NoCancel
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
                                $cache:settings.'match.minimumfilesize' = [Int](Get-UDElement -Id 'textbox-settings-minfilesize').value
                                #$cache:settings.'match.includedfileextension' = ((Get-UDElement -Id 'textbox-settings-includedfileext').value -split '\\')
                                #$cache:settings.'match.excludedfilestring' = ((Get-UDElement -Id 'textbox-settings-excludedfilestr').value -split '\\')
                                $cache:settings.'match.regex' = (Get-UDElement -Id 'checkbox-settings-regexmatch').checked
                                $cache:settings.'match.regex.string' = (Get-UDElement -Id 'textbox-settings-regexmatchstring').value
                                $cache:settings.'match.regex.idmatch' = (Get-UDElement -Id 'textbox-settings-regexidmatch').value
                                $cache:settings.'match.regex.ptmatch' = (Get-UDElement -Id 'textbox-settings-regexptmatch').value
                                $cache:settings.'sort.maxtitlelength' = [Int](Get-UDElement -Id 'autocomplete-settings-maxtitlelength').value
                                $cache:settings.'sort.metadata.nfo.translate.language' = (Get-UDElement -Id 'autocomplete-settings-translatelanguage').value
                                $cache:settings.'sort.metadata.nfo.translate.module' = (Get-UDElement -Id 'autocomplete-settings-translatemodule').value
                                $cache:settings.'sort.metadata.nfo.translate.field' = ((Get-UDElement -Id 'textbox-settings-translatefield').value -split '\\').Trim()
                                $cache:settings.'admin.log' = (Get-UDElement -Id 'checkbox-settings-adminlog').checked
                                $cache:settings.'admin.log.level' = (Get-UDElement -Id 'autocomplete-settings-adminloglevel').value
                                $cache:settings | ConvertTo-Json | Out-File $cache:settingsPath
                                $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json

                                if (Test-Path -LiteralPath ($cache:settings.'location.log')) {
                                    $cache:logPath = $cache:settings.'location.log'
                                } elseif (($cache:settings.'location.log') -ne '') {
                                    try {
                                        New-Item -Path $cache:settings.'location.log'
                                    } catch {
                                        Show-UDToast -CloseOnClick -Message "Error setting log location: $PSItem" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                    }
                                } else {
                                    $cache:logPath = $cache:defaultLogPath
                                }
                                if (Test-Path -LiteralPath ($cache:settings.'location.historycsv')) {
                                    $cache:historyPath = $cache:settings.'location.historycsv'
                                } elseif (($cache:settings.'location.historycsv') -ne '') {
                                    try {
                                        New-Item -Path $cache:settings.'location.historycsv'
                                    } catch {
                                        Show-UDToast -CloseOnClick -Message "Error setting history location: $PSItem" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                    }
                                } else {
                                    $cache:historyPath = $cache:defaultHistorypath
                                }
                                if (Test-Path -LiteralPath $cache:settings.'location.thumbcsv') {
                                    $cache:thumbCsvPath = $cache:settings.'location.thumbcsv'
                                } elseif (($cache:settings.'location.thumbcsv') -ne '') {
                                    try {
                                        New-Item -Path $cache:settings.'location.thumbcsv'
                                    } catch {
                                        Show-UDToast -CloseOnClick -Message "Error setting thumb location: $PSItem" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                    }
                                } else {
                                    $cache:thumbCsvPath = $cache:defaultThumbPath
                                }

                                SyncPage -Settings
                                InProgress -Off
                                Show-UDToast -CloseOnClick -Message "Settings updated" -Title "Success" -TitleColor green -Duration 2000 -Position bottomRight
                            }
                        }
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 4 -Content {
                            New-UDButton -Icon $iconEdit -Text 'Json' -Size large -FullWidth -OnClick {
                                Show-UDModal -FullScreen -Content {
                                    $settingsContent = (Get-Content -LiteralPath $cache:settingsPath) -join "`r`n"
                                    New-UDCodeEditor -Id 'editor-settings-json' -HideCodeLens -Language 'json' -Height '170ch' -Width '200ch' -Theme vs-dark -Code $settingsContent
                                } -Header {
                                    "jvSettings.json"
                                } -Footer {
                                    New-UDButton -Text 'Ok' -OnClick {
                                        try {
                                            # Validate that the settings json format before writing
                                            (Get-UDElement -Id 'editor-settings-json').code | ConvertFrom-Json
                                            (Get-UDElement -Id 'editor-settings-json').code | Out-File $cache:settingsPath -Force
                                            Show-UDToast -CloseOnClick -Message "Settings updated" -Title "Success" -TitleColor green -Duration 2000 -Position bottomRight
                                            $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
                                            SyncPage -Settings
                                            Hide-UDModal
                                        } catch {
                                            Show-UDToast -CloseOnClick -Message "Error occurred when saving settings: $PSItem" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
                                        }
                                    }
                                    New-UDButton -Text "Cancel" -OnClick {
                                        SyncPage -Settings
                                        Hide-UDModal
                                    }
                                }
                            }
                        }
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 4 -Content {
                            New-UDButton -Icon $iconUndo -Text 'Reload' -Size large -FullWidth -OnClick {
                                InProgress -Generic -NoCancel
                                if (Test-Path -LiteralPath ($cache:settings.'location.log')) {
                                    $cache:logPath = $cache:settings.'location.log'
                                } else {
                                    $cache:logPath = $cache:defaultLogPath
                                }
                                if (Test-Path -LiteralPath ($cache:settings.'location.historycsv')) {
                                    $cache:historyPath = $cache:settings.'location.historycsv'
                                } else {
                                    $cache:historyPath = $cache:defaultHistorypath
                                }
                                if (Test-Path -LiteralPath $cache:settings.'location.thumbcsv') {
                                    $cache:thumbCsvPath = $cache:settings.'location.thumbcsv'
                                } else {
                                    $cache:thumbCsvPath = $cache:defaultThumbPath
                                }
                                $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
                                $cache:actressObject = Import-Csv $cache:thumbCsvPath | Sort-Object FullName
                                $cache:actressArray += $cache:actressObject | ForEach-Object { "$($_.FullName) ($($_.JapaneseName)) [$actressIndex]"; $actressIndex++ }
                                SyncPage -Settings
                                InProgress -Off
                            }
                        }
                    }
                }

                ## Scrapers card
                New-UDCard -Title 'Scrapers' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Container -Content {
                            foreach ($scraper in $scraperSettings) {
                                New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                    New-UDCheckBox -Label $scraper -Id "checkbox-settings-$scraper" -LabelPlacement end -Checked ($cache:settings."scraper.movie.$scraper")
                                }
                            }
                        }

                        New-UDCard -Title 'Options' -Content {
                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                New-UDCheckBox -Label 'Scrape DMM Actress (Only use this is DMM is your actress scraper)' -Id 'checkbox-settings-scrapeactress' -LabelPlacement end -Checked ($cache:settings.'scraper.option.dmm.scrapeactress')
                            }
                            New-UDGrid -Item -ExtraSmallSize 6 -Content {
                                New-UDAutocomplete -Id 'autocomplete-settings-throttlelimit' -Label ThrottleLimit -Options @('1', '2', '3', '4', '5', '6', '7', '8', '9', '10') -Value $cache:settings.'throttlelimit' -OnChange {
                                    if ($null -eq (Get-UDElement -Id 'autocomplete-settings-throttlelimit').value) {
                                        Set-UDElement -Id 'autocomplete-settings-throttlelimit' -Properties @{
                                            value = '3'
                                        }
                                    }
                                }
                                New-UDAutocomplete -Id 'autocomplete-settings-idpreference' -Label 'ID Preference' -Options @('id', 'contentid') -Value $cache:settings.'scraper.option.idpreference' -OnChange {
                                    if ($null -eq (Get-UDElement -Id 'autocomplete-settings-idpreference').value) {
                                        Set-UDElement -Id 'autocomplete-settings-idpreference' -Properties @{
                                            value = 'id'
                                        }
                                    }
                                }
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
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTextbox -Placeholder $field -Id "textbox-settings-$field" -Value ($cache:settings."sort.metadata.priority.$field" -join ' \ ') -FullWidth
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Placeholder 'Required Fields' -Id 'textbox-settings-requiredfields' -Value ($cache:settings."sort.metadata.requiredfield" -join ' \ ') -FullWidth
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
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Placeholder 'match.minimumfilesize (MB)' -Id 'textbox-settings-minfilesize' -Value ($cache:settings.'match.minimumfilesize') -FullWidth
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Placeholder 'match.includedfileextension (Edit in JSON)' -Id 'textbox-settings-includedfileext' -Value ($cache:settings.'match.includedfileextension' -join ' \ ') -FullWidth -Disabled
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Placeholder 'match.excludedfilestring (Edit in JSON)' -Id 'textbox-settings-excludedfilestr' -Value ($cache:settings.'match.excludedfilestring' -join ' \ ') -FullWidth -Disabled
                                }
                            }
                            New-UDGrid -Container -Content {
                                New-UDCard -Title 'Regex' -Content {
                                    New-UDGrid -Container -Content {
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDCheckBox -Label 'match.regex' -Id 'checkbox-settings-regexmatch' -Checked ($cache:settings.'match.regex')
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Placeholder 'match.regex.string (Edit in JSON)' -Id 'textbox-settings-regexmatchstring' -Value ($cache:settings.'match.regex.string') -FullWidth -Disabled
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Placeholder 'match.regex.idmatch' -Id 'textbox-settings-regexidmatch' -Value ($cache:settings.'match.regex.idmatch') -FullWidth
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Placeholder 'match.regex.ptmatch' -Id 'textbox-settings-regexptmatch' -Value ($cache:settings.'match.regex.ptmatch') -FullWidth
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
                New-UDCard -Title 'Locations' -Content {
                    New-UDGrid -Container -Content {
                        foreach ($setting in $locationSettings) {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                New-UDTextbox -Placeholder $setting -Id "textbox-settings-location-$setting" -Value ($cache:settings."location.$setting") -FullWidth
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
                            New-UDCheckBox -Label 'sort.metadata.nfo.translate' -Id 'sort.metadata.nfo.translate' -LabelPlacement end -Checked ($cache:settings.'sort.metadata.nfo.translate')
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                            New-UDTextbox -Placeholder 'sort.metadata.nfo.translate.field' -Id 'textbox-settings-translatefield' -Value ($cache:settings.'sort.metadata.nfo.translate.field' -join ' \ ') -FullWidth
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                            New-UDAutocomplete -Id 'autocomplete-settings-translatelanguage' -Label 'Translate Language' -Options $translateLanguages -Value ($cache:settings.'sort.metadata.nfo.translate.language') -OnChange {
                                if ($null -eq (Get-UDElement -Id 'autocomplete-settings-translatelanguage').value) {
                                    Set-UDElement -Id 'autocomplete-settings-translatelanguage' -Properties @{
                                        value = 'en'
                                    }
                                }
                            }
                        }

                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
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
                                            New-UDTextbox -Placeholder $setting -Id "$setting" -Value ($cache:settings."$setting" -join ' \ ') -FullWidth
                                        } else {
                                            New-UDTextbox -Placeholder $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
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
                                    New-UDTextbox -Id 'textbox-settings-previewfile' -Placeholder 'Movie Path'
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
                                        New-UDTextbox -Placeholder $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
                                    }
                                }
                            }
                        }
                    }
                }
                New-UDCard -Title 'Javlibrary' -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -Content {
                            New-UDGrid -Container -Content {
                                foreach ($setting in $javlibrarySettings) {
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTextbox -Placeholder $setting -Id "$setting" -Value ($cache:settings."$setting") -FullWidth
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
