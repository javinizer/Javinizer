function Update-JVNfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo]$Path,

        [Parameter()]
        [Switch]$Recurse,

        [Parameter()]
        [Int]$Depth,

        [Parameter()]
        [System.IO.DirectoryInfo]$ThumbCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvThumbs.csv'),

        [Parameter()]
        [System.IO.DirectoryInfo]$GenreCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvGenres.csv'),

        [Parameter()]
        [Boolean]$FirstNameOrder,

        [Parameter()]
        [Boolean]$ThumbCsv,

        [Parameter()]
        [Boolean]$ThumbCsvAlias,

        [Parameter()]
        [Boolean]$ActressLanguageJa,

        [Parameter()]
        [Boolean]$GenreCsv,

        [Parameter()]
        [Array]$GenreIgnore

    )

    process {
        if ($ThumbCsv) {
            $actressCsv = Import-Csv -LiteralPath $ThumbCsvPath
        }

        if ($GenreCsv) {
            $genresCsv = Import-Csv -LiteralPath $GenreCsvPath
        }

        if (Test-Path -LiteralPath $Path) {
            if ($Depth) {
                $nfoFiles = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse -Depth:$Depth | Where-Object { $_.Extension -eq '.nfo' }
            } else {
                $nfoFiles = Get-ChildItem -LiteralPath $Path -Recurse:$Recurse | Where-Object { $_.Extension -eq '.nfo' }
            }
        }

        if ($ThumbCsv) {
            if ($ThumbCsvAlias) {
                $aliases = @()
                $aliasObject = @()
                $csvAlias = $actressCsv.Alias
                foreach ($alias in ($csvAlias | Where-Object { $_ -ne '' })) {
                    $index = [Array]::IndexOf($csvAlias, $alias)
                    $aliases = $alias -split '\|'
                    foreach ($alias in $aliases) {
                        # Match if the name contains Japanese characters
                        if ($alias -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                            $aliasObject += [PSCustomObject]@{
                                LastName     = ''
                                FirstName    = ''
                                JapaneseName = $alias
                                Index        = $index
                            }
                        } else {
                            $nameParts = ($alias -split ' ').Count
                            if ($nameParts -eq 1) {
                                $lastName = ''
                                $firstName = $alias
                            } else {
                                $lastName = ($alias -split ' ')[0]
                                $firstName = ($alias -split ' ')[1]
                            }

                            $aliasObject += [PSCustomObject]@{
                                LastName     = $lastName
                                FirstName    = $firstName
                                JapaneseName = ''
                                Index        = $index
                            }
                        }
                    }
                }
            }
        }

        foreach ($file in $nfoFiles) {
            $matched = @()
            $matchedActress = @()
            $actressObject = @()
            $aliasSwitch = $false
            $nfoContent = Get-Content -LiteralPath $file
            $originalNfoContent = $nfoContent -join "`r`n"
            $nfoNameString = ($nfoContent | Select-String -Pattern '<name>(.*)<\/name>' -AllMatches).Matches | ForEach-Object { $_.Groups[0].Value }
            $nfoThumbString = ($nfoContent | Select-String -Pattern '<thumb>(.*)<\/thumb>' -AllMatches).Matches | ForEach-Object { $_.Groups[0].Value }

            # Check to make sure that the actress and thumb row counts are consistent
            # Otherwise we may overwrite the incorrect rows
            if ($nfoNameString.Count -eq $nfoThumbString.Count) {
                if ($ThumbCsv) {
                    $actressName = ($nfoContent | Select-String -Pattern '<name>(.*)<\/name>' -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value }
                    $actressThumb = ($nfoContent | Select-String -Pattern '<thumb>(.*)<\/thumb>' -AllMatches).Matches | ForEach-Object { $_.Groups[1].Value }

                    for ($x = 0; $x -lt $actressName.Count; $x++) {
                        if ($actressName.Count -eq 1) {
                            if ($actressName -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                                $actressObject += [PSCustomObject]@{
                                    LastName     = ''
                                    FirstName    = ''
                                    JapaneseName = $actressName
                                    ThumbUrl     = $actressThumb
                                }
                            } elseif ($FirstNameOrder) {
                                $actressObject += [PSCustomObject]@{
                                    LastName     = ($actressName -split ' ')[1]
                                    FirstName    = ($actressName -split ' ')[0]
                                    JapaneseName = ''
                                    ThumbUrl     = $actressThumb
                                }
                            } else {
                                $nameParts = ($actressName -split ' ').Count
                                if ($nameParts -eq 1) {
                                    $lastName = ''
                                    $firstName = $actressName
                                } else {
                                    $lastName = ($actressName -split ' ')[0]
                                    $firstName = ($actressName -split ' ')[1]
                                }

                                $actressObject += [PSCustomObject]@{
                                    LastName     = $lastName
                                    FirstName    = $firstName
                                    JapaneseName = ''
                                    ThumbUrl     = $actressThumb
                                }
                            }
                        } else {
                            if ($actressName[$x] -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                                $actressObject += [PSCustomObject]@{
                                    LastName     = ''
                                    FirstName    = ''
                                    JapaneseName = $actressName[$x]
                                    ThumbUrl     = $actressThumb[$x]
                                }
                            } elseif ($FirstNameOrder) {
                                $actressObject += [PSCustomObject]@{
                                    LastName     = ($actressName[$x] -split ' ')[1]
                                    FirstName    = ($actressName[$x] -split ' ')[0]
                                    JapaneseName = ''
                                    ThumbUrl     = $actressThumb[$x]
                                }
                            } else {
                                $nameParts = ($actressName[$x] -split ' ').Count
                                if ($nameParts -eq 1) {
                                    $lastName = ''
                                    $firstName = $actressName[$x]
                                } else {
                                    $lastName = ($actressName[$x] -split ' ')[0]
                                    $firstName = ($actressName[$x] -split ' ')[1]
                                }

                                $actressObject += [PSCustomObject]@{
                                    LastName     = $lastName
                                    FirstName    = $firstName
                                    JapaneseName = ''
                                    ThumbUrl     = $actressThumb[$x]
                                }
                            }
                        }
                    }

                    if ($ThumbCsvAlias) {
                        # Try three methods for matching aliases
                        # FirstName | FirstName, LastName | JapaneseName
                        for ($x = 0; $x -lt $actressObject.Count; $x++) {
                            $matched = @()
                            $currentName = $actressObject[$x]

                            if (($actressObject[$x].LastName -eq '' -and $actressObject[$x].FirstName -ne '') -and ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $actressObject[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName'))) {
                                $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                                if ($matched.Count -eq 1) {
                                    $actressObject[$x].FirstName = $actressCsv[$matched.Index].FirstName
                                    $actressObject[$x].LastName = $actressCsv[$matched.Index].LastName
                                    $actressObject[$x].JapaneseName = $actressCsv[$matched.Index].JapaneseName
                                    $actressObject[$x].ThumbUrl = $actressCsv[$matched.Index].ThumbUrl
                                    $actressString = $actressObject[$x] | ConvertTo-Json -Compress
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName match"
                                } elseif ($matched.Count -gt 1) {
                                    $actressObject[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                    $actressObject[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                    $actressObject[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                    $actressObject[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                    $actressString = $actressObject[$x] | ConvertTo-Json -Compress
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName match"
                                }
                            } elseif (($actressObject[$x].LastName -ne '' -and $actressObject[$x].FirstName -ne '') -and ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $actressObject[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName'))) {
                                $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                                if ($matched.Count -eq 1) {
                                    $actressObject[$x].FirstName = $actressCsv[$matched.Index].FirstName
                                    $actressObject[$x].LastName = $actressCsv[$matched.Index].LastName
                                    $actressObject[$x].JapaneseName = $actressCsv[$matched.Index].JapaneseName
                                    $actressObject[$x].ThumbUrl = $actressCsv[$matched.Index].ThumbUrl
                                    $actressString = $actressObject[$x] | ConvertTo-Json -Compress
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName LastName match"
                                } elseif ($matched.Count -gt 1) {
                                    $actressObject[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                    $actressObject[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                    $actressObject[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                    $actressObject[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                    $actressString = $actressObject[$x] | ConvertTo-Json -Compress
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using FirstName LastName match"
                                }
                            } elseif (($actressObject[$x].JapaneseName -ne '') -and ($matched = Compare-Object -ReferenceObject $aliasObject -DifferenceObject $actressObject[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName'))) {
                                $aliasString = "$($matched.LastName) $($matched.FirstName)".Trim()
                                if ($matched.Count -eq 1) {
                                    $actressObject[$x].FirstName = $actressCsv[$matched.Index].FirstName
                                    $actressObject[$x].LastName = $actressCsv[$matched.Index].LastName
                                    $actressObject[$x].JapaneseName = $actressCsv[$matched.Index].JapaneseName
                                    $actressObject[$x].ThumbUrl = $actressCsv[$matched.Index].ThumbUrl
                                    $actressString = $actressObject[$x] | ConvertTo-Json -Compress
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using JapaneseName match"
                                } elseif ($matched.Count -gt 1) {
                                    $actressString = "$($actressCsv[$matched.Index].LastName) $($actressCsv[$matched.Index].FirstName) - $($actressCsv[$matched[0].Index].JapaneseName)".Trim()
                                    $actressObject[$x].FirstName = $actressCsv[$matched[0].Index].FirstName
                                    $actressObject[$x].LastName = $actressCsv[$matched[0].Index].LastName
                                    $actressObject[$x].JapaneseName = $actressCsv[$matched[0].Index].JapaneseName
                                    $actressObject[$x].ThumbUrl = $actressCsv[$matched[0].Index].ThumbUrl
                                    $actressString = $actressObject[$x] | ConvertTo-Json -Compress
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [Alias - $aliasString] converted to [$actressString] using JapaneseName match"
                                }
                            }
                        }
                    }

                    for ($x = 0; $x -lt $actressObject.Count; $x++) {
                        $matched = @()
                        $matchedActress = @()
                        $actressString = ''

                        # Try three methods for matching aliases
                        # FirstName | FirstName, LastName | JapaneseName
                        if (($actressObject[$x].LastName -eq '' -and $actressObject[$x].FirstName -ne '') -and ($matched = Compare-Object -ReferenceObject ($actressCsv | Where-Object { $_.LastName -eq '' }) -DifferenceObject $actressObject[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName'))) {
                            if ($matched.Count -eq 1) {
                                $matchedActress = $matched
                            } elseif ($matched.Count -gt 1) {
                                $matchedActress = $matched[0]
                            }

                            if ($null -ne $matchedActress) {
                                $originalActressString = $actressObject[$x] | ConvertTo-Json -Compress
                                $actressObject[$x].ThumbUrl = $matchedActress.ThumbUrl
                                $actressObject[$x].JapaneseName = $matchedActress.JapaneseName
                                $actressString = $actressObject[$x] | ConvertTo-Json -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [$file] [Actress - $originalActressString] matched to [$actressString]"
                            }
                        } elseif ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $actressObject[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('FirstName', 'LastName')) {
                            if ($matched.Count -eq 1) {
                                $matchedActress = $matched
                            } elseif ($matched.Count -gt 1) {
                                $matchedActress = $matched[0]
                            }

                            if ($null -ne $matchedActress) {
                                $originalActressString = $actressObject[$x] | ConvertTo-Json -Compress
                                $actressObject[$x].ThumbUrl = $matchedActress.ThumbUrl
                                $actressObject[$x].JapaneseName = $matchedActress.JapaneseName
                                $actressString = $actressObject[$x] | ConvertTo-Json -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [$file] [Actress - $originalActressString] matched to [$actressString]"
                            }
                        } elseif (($actressObject[$x].JapaneseName -ne '') -and ($matched = Compare-Object -ReferenceObject $actressCsv -DifferenceObject $actressObject[$x] -IncludeEqual -ExcludeDifferent -PassThru -Property @('JapaneseName'))) {
                            if ($matched.Count -eq 1) {
                                $matchedActress = $matched
                            } elseif ($matched.Count -gt 1) {
                                $matchedActress = $matched[0]
                            }

                            if ($null -ne $matchedActress) {
                                $originalActressString = $actressObject[$x] | ConvertTo-Json -Compress
                                $actressObject[$x].FirstName = $matchedActress.FirstName
                                $actressObject[$x].LastName = $matchedActress.LastName
                                $actressObject[$x].ThumbUrl = $matchedActress.ThumbUrl
                                $actressString = $actressObject[$x] | ConvertTo-Json -Compress
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [$file] [Actress - $originalActressString] matched to [$actressString]"
                            }
                        } else {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [$file] [Actress - $($actressObject[$x] | ConvertTo-Json -Compress)] not matched"
                        }
                    }

                    $nfoContent = $nfoContent -join "`r`n"
                    for ($x = 0; $x -lt $actressObject.Count; $x++) {
                        $actressName = ''
                        $actressString = ''
                        $actressThumb = ''
                        $actressThumbString = ''
                        if ($actressObject.Count -eq 1) {
                            $actressThumb = $actressObject.ThumbUrl
                            $actressThumbString = "<thumb>$actressThumb</thumb>"
                            if ($actressLanguageJa) {
                                $actressName = "$($actressObject.JapaneseName)".Trim()
                                if ($actressName -eq '') {
                                    $actressName = "$($actressObject.LastName) $($actressObject.FirstName)".Trim()
                                }
                                $actressString = "<name>$actressName</name>"
                            } else {
                                $actressName = "$($actressObject.LastName) $($actressObject.FirstName)".Trim()
                                if ($actressName -eq '') {
                                    $actressName = "$($actressObject.JapaneseName)".Trim()
                                }
                                $actressString = "<name>$actressName</name>"
                            }

                            $group = "$($nfoNameString)\r\n\s.*$($nfoThumbString)"
                            $replacement = "$actressString`r`n        $actressThumbString"
                            $nfoContent = $nfoContent -replace $group, $replacement

                        } else {
                            $actressThumb = $actressObject[$x].ThumbUrl
                            $actressThumbString = "<thumb>$actressThumb</thumb>"
                            if ($actressLanguageJa) {
                                $actressName = "$($actressObject[$x].JapaneseName)".Trim()
                                if ($actressName -eq '') {
                                    $actressName = "$($actressObject[$x].LastName) $($actressObject[$x].FirstName)".Trim()
                                }
                                $actressString = "<name>$actressName</name>"
                            } else {
                                $actressName = "$($actressObject[$x].LastName) $($actressObject[$x].FirstName)".Trim()
                                if ($actressName -eq '') {
                                    $actressName = "$($actressObject[$x].JapaneseName)".Trim()
                                }
                                $actressString = "<name>$actressName</name>"
                            }

                            $group = "$($nfoNameString[$x])\r\n\s.*$($nfoThumbString[$x])"
                            $replacement = "$actressString`r`n        $actressThumbString"
                            $nfoContent = $nfoContent -replace $group, $replacement
                        }
                    }
                    $nfoContent | Out-File -LiteralPath $file
                }

                if ($GenreCsv) {
                    $nfoContent = (Get-Content -LiteralPath $file) -join "`r`n"
                    foreach ($genre in $genresCsv) {
                        if ($nfoContent -match "<genre>$($genre.Original)</genre>") {
                            $nfoContent = $nfoContent -replace "<genre>$($genre.Original)</genre>", "<genre>$($genre.Replacement)</genre>"
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [$file] [Genre - $($genre.Original)] replaced by [$($genre.Replacement)]"
                        }
                    }
                    $nfoContent | Out-File -LiteralPath $file
                }

                if ($GenreIgnore) {
                    $nfoContent = (Get-Content -LiteralPath $file) -join "`r`n"
                    foreach ($genre in $GenreIgnore) {
                        if ($nfoContent -match "<genre>$genre</genre>") {
                            $nfoContent = $nfoContent -replace '\s*<genre>Featured Actress</genre>\s*', "`r`n    "
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($MyInvocation.MyCommand.Name)] [$file] [Genre - $genre] removed"
                        }
                    }
                    $nfoContent | Out-File -LiteralPath $file
                }
            }

            $newNfoContent = (Get-Content -LiteralPath $file) -join "`r`n"
            if ($originalNfoContent -ne $newNfoContent) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info -Message "[$($MyInvocation.MyCommand.Name)] Updated nfo [$file]"
            }
        }
    }
}
