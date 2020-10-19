Import-Module "/root/.local/share/powershell/Modules/Javinizer/2.1.4/Javinizer.psm1"

$Pages = @()

Get-ChildItem (Join-Path $PSScriptRoot "pages") -Recurse -File | ForEach-Object {
    $Page = . $_.FullName
    $Pages += $Page
}

New-UDDashboard -Title "Javinizer Web" -Pages $Pages -Theme $Theme
