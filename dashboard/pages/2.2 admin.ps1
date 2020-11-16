New-UDPage -Name 'Admin' -Content {
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDCard -Title 'Console' -Content {
                New-UDGrid -Container -Content {
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                        New-UDTextbox -Id 'textbox-admin-console' -Placeholder 'Enter a command' -FullWidth -MultiLine -Autofocus
                    }
                    New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
                        New-UDButton -Text 'Run' -FullWidth -OnClick {
                            InProgress -Generic
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
                                InProgress -Off
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
                        #New-UDTextbox -Id 'logAutoRefreshInterval' -Label 'Every how many seconds' -Placeholder '5'
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
                                        Show-UDToast -CloseOnClick -Message "$PSItem" -Title "Error" -TitleColor red -Duration 5000 -Position bottomRight
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
}
