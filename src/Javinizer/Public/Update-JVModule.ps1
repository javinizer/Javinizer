function Update-JVModule {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Check')]
        [Switch]$CheckUpdates,

        [Parameter(ParameterSetName = 'Update')]
        [Switch]$Update
    )

    begin {

    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            'Check' {
                if (!($global:jvUpdateCheck)) {
                    # Set global variable to determine that check has already been completed in the current session
                    $global:jvUpdateCheck = $true
                    $installedVersion = (Get-JVModuleInfo).Version
                    $latestVersion = (Find-Module -Name 'Javinizer').Version
                    Write-Debug "Installed version: $installedVersion"
                    Write-Debug "Latest version: $latestVersion"

                    if ($installedVersion -ne $latestVersion) {
                        Write-Warning "There is a newer version of Javinizer available! (Set 'admin.updates.check' to false to hide this message)"
                        Write-Warning "$installedVersion => $latestVersion"
                    }
                }
            }

            'Update' {
                try {
                    Get-InstalledModule -Name 'Javinizer' | Out-Null
                } catch {
                    Write-Error "You can only use this method to update if you installed Javinizer using 'Install-Module'" -ErrorAction Stop
                }

                $installedVersion = (Get-JVModuleInfo).Version
                $latestVersion = (Find-Module -Name 'Javinizer').Version

                if ($installedVersion -ne $latestVersion) {
                    Write-Warning "Starting update process, please make sure to close all related Javinizer settings files before continuing"
                    Write-Warning "Updating from version [$installedVersion => $latestVersion]"
                    Pause

                    try {
                        $origSettings = Get-JVSettings

                        if (Test-Path -Path $origSettings.'location.thumbcsv') {
                            $origThumbsPath = (Get-Item -Path $origSettings.'location.thumbcsv').FullName
                        } else {
                            $origThumbsPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'
                        }

                        if (Test-Path -Path $origSettings.'location.genrecsv') {
                            $origGenresPath = (Get-Item -Path $origSettings.'location.genrecsv').FullName
                        } else {
                            $origGenresPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvGenres.csv'
                        }

                        if (Test-Path -Path $origSettings.'location.uncensorcsv') {
                            $origUncensorPath = (Get-Item -Path $origSettings.'location.uncensorcsv').FullName
                        } else {
                            $origUncensorPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvUncensor.csv'
                        }

                        if (Test-Path -Path $origSettings.'location.historycsv') {
                            $origHistoryPath = (Get-Item -Path $origSettings.'location.historycsv').FullName
                        } else {
                            $origHistoryPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvHistory.csv'
                        }

                        if (Test-Path -Path $origSettings.'location.tagcsv') {
                            $origTagsPath = (Get-Item -Path $origSettings.'location.tagcsv').FullName
                        } else {
                            $origTagsPath = Join-Path -Path ((Get-Item $PSSCriptRoot).Parent) -ChildPath 'jvTags.csv'
                        }

                        # Write all settings configurations to memory
                        $origThumbs = Import-Csv -Path $origThumbsPath -Encoding utf8 -ErrorAction Continue
                        $origGenres = Import-Csv -Path $origGenresPath -Encoding utf8 -ErrorAction Continue
                        $origUncensor = Import-Csv -Path $origUncensorPath -Encoding utf8 -ErrorAction Continue
                        $origHistory = Import-Csv -Path $origHistoryPath -Encoding utf8 -ErrorAction Continue
                        $origTags = Import-Csv -Path $origTagsPath -Encoding utf8 -ErrorAction Continue

                    } catch {
                        Write-Error "Error occurred when retrieving existing settings: $PSItem" -ErrorAction Stop
                    }

                    try {
                        Update-Module -Name 'Javinizer' -Force -Confirm:$false
                    } catch {
                        Write-Error "Error occurred when updating the Javinizer module: $PSItem" -ErrorAction Stop
                    }

                    $newModulePath = (Get-InstalledModule -Name 'Javinizer').InstalledLocation

                    # Update jvSettings
                    $newSettingsPath = Join-Path -Path $newModulePath -ChildPath 'jvSettings.json'
                    $newSettings = Get-JVSettings -Path $newSettingsPath
                    $origSettings.PSObject.Properties | ForEach-Object {
                        $newSettings."$($_.Name)" = $_.Value
                    }

                    $newSettings | ConvertTo-Json -Depth 32 | Out-File -FilePath $newSettingsPath -Force -ErrorAction Continue

                    # Update jvThumbs
                    try {
                        $newThumbsPath = Join-Path -Path $newModulePath -ChildPath 'jvThumbs.csv'
                        $newThumbs = Import-Csv -Path $newThumbsPath -Encoding utf8
                        $thumbsDifference = (Compare-Object -ReferenceObject $origThumbs -DifferenceObject $newThumbs -ErrorAction SilentlyContinue).InputObject
                        $thumbsDifference | Export-Csv -Path $newThumbsPath -Append -Encoding utf8 -ErrorAction Continue
                    } catch {
                        Write-Error "Error [$origThumbsPath]: $PSItem"
                    }

                    # Update jvGenres
                    try {
                        $newGenresPath = Join-Path -Path $newModulePath -ChildPath 'jvGenres.csv'
                        $newGenres = Import-Csv -Path $newGenresPath -Encoding utf8
                        $genresDifference = (Compare-Object -ReferenceObject $origGenres -DifferenceObject $newGenres -ErrorAction SilentlyContinue).InputObject
                        $genresDifference | Export-Csv -Path $newGenresPath -Append -Encoding utf8 -ErrorAction Continue
                    } catch {
                        Write-Error "Error [$origGenresPath]: $PSItem"
                    }

                    # Update jvUncensor
                    try {
                        $newUncensorPath = Join-Path -Path $newModulePath -ChildPath 'jvGenres.csv'
                        $newUncensor = Import-Csv -Path $newUncensorPath -Encoding utf8
                        $uncensorDifference = (Compare-Object -ReferenceObject $origUncensor -DifferenceObject $newUncensor -ErrorAction SilentlyContinue).InputObject
                        $uncensorDifference | Export-Csv -Path $newUncensorPath -Append -Encoding utf8 -ErrorAction Continue
                    } catch {
                        Write-Error "Error [$origUncensorPath]: $PSItem"
                    }

                    # Update jvHistory
                    try {
                        $newHistoryPath = Join-Path -Path $newModulePath -ChildPath 'jvHistory.csv'
                        $newHistory = Import-Csv -Path $newHistoryPath -Encoding utf8
                        $historyDifference = (Compare-Object -ReferenceObject $origHistory -DifferenceObject $newHistory -ErrorAction SilentlyContinue).InputObject
                        $historyDifference | Export-Csv -Path $newHistoryPath -Append -Encoding utf8 -ErrorAction Continue
                    } catch {
                        Write-Error "Error [$origHistoryPath]: $PSItem"
                    }

                    # Update jvTags
                    try {
                        $newTagsPath = Join-Path -Path $newModulePath -ChildPath 'jvTags.csv'
                        $newTags = Import-Csv -Path $newTagsPath -Encoding utf8
                        $tagsDifference = (Compare-Object -ReferenceObject $origTags -DifferenceObject $newTags -ErrorAction SilentlyContinue).InputObject
                        $tagsDifference | Export-Csv -Path $newTagsPath -Append -Encoding utf8 -ErrorAction Continue
                    } catch {
                        Write-Error "Error [$origTagsPath]: $PSItem"
                    }
                } else {
                    Write-Warning "You already have the latest version of Javinizer! [$installedVersion]"
                }
            }
        }
    }
}
