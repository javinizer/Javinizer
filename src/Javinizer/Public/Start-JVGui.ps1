function Start-JVGui {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(0, 65353)]
        [Int]$Port = 8600
    )

    # Get module details
    $psuVersion = '1.5.13'
    $javinizerModulePath = (Get-InstalledModule -Name Javinizer).InstalledLocation
    $javinizerRepoPath = Join-Path -Path $javinizerModulePath -ChildPath 'Universal' -AdditionalChildPath 'Repository'
    $javinizerGuiScriptPath = Join-Path -Path $javinizerRepoPath -ChildPath 'javinizergui.ps1'

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
        $moduleVersion = ((((Get-Content -Path $javinizerGuiScriptPath) -split "`n")[0] | Select-String -Pattern "'(.*)'").Matches.Groups[1].Value -split '-')[0]
        $currentVersion = ((((Get-Content -Path $psuGuiScriptPath) -split "`n")[0] | Select-String -Pattern "'(.*)'").Matches.Groups[1].Value -split '-')[0]

        # Update the script if the module version is different
        if ($currentVersion -ne $moduleVersion) {
            Write-Warning "New Javinizer GUI version detected"
            Write-Warning "Updating Javinizer GUI from $currentVersion => $moduleVersion"
            Copy-Item -Path $javinizerGuiScriptPath -Destination $psuGuiScriptPath -Force | Out-Null
        }
    } catch {
        Write-Warning "Error occurred when copying [$javinizerGuiScriptPath] to [$psuGuiScriptPath]: $PSItem"
    }

    try {
        $request = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/javinizer/Javinizer/master/src/Javinizer/Universal/Repository/javinizergui.ps1' -MaximumRetryCount 3 -Verbose:$false -ErrorAction SilentlyContinue
        $currentVersion = ((((Get-Content -Path $psuGuiScriptPath) -split "`n")[0] | Select-String -Pattern "'(.*)'").Matches.Groups[1].Value -split '-')[0]
        $currentRevision = ((((Get-Content -Path $psuGuiScriptPath) -split "`n")[0] | Select-String -Pattern "'(.*)'").Matches.Groups[1].Value -split '-')[1]
        $webVersion = (((($request.Content) -split "`n")[0] | Select-String -Pattern "'(.*)'").Matches.Groups[1].Value -split '-')[0]
        $webRevision = (((($request.Content) -split "`n")[0] | Select-String -Pattern "'(.*)'").Matches.Groups[1].Value -split '-')[1]

        # Check that the current module version is equal
        if ($currentVersion -eq $webVersion) {
            # Check that the current revision version is different
            # We want to automatically update to a new revision if the module version has not changed
            if ($currentRevision -ne $webRevision) {
                Write-Warning "New Javinizer GUI revision detected"
                Write-Warning "Updating Javinizer GUI to latest revision $currentVersion-$currentRevision => $webVersion-$webRevision"
                $request.Content | Out-File -FilePath $psuGuiScriptPath -Force
                Write-Warning "Updated GUI contents written to [$psuGuiScriptPath]"
            }
        } else {
            Write-Warning "There is a new version of Javinizer available $currentVersion-$currentRevision => $webVersion-$webRevision"
            Write-Warning "Update your module to get the new version"
        }
    } catch {
        Write-Warning "Error occurred when checking Javinizer repository for GUI updates: $PSItem"
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

    $timeout = New-TimeSpan -Seconds 15
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    do {
        $httpRequest = [System.Net.WebRequest]::Create("http://localhost:$Port/")
        try {
            $httpResponse = $httpRequest.GetResponse()
        } catch {
            # Silence http response errors
        }
        $httpStatusCode = [int]$httpResponse.StatusCode
    } while ($httpStatusCode -ne 200 -and $stopwatch.elapsed -lt $timeout)

    Start-Process "http://localhost:$Port/"
    Write-Host "Javinizer GUI started at [http://localhost:$Port/]"
    Write-Host "To specify a custom port, use the -Port parameter (0 - 65353)"
    Write-Host "If you see a 'Not Running' screen, remove the '/not-running' or wait for the page to reload"
}
