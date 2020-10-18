Import-Module "C:\ProgramData\Javinizer\src\Javinizer\Javinizer.psd1"

$Pages = @()

Get-ChildItem (Join-Path $PSScriptRoot "pages") -Recurse -File | ForEach-Object {
    $Page = . $_.FullName
    $Pages += $Page
}

New-UDDashboard -Title "PowerShell Universal Dashboard" -Pages $Pages -Theme $Theme
