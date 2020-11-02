Import-Module "/home/Javinizer/src/Javinizer/Javinizer.psm1"
Import-Module UniversalDashboard.Style
#Import-Module UniversalDashboard.CodeEditor

$Pages = @()

Get-ChildItem (Join-Path $PSScriptRoot "pages") -Recurse -File | ForEach-Object {
    $Page = . $_.FullName
    $Pages += $Page
}

New-UDDashboard -Title "Javinizer Web" -Pages $Pages -Theme $Theme
