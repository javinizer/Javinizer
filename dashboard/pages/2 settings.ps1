New-UDPage -Name "Settings" -Content {
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
        New-UDScrollUp
        New-UDGrid -Container -Content {
            ## Left Column
            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                New-UDCard -Content {
                    New-UDGrid -Container -Content {
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 4 -Content {
                            New-UDButton -Icon $iconCheck -Text 'Apply' -Size large -Variant outlined -FullWidth -OnClick {
                                InProgress -Generic
                                foreach ($scraper in $scraperSettings) {
                                    $cache:settings."scraper.movie.$scraper" = (Get-UDElement -Id "SettingChkbx$scraper").checked
                                }
                                foreach ($field in $prioritySettings) {
                                    $cache:settings."sort.metadata.priority.$field" = ((Get-UDElement -Id "SettingTextbox$field").value -split ' \\ ') | ForEach-Object { ($_).Trim() }
                                }
                                foreach ($setting in $locationSettings) {
                                    $cache:settings."location.$setting" = ((Get-UDElement -Id "SettingTextboxLocation$setting")).value
                                }

                                foreach ($setting in $sortSettings) {
                                    $cache:settings."$setting" = (Get-UDElement -Id "$setting").checked
                                }

                                foreach ($setting in $formatStringSettings) {
                                    if ($setting -eq 'sort.format.posterimg' -or $setting -eq 'sort.metadata.nfo.format.tag' -or $setting -eq 'sort.format.outputfolder') {
                                        $cache:settings."$setting" = ((Get-UDElement -Id "$setting").value -split ' \\ ')
                                    } else {
                                        $cache:settings."$setting" = (Get-UDElement -Id "$setting").value
                                    }
                                }

                                $cache:settings.'sort.metadata.requiredfield' = ((Get-UDElement -Id 'sort.metadata.requiredfield').value -split ' \\ ') | ForEach-Object { ($_).Trim() }
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
                                SyncPage -Settings
                                InProgress -Off
                                Show-UDToast -CloseOnClick -Message "Settings updated" -Title "Success" -TitleColor green -Duration 2000 -Position bottomRight
                            }
                        }
                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 4 -Content {
                            New-UDButton -Icon $iconEdit -Text 'Edit (JSON)' -Size large -Variant outlined -FullWidth -OnClick {
                                Show-UDModal -FullScreen -Content {
                                    $settingsContent = (Get-Content -LiteralPath $cache:settingsPath) -join "`r`n"
                                    New-UDCodeEditor -Id 'SettingsEditor' -HideCodeLens -Language 'json' -Height '170ch' -Width '200ch' -Theme vs-dark -Code $settingsContent
                                } -Header {
                                    "jvSettings.json"
                                } -Footer {
                                    New-UDButton -Text 'Ok' -OnClick {
                                        try {
                                            # Validate that the settings json format before writing
                                            (Get-UDElement -Id 'SettingsEditor').code | ConvertFrom-Json
                                            (Get-UDElement -Id 'SettingsEditor').code | Out-File $cache:settingsPath -Force
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
                            New-UDButton -Icon $iconUndo -Text 'Reset' -Size large -Variant outlined -FullWidth -OnClick {
                                InProgress -Generic
                                $cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
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
                                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                        New-UDTextbox -Label $field -Id "SettingTextbox$field" -Value ($cache:settings."sort.metadata.priority.$field" -join ' \ ') -FullWidth
                                    }
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
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
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Label 'match.minimumfilesize' -Id 'match.minimumfilesize' -Value ($cache:settings.'match.minimumfilesize') -FullWidth
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Label 'match.includedfileextension' -Id 'matchincludedfileextension' -Value ($cache:settings.'match.includedfileextension' -join ' \ ') -FullWidth -Disabled
                                }
                                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                    New-UDTextbox -Label 'match.excludedfilestring' -Id 'matchexcludedfilestring' -Value ($cache:settings.'match.excludedfilestring' -join ' \ ') -FullWidth -Disabled
                                }
                            }
                            New-UDGrid -Container -Content {
                                New-UDCard -Title 'Regex' -Content {
                                    New-UDGrid -Container -Content {
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDCheckBox -Label 'match.regex' -Id 'match.regex' -Checked ($cache:settings.'match.regex')
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Label 'match.regex.string' -Id 'matchregexstring' -Value ($cache:settings.'match.regex.string') -FullWidth -Disabled
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                            New-UDTextbox -Label 'match.regex.idmatch' -Id 'matchregexidmatch' -Value ($cache:settings.'match.regex.idmatch') -FullWidth
                                        }
                                        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
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
                        New-UDGrid -Item -SmallSize 6 -Content {
                            New-UDCheckBox -Id 'admin.log' -Label 'admin.log' -LabelPlacement end -Checked ($cache:settings.'admin.log')
                        }
                        New-UDGrid -Item -SmallSize 6 -Content {
                            New-UDTypography -Variant 'body2' -Text 'admin.log.level'
                            New-UDAutocomplete -Id 'adminloglevel' -Options @('debug', 'info', 'warning', 'error') -Value ($cache:settings.'admin.log.level')
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
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                #New-UDTypography -Variant 'body2' -Text 'Translate Language'
                                New-UDTextbox -Id 'sortmetadatanfotranslatedescriptionlanguage' -Label 'Translate Language' -Value ($cache:settings.'sort.metadata.nfo.translatedescription.language') -FullWidth
                                #New-UDAutocomplete -Id 'sortmetadatanfotranslatedescriptionlanguage' -Options $translateLanguages -Value ($cache:settings.'sort.metadata.nfo.translatedescription.language')
                            }

                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 6 -Content {
                                New-UDTextbox -Id 'sort.maxtitlelength' -Label 'sort.maxtitlelength' -Value ($cache:settings.'sort.maxtitlelength') -FullWidth
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
                New-UDCard -Title 'Javlibrary' -Content {
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
