function Install-JVGui {
    [CmdletBinding()]
    param (

    )
    begin {
        Write-Host "Installing Javinizer GUI..."
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

        $javinizerModulePath = (Get-InstalledModule -Name Javinizer).InstalledLocation
        $javinizerPsuPath = Join-Path -Path $javinizerModulePath -ChildPath 'GUI'
        $psuDownloadPath = Join-Path -Path $env:TEMP -ChildPath 'Universal.win-x64.1.4.7.zip'
        $psuUrl = 'https://imsreleases.blob.core.windows.net/universal/production/1.4.7/Universal.win-x64.1.4.7.zip'

        $installedPSModules = Get-InstalledModule
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
    }

    process {
        # Install Universal Dashboard modules used by Javinizer dashboard
        Write-Host "Installing required modules..."
        foreach ($module in $requiredPSModules) {
            if ($installedPSModules.Name -notcontains $module) {
                Write-Host "    [-] PowerShell module $module not detected, installing" -ForegroundColor Yellow
                Install-Module -Name $module -Force -Confirm:$false
            } else {
                Write-Host "    [+] PowerShell module $module is already installed" -ForegroundColor Green
            }
        }

        # Check if the PowerShell Universal binary is already installed
        if (!(Test-Path -Path (Join-Path -Path $javinizerPsuPath -ChildPath 'Universal.Server.exe'))) {
            Write-Host "    [+] PowerShell Universal not detected, installing" -ForegroundColor Yellow
            # Download PowerShell Universal 1.4.7
            # We need this version to get Universal Dashboard framework 3.1.5
            Invoke-WebRequest -Uri $psuUrl -OutFile $psuDownloadPath

            # Create GUI directory within the Javinizer module path
            if (!(Test-Path -Path $javinizerPsuPath)) {
                New-Item -Path $javinizerPsuPath -ItemType 'Directory' | Out-Null
            }

            # Extract the PowerShell Universal contents to the GUI directory
            Write-Host "Extracting PowerShell Universal to $javinizerPsuPath..."
            Expand-Archive -Path $psuDownloadPath -DestinationPath $javinizerPsuPath -Force
        } else {
            Write-Host "    [+] PowerShell Universal is already installed" -ForegroundColor Green
        }

        Write-Host "Checking additional Javinizer dependencies..."
        $pythonVersion = python --version
        $pythonModules = pip list | Out-Null

        if ($pythonVersion -like 'Python 3*') {
            Write-Host "    [+] Python 3 is already installed" -ForegroundColor Green
        } else {
            Write-Host "    [-] Python 3 not installed, install Python 3 before using Javinizer." -ForegroundColor Red
        }

        foreach ($module in $requiredPyModules) {
            try {
                $pythonModules | Select-String -Pattern $module | Out-Null
                Write-Host "    [+] Python module $module is already installed" -ForegroundColor Green
            } catch {
                Write-Host "    [-] Python module $module not detected, install using pip." -ForegroundColor Red
            }
        }

        Write-Host "If all modules are installed, open the GUI using 'Javinizer -OpenGUI'"
        Write-Host "You will need to follow documentation to import the Javinizer dashboard for your first-run:"
        Write-Host "https://docs.jvlflame.net/v/2.2.6/installation/install-javinizer-web-gui#import-the-javinizer-dashboard"
    }

    end {
        # Clean up
        Remove-Item -Path $psuDownloadPath -ErrorAction 'SilentlyContinue'
    }
}
