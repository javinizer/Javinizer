
# Set default paths
$cache:modulePath = '/home/Javinizer/src/Javinizer/'
$cache:fullModulePath = Join-Path -Path $cache:modulePath -ChildPath 'Javinizer.psm1'
$cache:defaultSettingsPath = Join-Path -Path $cache:modulePath -ChildPath 'jvSettings.json'
$cache:settingsPath = Join-Path -Path $cache:modulePath -ChildPath 'jvSettings.json'
$cache:defaultLogPath = Join-Path -Path $cache:modulePath -ChildPath 'jvLog.log'
$cache:defaultHistoryPath = Join-Path -Path $cache:modulePath -ChildPath 'jvHistory.csv'
$cache:defaultThumbPath = Join-Path -Path $cache:modulePath -ChildPath 'jvThumbs.csv'
Import-Module "/home/UniversalDashboard.CodeEditor/1.0.4/UniversalDashboard.CodeEditor.psd1"
Import-Module UniversalDashboard.Style
Import-Module UniversalDashboard.UDPlayer
Import-Module UniversalDashboard.UDScrollUp
Import-Module UniversalDashboard.UDSpinner
Import-Module $cache:fullModulePath
$cache:settings = Get-Content -Path $cache:settingsPath | ConvertFrom-Json
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


$Pages = @()
Get-ChildItem (Join-Path $PSScriptRoot "pages") -Recurse -File | ForEach-Object {
    $Page = . $_.FullName
    $Pages += $Page
}

$Theme = @{
    light = @{
        spacing = 4
        shape   = @{
            borderRadius = 5
        }
        palette = @{
            type    = 'light'
            primary = @{
                main = "#303f9f"
            }
            grey    = @{
                '300' = '#303f9f'
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
                paper   = ' #333333'
            }
            primary    = @{
                main = '#303f9f'
            }
            grey       = @{
                '300' = '#303f9f'
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

New-UDDashboard -Title "Javinizer Web" -Pages $Pages -Theme $Theme
