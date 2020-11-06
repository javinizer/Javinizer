Import-Module "/home/Javinizer/src/Javinizer/Javinizer.psm1"
Import-Module "/home/UniversalDashboard.CodeEditor/1.0.4/UniversalDashboard.CodeEditor.psd1"
Import-Module UniversalDashboard.Style
Import-Module UniversalDashboard.SyntaxHighlighter
Import-Module UniversalDashboard.UDPlayer
Import-Module UniversalDashboard.UDScrollUp
Import-Module UniversalDashboard.UDSpinner

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
                '300' = '#e0e0e0'
                <# '50'   = '#fafafa100'
                '200'  = '#eeeeee'
                '400'  = '#bdbdbd'
                '500'  = '#9e9e9e'
                '600'  = '#757575'
                '700'  = '#616161'
                '800'  = '#424242'
                '900'  = '#212121'
                'A100' = '#d5d5d5'
                'A200' = '#aaaaaa'
                'A400' = '#303030'
                'A700' = '#61616' #>
            }
        }
    }

    dark  = @{
        spacing = 4
        shape   = @{
            borderRadius = 5
        }
        palette = @{
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
            action     = @{
                active             = '#fff'
                hover              = '#fff'
                hoverOpacity       = '0.80'
                selected           = '#fff'
                selectedOpacity    = '0.16'
                disabled           = '#fff'
                disabledBackground = '#fff'
                disabledOpacity    = '0.38'
                focus              = '#fff'
                focusOpacity       = '0.12'
                activatedOpacity   = '0.24'
            }

            secondary  = @{
                light        = '#0066ff'
                main         = '#0044ff'
                contrastText = '#ffcc00'
            }
        }
    }
}

New-UDDashboard -Title "Javinizer Web" -Pages $Pages -Theme $Theme
