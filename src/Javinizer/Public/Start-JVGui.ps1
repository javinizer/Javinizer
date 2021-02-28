function Start-JVGui {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(0, 65353)]
        [Int]$Port = 8600
    )

    # Get module details
    $psuVersion = '1.5.13'

    # Get PowerShell Universal details
    $psuPath = Join-Path -Path $env:programfiles -ChildPath 'Javinizer' -AdditionalChildPath $psuVersion
    $psuUniversalPath = Join-Path -Path $psuPath -ChildPath 'Universal'
    $psuBinaryPath = Join-Path -Path $psuPath -ChildPath 'Universal.Server.exe'
    $psuAppSettingsPath = Join-Path -Path $psuPath -ChildPath 'appsettings.json'
    $psuRepoPath = Join-Path -Path $psuUniversalPath -ChildPath 'Repository'
    $psuGuiScriptPath = Join-Path $psuRepoPath -ChildPath 'javinizergui.ps1'
    $psuDatabasePath = Join-Path -Path $psuUniversalPath -ChildPath 'database.db'
    $psuAssetsPath = Join-Path -Path $psuUniversalPath -ChildPath 'Dashboard'
    $psuConfigPath = Join-Path -Path $psuRepoPath -ChildPath '.universal'
    $psuConfigDashboardScriptPath = Join-Path $psuConfigPath -ChildPath 'dashboards.ps1'
    $psuLogPath = Join-Path -Path $psuUniversalPath -ChildPath 'log.txt'

    if (!(Test-Path -Path $psuPath)) {
        Write-Warning "Javinizer GUI installation not detected at path [$psuPath], run 'Javinizer -InstallGUI' to install"
        return
    }

    if (!(Test-Path -Path $psuConfigPath) -or !(Test-Path -Path $psuConfigDashboardScriptPath)) {
        Write-Warning "Default Javinizer configurations not detected at path [$psuConfigPath], run 'Javinizer -InstallGUI' to reinstall"
        return
    }

    if (!(Test-Path -Path $psuGuiScriptPath)) {
        Write-Warning "Javinizer GUI script file not detected at path [$psuGuiScriptPath], run 'Javinizer -InstallGUI' to reinstall"
        return
    }

    try {
        # Customize the default appsettings.json for Javinizer specific usage
        $psuAppSettings = Get-Content -Path $psuAppSettingsPath | ConvertFrom-Json -Depth 32
        $psuAppSettings.Kestrel.Endpoints.HTTP.Url = "http://*:$Port"
        $psuAppSettings.Logging.Path = $psuLogPath
        $psuAppSettings.Data.RepositoryPath = $psuRepoPath
        $psuAppSettings.Data.ConnectionString = $psuDatabasePath
        $psuAppSettings.UniversalDashboard.AssetsFolder = $psuAssetsPath

        # Write settings back to appsettings.json
        $psuAppSettings | ConvertTo-Json -Depth 32 | Out-File -FilePath $psuAppSettingsPath -Force
    } catch {
        Write-Error "Error occurred when writing PowerShell Universal appsettings: $PSItem"
        return
    }

    try {
        # We are using explorer.exe to run the binary as non-administrator
        # This allows users to access network drives more easily without
        # Needing to remap them in an administrator scope
        explorer.exe $psuBinaryPath
    } catch {
        Write-Error "Error starting Javinizer PowerShell Universal: $PSItem"
        return
    }

    Write-Host "Waiting for Javinizer dashboard to start..." -NoNewline
    $timeout = New-TimeSpan -Seconds 15
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    do {
        $httpRequest = [System.Net.WebRequest]::Create("http://localhost:$Port/javinizer")
        $httpResponse = $httpRequest.GetResponse()
        $httpStatusCode = [int]$httpResponse.StatusCode
        Write-Host '.'
        Start-Sleep -Seconds 2
    } while ($httpStatusCode -ne 200 -and $stopwatch.elapsed -lt $timeout)

    Start-Process "http://localhost:$Port/javinizer"
    Write-Host "Javinizer GUI started at [http://localhost:$Port/javinizer]"
    Write-Host "To specify a custom port, use the -Port parameter (0 - 65353)"
}
