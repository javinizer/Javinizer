New-UDPage -Name 'Log' -Content {
    New-UDScrollUp

    New-UDDynamic -Content {
        New-UDCard {
            New-UDGrid -Container -Content {
                New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {

                }
            }
        }

    }
    <# #New-UDPlayer -URL "https://www.youtube.com/watch?v=yRYFKcMa_Ek&list=RDU7-q1WRaKNg&index=2"
    $rawLog = (Get-Content -LiteralPath 'C:\ProgramData\Javinizer\src\Javinizer\jvLog.log')
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
        Show-UDModal -FullScreen -Content {
            New-UDCodeEditor -Id 'FullLogEditor' -HideCodeLens -Language 'powershell' -Height '175ch' -Width '175ch' -Theme vs-dark -ReadOnly -Code $fullLog
        } -Footer {
            New-UDButton 'Close' -OnClick {
                Hide-UDModal
            }
        }
    }
    New-UDTypography -Variant h5 -Text "Last 50 Entries"
    New-UDDynamic -Content {
        New-UDGrid -Container -Content {
            New-UDCodeEditor -Id 'LogEditor' -HideCodeLens -Language 'powershell' -Height '150ch' -Width '250ch' -Theme vs-dark -ReadOnly -Code $recentLog
        }
    } #>
}
