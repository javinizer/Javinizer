function Update-JVModule {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Check')]
        [Switch]$CheckUpdates,

        [Parameter(ParameterSetName = 'Update')]
        [Switch]$Update,

        [Parameter(ParameterSetName = 'Check')]
        [Switch]$IsWeb,

        [Parameter(ParameterSetName = 'Check')]
        [Switch]$GuiVersion,

        [Parameter(ParameterSetName = 'Update')]
        [String]$UpdateUrl = 'https://raw.githubusercontent.com/javinizer/Javinizer/master/src/Javinizer/Misc/Invoke-Update.ps1'
    )

    process {
        switch ($PsCmdlet.ParameterSetName) {
            'Check' {
                if ($IsWeb) {
                    $installedVersion = (Get-JVModuleInfo).Version
                    $latestVersion = ((Find-Module -Name 'Javinizer') | Select-Object -First 1).Version
                    if ([System.Version]$installedVersion -lt [System.Version]$latestVersion) {
                        Show-JVToast -Type Success -Message "There is a new version of Javinizer available $installedVersion => $latestVersion"
                    } else {
                        Show-JVToast -Type Info -Message "There are no updates for Javinizer available"
                    }

                    $guiCheck = Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/javinizer/Javinizer/master/src/Javinizer/Universal/Repository/javinizergui.ps1' -MaximumRetryCount 3
                    $latestGuiVersion = ($guiCheck.Content | Select-String -Pattern "\`$cache\:guiVersion = '(.*)'").Matches.Groups[1].Value

                    if ([System.Version]$GuiVersion -lt [System.Version]$latestGuiVersion) {
                        Show-JVToast -Type Success -Message "There is a new version of Javinizer GUI available $GuiVersion => $latestGuiVersion"
                    } else {
                        Show-JVToast -Type Info -Message "There are no updates for Javinizer GUI available"
                    }
                }
                if (!($global:jvUpdateCheck)) {
                    # Set global variable to determine that check has already been completed in the current session
                    $global:jvUpdateCheck = $true
                    $installedVersion = (Get-JVModuleInfo).Version
                    $latestVersion = ((Find-Module -Name 'Javinizer') | Select-Object -First 1).Version
                    Write-Debug "Installed version: $installedVersion"
                    Write-Debug "Latest version: $latestVersion"

                    if ([System.Version]$installedVersion -lt [System.Version]$latestVersion) {
                        Write-Warning "There is a newer version of Javinizer available! (Set 'admin.updates.check' to false to hide this message)"
                        Write-Warning "You can update your module using 'Javinizer -UpdateModule'"
                        Write-Warning "$installedVersion => $latestVersion"
                    }
                }
            }

            'Update' {
                try {
                    Get-InstalledModule -Name 'Javinizer' -ErrorAction Stop | Out-Null
                } catch {
                    Write-Error "You can only use this method to update if you installed Javinizer using 'Install-Module'" -ErrorAction Stop
                }

                $installedVersion = (Get-JVModuleInfo).Version
                $latestVersion = ((Find-Module -Name 'Javinizer') | Select-Object -First 1).Version

                if ([System.Version]$installedVersion -lt [System.Version]$latestVersion) {
                    Write-Warning "Starting update process, please make sure to close all related Javinizer settings files before continuing"
                    Write-Warning "Updating from version [$installedVersion => $latestVersion]"
                    Pause

                    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($UpdateUrl))
                } else {
                    Write-Warning "You already have the latest version of Javinizer! [$installedVersion]"
                }
            }
        }
    }
}
