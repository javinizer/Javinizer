New-UDPage -Name 'History' -Content {
    New-UDScrollUp
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDPaper -Content {
                New-UDButton -Icon $iconUndo -Text 'Reload' -OnClick {
                    if (Test-Path -LiteralPath ($cache:settings.'location.historycsv')) {
                        $cache:historyPath = $cache:settings.'location.historycsv'
                    } else {
                        $cache:historyPath = $cache:defaultHistorypath
                    }
                    Sync-UDElement -Id 'dynamic-history-sorttable'
                }
                New-UDButton -Icon $iconTrash -Text 'Clear' -OnClick {
                    Show-UDModal -FullWidth -MaxWidth xl -Content {
                        New-UDTypography -Variant h6 -Text "Clear history?"
                    } -Footer {
                        New-UDButton -Text 'Ok' -OnClick {
                            try {
                                Clear-Content -LiteralPath $cache:historyPath -Force
                                Sync-UDElement -Id 'dynamic-history-sorttable'
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
            }
        }
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDDynamic -Id 'dynamic-history-sorttable' -Content {
                try {
                    $cache:sortHistory = Import-Csv -LiteralPath $cache:historyPath -Encoding utf8 | Sort-Object Timestamp -Descending
                } catch {
                    Show-UDToast -CloseOnClick -Message "$PSItem" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                }
                New-UDTable -Title $cache:historyPath -Data $cache:sortHistory -Sort -Filter -Search -PageSize 5 -Padding 'dense'

                #New-UDChartJS -Type 'bar' -Data $cache:sortHistory -DataProperty Maker
                #New-UDCard -Content {
                #$makerData = $cache:sortHistory | Group-Object maker | Sort-Object Count -Descending | Select-Object -First 10
                #New-UDChartJS -Type 'bar' -Data $makerData -DataProperty Count -LabelProperty Name
                #$dateData = $cache:sortHistory | Select-Object @{Name = 'Year'; Expression = { (Get-Date $_.Timestamp).Year } }, @{Name = 'Month'; Expression = { (Get-Date $_.Timestamp).Month } }, @{Name = 'Day'; Expression = { (Get-Date $_.Timestamp).Day } } | Group-Object Year, Month | Select-Object -First 12
                #New-UDChartJS -Type 'bar' -Data $dateData -DataProperty Count -LabelProperty Name
                #}
            }
        }
    }
}
