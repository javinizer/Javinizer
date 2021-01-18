function Start-JVGui {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(0, 65353)]
        [Int]$Port = 8600
    )

    $jvModulePath = (Get-InstalledModule -Name Javinizer).InstalledLocation
    $jvPsuPath = Join-Path -Path $jvModulePath -ChildPath 'GUI'
    $jvPsuExePath = Join-Path -Path $jvPsuPath -ChildPath 'Universal.Server.exe'
    $jvPsuSettingsPath = Join-Path -Path $jvPsuPath -ChildPath 'appsettings.json'
    $jvPsuRepositoryPath = Join-Path -Path $jvModulePath -ChildPath 'Universal' -AdditionalChildPath 'Repository'
    $jvDashboardPath = Join-Path -Path $jvPsuRepositoryPath -ChildPath 'javinizergui.ps1'
    $jvPsuDatabasePath = Join-Path -Path $jvModulePath -ChildPath 'Universal' -AdditionalChildPath 'database.db'
    $jvPsuAssetsFolderPath = Join-Path -Path $jvModulePath -ChildPath 'Universal' -AdditionalChildPath 'Dashboard'

    # Check if the dashboard file is valid
    $dashboardContent = Get-Content -Path $jvDashboardPath -Raw

    if ($dashboardContent -notmatch 'Javinizer Web') {
        Write-Warning "Javinizer dashboard content is invalid, redownloading..."
        try {
            $origDashboardContent = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/jvlflame/Javinizer/master/src/Javinizer/Universal/Repository/javinizergui.ps1' -Verbose:$false
            Set-Content -Path $jvDashboardPath -Value $origDashboardContent -Force -
        } catch {
            Write-Error "Error occurred when resetting Javinizer dashboard: $PSItem"
        }
    }

    # Customize the default appsettings.json for Javinizer specific usage
    $jvPsuSettings = Get-Content -Path $jvPsuSettingsPath | ConvertFrom-Json -Depth 32
    $jvPsuSettings.Kestrel.Endpoints.HTTP.Url = "http://*:$Port"
    $jvPSuSettings.Data.RepositoryPath = $jvPsuRepositoryPath
    $jvPsuSettings.Data.ConnectionString = $jvPsuDatabasePath
    $jvPsuSettings.UniversalDashboard.AssetsFolder = $jvPsuAssetsFolderPath

    # Write settings back to appsettings.json
    $jvPsuSettings | ConvertTo-Json -Depth 32 | Out-File -FilePath $jvPsuSettingsPath -Force

    try {
        Start-Process -FilePath $jvPsuExePath -Verb RunAs
    } catch {
        Write-Error "Error starting Javinizer PowerShell Universal client: $PSItem" -ErrorAction Stop
    }

    Start-Process "http://localhost:$Port/dashboard"
}
