Write-Progress -Status "Updating Javinizer" -Activity "Fetching Javinizer settings files..." -PercentComplete 25
$modulePath = (Get-InstalledModule Javinizer).InstalledLocation
$origSettings = Get-Content -Path (Join-Path -Path $modulePath -ChildPath 'jvSettings.json') | ConvertFrom-Json -Depth 32

try {
    if (Test-Path -Path $origSettings.'location.thumbcsv') {
        $origThumbsPath = (Get-Item -Path $origSettings.'location.thumbcsv').FullName
    } else {
        $origThumbsPath = Join-Path -Path $modulePath -ChildPath 'jvThumbs.csv'
    }

    $origThumbs = Import-Csv -Path $origThumbsPath -Encoding utf8 -ErrorAction Continue
} catch {
    Write-Error "Error occurred when retrieving thumb csv [$origThumbsPath]: $PSItem" -ErrorAction Stop
}

try {
    if (Test-Path -Path $origSettings.'location.genrecsv') {
        $origGenresPath = (Get-Item -Path $origSettings.'location.genrecsv').FullName
    } else {
        $origGenresPath = Join-Path -Path $modulePath -ChildPath 'jvGenres.csv'
    }

    $origGenres = Import-Csv -Path $origGenresPath -Encoding utf8 -ErrorAction Continue
} catch {
    Write-Error "Error occurred when retrieving genre csv [$origGenresPath]: $PSItem" -ErrorAction Stop
}

try {
    if (Test-Path -Path $origSettings.'location.uncensorcsv') {
        $origUncensorPath = (Get-Item -Path $origSettings.'location.uncensorcsv').FullName
    } else {
        $origUncensorPath = Join-Path -Path $modulePath -ChildPath 'jvUncensor.csv'
    }

    $origUncensor = Import-Csv -Path $origUncensorPath -Encoding utf8 -ErrorAction Continue
} catch {
    Write-Error "Error occurred when retrieving uncensor csv [$origUncensorPath]: $PSItem" -ErrorAction Stop
}

try {
    if (Test-Path -Path $origSettings.'location.historycsv') {
        $origHistoryPath = (Get-Item -Path $origSettings.'location.historycsv').FullName
    } else {
        $origHistoryPath = Join-Path -Path $modulePath -ChildPath 'jvHistory.csv'
    }

    $origHistory = Import-Csv -Path $origHistoryPath -Encoding utf8 -ErrorAction Continue
} catch {
    Write-Error "Error occurred when retrieving history csv [$origHistoryPath]: $PSItem" -ErrorAction Stop
}

try {
    if (Test-Path -Path $origSettings.'location.tagcsv') {
        $origTagsPath = (Get-Item -Path $origSettings.'location.tagcsv').FullName
    } else {
        $origTagsPath = Join-Path -Path $modulePath -ChildPath 'jvTags.csv'
    }

    $origTags = Import-Csv -Path $origTagsPath -Encoding utf8 -ErrorAction Continue
} catch {
    Write-Error "Error occurred when retrieving tag csv [$origTagsPath]: $PSItem" -ErrorAction Stop
}

try {
    Write-Progress -Status "Updating Javinizer" -Activity "Updating Javinizer module via PowerShell Gallery..." -PercentComplete 50
    Update-Module -Name 'Javinizer' -Force -Confirm:$false
} catch {
    Write-Error "Error occurred when updating the Javinizer module: $PSItem" -ErrorAction Stop
}

$newModulePath = (Get-InstalledModule -Name 'Javinizer').InstalledLocation

# Update jvSettings
$supportedScrapers = Get-Help Get-JVData -Parameter * | Select-Object -ExpandProperty aliases | Where-Object { $_.StartsWith("scraper.movie") } | ForEach-Object { $_.Replace("scraper.movie.", "") }
$newSettingsPath = Join-Path -Path $newModulePath -ChildPath 'jvSettings.json'
$newSettings = Get-JVSettings -Path $newSettingsPath
$newSettings.PSObject.Properties | ForEach-Object {
    $property = $_
    if ($origSettings.PSObject.Properties.Name -contains $_.Name) {
        $newSettings."$($_.Name)" = ($origSettings.PSObject.Properties | Where-Object { $_.Name -eq $property.Name })[0].Value
        if ($_.Name.StartsWith("sort.metadata.priority")) {
            $elementIndex = $_.Value.IndexOf(($_.Value | Where-Object { $_ -eq "r18" }))
            if ($elementIndex -ge 0) {
                $_.Value[$elementIndex] = "r18dev"
            }
            $newSettings."$($_.Name)" = $_.Value | Where-Object { $_ -in $supportedScrapers }
        }
    }
}

try {
    Write-Progress -Status "Updating Javinizer" -Activity "Migrating settings to $newSettingsPath..." -PercentComplete 65
    $newSettings | ConvertTo-Json -Depth 32 | Out-File -FilePath $newSettingsPath -Force -ErrorAction Continue
} catch {
    Write-Error "Error occurred when updating the existing settings file at path [$newSettingsPath]: $PSItem" -ErrorAction Continue
    $tempFile = New-TemporaryFile
    $newSettings | ConvertTo-Json -Depth 32 | Out-File -FilePath $tempFile
    Write-Warning "Writing updated settings file to temp location: $(Join-Path -Path $env:TEMP -ChildPath $tempFile)"
}

# Update jvThumbs
try {
    $newThumbsPath = Join-Path -Path $newModulePath -ChildPath 'jvThumbs.csv'
    Write-Progress -Status "Updating Javinizer" -Activity "Migrating thumbs to $newThumbsPath..." -PercentComplete 70
    Write-Host "Migrating $origThumbsPath => $newThumbsPath"
    Copy-Item -Path $origThumbsPath -Destination $newThumbsPath -Force
    <# $newThumbs = Import-Csv -Path $newThumbsPath -Encoding utf8
    if ($null -ne $origThumbs) {
        $thumbsDifference = (Compare-Object -ReferenceObject $origThumbs -DifferenceObject $newThumbs -ErrorAction SilentlyContinue).InputObject
        if ($thumbsDifference) {
            $thumbsDifference | Export-Csv -Path $newThumbsPath -Append -Encoding utf8 -ErrorAction SilentlyContinue
            Write-Host "Migrating $origThumbsPath => $newThumbsPath"
        } else {
            Write-Host "Migrating $origThumbsPath => $newThumbsPath (no changes)"
        }
    } #>
} catch {
    Write-Warning "Error [$origThumbsPath]: $PSItem"
}

# Update jvGenres
try {
    $newGenresPath = Join-Path -Path $newModulePath -ChildPath 'jvGenres.csv'
    Write-Progress -Status "Updating Javinizer" -Activity "Migrating genres to $newGenresPath..." -PercentComplete 75
    Write-Host "Migrating $origGenresPath => $newGenresPath"
    Copy-Item -Path $origGenresPath -Destination $newGenresPath -Force
    <# $newGenres = Import-Csv -Path $newGenresPath -Encoding utf8
    if ($null -ne $origGenres) {
        $genresDifference = (Compare-Object -ReferenceObject $origGenres -DifferenceObject $newGenres -ErrorAction SilentlyContinue).InputObject
        if ($genresDifference) {
            $genresDifference | Export-Csv -Path $newGenresPath -Append -Encoding utf8 -ErrorAction SilentlyContinue
        } else {
            Write-Host "Migrating $origGenresPath => $newGenresPath (no changes)"
        }
    } #>
} catch {
    Write-Warning "Error [$origGenresPath]: $PSItem"
}

# Update jvUncensor
try {
    $newUncensorPath = Join-Path -Path $newModulePath -ChildPath 'jvUncensor.csv'
    Write-Progress -Status "Updating Javinizer" -Activity "Migrating uncensors to $newUncensorPath..." -PercentComplete 80
    $newUncensor = Import-Csv -Path $newUncensorPath -Encoding utf8
    if ($null -ne $origUncensor) {
        $uncensorDifference = (Compare-Object -ReferenceObject $origUncensor -DifferenceObject $newUncensor -ErrorAction SilentlyContinue).InputObject
        if ($uncensorDifference) {
            $uncensorDifference | Export-Csv -Path $newUncensorPath -Append -Encoding utf8 -ErrorAction SilentlyContinue
            Write-Host "Migrating $origUncensorPath => $newUncensorPath"
        } else {
            Write-Host "Migrating $origUncensorPath => $newUncensorPath (no changes)"
        }
    }
} catch {
    Write-Warning "Error [$origUncensorPath]: $PSItem"
}

# Update jvHistory
try {
    $newHistoryPath = Join-Path -Path $newModulePath -ChildPath 'jvHistory.csv'
    Write-Progress -Status "Updating Javinizer" -Activity "Migrating history to $newHistoryPath..." -PercentComplete 85
    Write-Host "Migrating $origHistoryPath => $newHistoryPath"
    Copy-Item -Path $origHistoryPath -Destination $newHistoryPath -Force
    <# $newHistory = Import-Csv -Path $newHistoryPath -Encoding utf8
    if ($null -ne $origHistory) {
        $historyDifference = (Compare-Object -ReferenceObject $origHistory -DifferenceObject $newHistory -ErrorAction SilentlyContinue).InputObject
        if ($historyDifference) {
            $historyDifference | Export-Csv -Path $newHistoryPath -Append -Encoding utf8 -ErrorAction SilentlyContinue
        } else {
            Write-Host "Migrating $origHistoryPath => $newHistoryPath (no changes)"
        }
    } #>
} catch {
    Write-Warning "Error [$origHistoryPath]: $PSItem"
}

# Update jvTags
try {
    $newTagsPath = Join-Path -Path $newModulePath -ChildPath 'jvTags.csv'
    Write-Progress -Status "Updating Javinizer" -Activity "Migrating tags to $newTagsPath..." -PercentComplete 90
    Write-Host "Migrating $origTagsPath => $newTagsPath"
    Copy-Item -Path $origTagsPath -Destination $newTagsPath -Force
    <# $newTags = Import-Csv -Path $newTagsPath -Encoding utf8
    if ($null -ne $origTags) {
        $tagsDifference = (Compare-Object -ReferenceObject $origTags -DifferenceObject $newTags -ErrorAction SilentlyContinue).InputObject
        if ($tagsDifference) {
            $tagsDifference | Export-Csv -Path $newTagsPath -Append -Encoding utf8 -ErrorAction SilentlyContinue
        } else {
            Write-Host "Migrating $origTagsPath => $newTagsPath (no changes)"
        }
    } #>
} catch {
    Write-Warning "Error [$origTagsPath]: $PSItem"
}

Write-Host "Javinizer update completed! Restart your shell to continue." -ForegroundColor Green
