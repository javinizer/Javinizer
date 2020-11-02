Import-Module "/home/Javinizer/src/Javinizer/Javinizer.psm1"
Import-Module "/home/UniversalDashboard.CodeEditor/1.0.4/UniversalDashboard.CodeEditor.psd1"
Import-Module UniversalDashboard.Style

$Pages = @()

Get-ChildItem (Join-Path $PSScriptRoot "pages") -Recurse -File | ForEach-Object {
    $Page = . $_.FullName
    $Pages += $Page
}

New-UDDashboard -Title "Javinizer Web" -Pages $Pages -Theme $Theme
