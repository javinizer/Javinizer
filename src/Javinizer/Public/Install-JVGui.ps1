function Install-JVGui {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]$PSUDownloadUrl = 'https://imsreleases.blob.core.windows.net/universal/production/1.5.13/Universal.win7-x64.1.5.13.zip',

        [Parameter()]
        [Switch]$Force
    )

    if (Test-Administrator) {
        if ($IsWindows) {
            Write-Host "Starting Javinizer GUI install..."
            Write-Host "Use the -Force parameter if you want to overwrite the existing PowerShell Universal install"
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

            # Get module details
            $psuVersion = '1.5.13'
            $javinizerModulePath = (Get-InstalledModule -Name Javinizer).InstalledLocation
            $javinizerRepoPath = Join-Path -Path $javinizerModulePath -ChildPath 'Universal' -AdditionalChildPath 'Repository'
            $javinizerGuiScriptPath = Join-Path -Path $javinizerRepoPath -ChildPath 'javinizergui.ps1'
            $javinizerConfigScriptPath = Join-Path -Path $javinizerRepoPath -ChildPath 'dashboards.ps1'

            # Get PowerShell Universal details
            $psuPath = Join-Path -Path $env:programfiles -ChildPath 'Javinizer' -AdditionalChildPath $psuVersion
            $psuBinaryPath = Join-Path -Path $psuPath -ChildPath 'Universal.Server.exe'
            $psuUniversalPath = Join-Path -Path $psuPath -ChildPath 'Universal'
            $psuRepoPath = Join-Path -Path $psuUniversalPath -ChildPath 'Repository'
            $psuConfigPath = Join-Path -Path $psuRepoPath -ChildPath '.universal'
            $psuAssetsPath = Join-Path -Path $psuUniversalPath -ChildPath 'Dashboard'
            $psuGuiScriptPath = Join-Path $psuRepoPath -ChildPath 'javinizergui.ps1'
            $psuConfigDashboardScriptPath = Join-Path $psuConfigPath -ChildPath 'dashboards.ps1'
            $psuDownloadPath = Join-Path -Path $env:TEMP -ChildPath "Universal.win-x64.$psuVersion.zip"
            $installedPSModules = Get-InstalledModule
            $javinizerModulePath = (Get-InstalledModule -Name Javinizer).InstalledLocation

            $requiredPSModules = @(
                'UniversalDashboard.Style',
                'UniversalDashboard.UDPlayer',
                'UniversalDashboard.UDSpinner',
                'UniversalDashboard.UDScrollUp',
                'UniversalDashboard.CodeEditor'
            )

            $requiredPyModules = @(
                'googletrans',
                'google-trans-new',
                'pillow'
            )

            # Install Universal Dashboard modules used by Javinizer dashboard
            Write-Host "Installing required modules..."
            foreach ($module in $requiredPSModules) {
                if ($installedPSModules.Name -notcontains $module) {
                    Write-Host "Module [$module] not detected, installing"
                    try {
                        Install-Module -Name $module -Force -AllowClobber -Confirm:$false
                        Write-Host "Module [$module] installed"
                    } catch {
                        Write-Error "Error installing module [$module]: $PSItem"
                        return
                    }
                } else {
                    Write-Host "Module [$module] is already installed"
                }
            }

            # Check if the PowerShell Universal binary is already installed
            if (!(Test-Path -Path $psuBinaryPath) -or $Force) {
                try {
                    Write-Host "Installing PowerShell Universal..."
                    Invoke-WebRequest -Uri $PSUDownloadUrl -OutFile $psuDownloadPath

                    # Create GUI directory within the Javinizer module path
                    if (!(Test-Path -Path $psuPath) -or $Force) {
                        New-Item -Path $psuPath -ItemType 'Directory' -Force:$Force | Out-Null
                    }

                    # Extract the PowerShell Universal contents to the GUI directory
                    Write-Host "Extracting PowerShell Universal to [$psuPath]..."
                    Expand-Archive -Path $psuDownloadPath -DestinationPath $psuPath -Force:$Force
                } catch {
                    Remove-Item -Path $psuPath -ErrorAction SilentlyContinue
                    Write-Error "Error downloading and extracting PowerShell Universal: $PSItem"
                    return
                } finally {
                    # Clean up the PowerShell Universal zip file
                    Remove-Item -Path $psuDownloadPath -ErrorAction 'SilentlyContinue'
                }
            } else {
                Write-Host "PowerShell Universal is already installed at [$psuPath]"
            }

            try {
                Write-Host "Creating PowerShell Universal repository path at [$psuRepoPath]..."
                New-Item -Path $psuRepoPath -ItemType Directory -Force | Out-Null

                Write-Host "Creating PowerShell Universal configs path at [$psuConfigPath]"
                New-Item -Path $psuConfigPath -ItemType Directory -Force | Out-Null

                Write-Host "Creating PowerShell Universal assets path at [$psuAssetsPath]..."
                New-Item -Path $psuAssetsPath -ItemType Directory -Force | Out-Null

                Write-Host "Copying javinizergui.ps1 script to [$psuGuiScriptPath]..."
                Copy-Item -Path $javinizerGuiScriptPath -Destination $psuGuiScriptPath -Force | Out-Null

                Write-Host "Copying dashboards.ps1 script to [$psuConfigPath]"
                Copy-Item -Path $javinizerConfigScriptPath -Destination $psuConfigDashboardScriptPath -Force | Out-Null
            } catch {
                Remove-Item -Path $psuPath -ErrorAction SilentlyContinue
                Write-Error "Error occurred when creating PowerShell Universal directories: $PSItem"
                return
            }

            try {
                Write-Host "Setting ACL on [$psuPath]..."
                $psuAcl = Get-Acl -Path $psuPath
                # Find Windows SID values here https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/security-identifiers-in-windows#well-known-sids-all-versions-of-windows
                $everyoneAccountName = ([wmi]"Win32_SID.SID='S-1-1-0'").AccountName
                $aclRule = New-Object System.Security.AccessControl.FileSystemAccessRule($everyoneAccountName, "FullControl", "ContainerInherit,Objectinherit", "none", "Allow")
                $psuAcl.AddAccessRule($aclRule)
                Set-Acl -Path $psuPath -AclObject $psuAcl
            } catch {
                Remove-Item -Path $psuPath -ErrorAction SilentlyContinue
                Write-Error "Error occurred when setting ACL on [$psuUniversalPath]: $PSItem" -ErrorAction Stop
                return
            }

            # Windows service deployment is deprecated due to requiring admin scope privileges during runtime
            # To allow easier access to network drives, we will only be copying the files/executable
            # And running the executable in a non-admin scope

            <# $svcCheck = Get-Service -Name Javinizer -ErrorAction SilentlyContinue
            if ($svcCheck) {
                Write-Host "Removing the existing Javinizer service..."
                Remove-Service -Name Javinizer
            }

            $serviceParams = @{
                Name           = 'Javinizer'
                DisplayName    = 'Javinizer'
                StartUpType    = 'Automatic'
                BinaryPathName = "`"$psuBinaryPath`" --service"
                Description    = 'PowerShell Universal Javinizer runtime service'
                ErrorAction    = 'Stop'
            }

            New-Service @serviceParams | Out-Null
            Start-Service -Name 'Javinizer' #>

            Write-Host "Javinizer GUI successfully installed!" -ForegroundColor Green
            Write-Host "If all modules are installed, open the GUI using 'Javinizer -OpenGUI'" -ForegroundColor Green
        } else {
            Write-Warning "This feature is only available on Windows"
            return
        }
    } else {
        Write-Warning "Installing the Javinizer GUI requires PowerShell 7 (pwsh.exe) to be run as administrator"
        return
    }
}
