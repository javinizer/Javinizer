function Start-JVGui {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(0, 65353)]
        [Int]$Port = 5000
    )

    $jvModulePath = (Get-InstalledModule -Name Javinizer).InstalledLocation
    $jvPsuPath = Join-Path -Path $jvModulePath -ChildPath 'GUI'
    $jvPsuExePath = Join-Path -Path $jvPsuPath -ChildPath 'Universal.Server.exe'
    $jvPsuSettingsPath = Join-Path -Path $jvPsuPath -ChildPath 'appsettings.json'
    $jvPsuRepositoryPath = Join-Path -Path $jvPsuPath -ChildPath 'Universal' -AdditionalChildPath 'Repository'
    $jvPsuDatabasePath = Join-Path -Path $jvPsuPath -ChildPath 'Universal' -AdditionalChildPath 'database.db'
    $jvPsuAssetsFolderPath = Join-Path -Path $jvPsuPath -ChildPath 'Universal' -AdditionalChildPath 'Dashboard'

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
