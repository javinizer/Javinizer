function Set-JavMovie {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject,
        [object]$Settings,
        [string]$Path,
        [string]$DestinationPath,
        [string]$ScriptRoot,
        [switch]$Force
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $r18ThumbCsv = Import-Csv -LiteralPath (Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs.csv')
        $fixedPath = ($Path).replace('`[', '[').replace('`]', ']')
        $Path = (Get-Item -LiteralPath $fixedPath).FullName
        $fileExtension = (Get-Item -LiteralPath $fixedPath).Extension
        $fixedDestinationPath = ($DestinationPath).replace('`[', '[').replace('`]', ']')
        $DestinationPath = (Get-Item -LiteralPath $fixedDestinationPath).FullName
        $webClient = New-Object System.Net.WebClient
        $cropPath = Join-Path -Path $ScriptRoot -ChildPath 'crop.py'

        if ($Settings.General.'move-to-folder' -eq 'True') {
            $folderPath = Join-Path -Path $fixedDestinationPath -ChildPath $dataObject.FolderName
        } else {
            $folderPath = $fixedDestinationPath
        }

        $nfoPath = Join-Path -Path $folderPath -ChildPath ($dataObject.OriginalFileName + '.nfo')
        $coverPath = Join-Path -Path $folderPath -ChildPath ('fanart.jpg')
        $posterPath = Join-Path -Path $folderPath -ChildPath ('poster.jpg')
        $trailerPath = Join-Path -Path $folderPath -ChildPath ($dataObject.OriginalFileName + '-trailer.mp4')
        $screenshotPath = Join-Path -Path $folderPath -ChildPath 'extrafanart'
        $actorPath = Join-Path -Path $folderPath -ChildPath '.actors'
        $fixedNfoPath = ($nfoPath).replace('`[', '[').replace('`]', ']')
        $fixedCoverPath = ($coverPath).replace('`[', '[').replace('`]', ']')
        $fixedPosterPath = ($posterPath).replace('`[', '[').replace('`]', ']')
        $fixedTrailerPath = ($trailerPath).replace('`[', '[').replace('`]', ']')
        $fixedScreenshotPath = ($screenshotPath).replace('`[', '[').replace('`]', ']')
        $fixedActorPath = ($actorPath).replace('`[', '[').replace('`]', ']')
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Crop path: [$cropPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Folder path: [$folderPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Nfo path: [$nfoPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Cover path: [$coverPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Poster path: [$posterPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Screenshot path: [$screenshotPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Trailer path: [$trailerPath]"
    }

    process {
        $newFileName = $dataObject.FileName + $fileExtension
        $dataObject = Test-RequiredMetadata -DataObject $DataObject -Settings $settings
        if ($null -ne $dataObject) {
            if ($Settings.General.'move-to-folder' -eq 'True') {
                $fixedDestinationPath = $DestinationPath.replace('[', '`[').replace(']', '`]')
                New-Item -ItemType Directory -Name $dataObject.FolderName -Path $fixedDestinationPath -Force:$Force -ErrorAction 'SilentlyContinue' | Out-Null
                Get-MetadataNfo -DataObject $dataObject -Settings $Settings -R18ThumbCsv $r18ThumbCsv | Out-File -LiteralPath $fixednfoPath -Force:$Force -ErrorAction 'Ignore'
                Rename-Item -LiteralPath $Path -NewName $newFileName -PassThru -Force:$Force -ErrorAction Stop | Move-Item -Destination $folderPath -Force:$Force -ErrorAction 'Stop'
            } else {
                Rename-Item -LiteralPath $Path -NewName $newFileName -PassThru -Force:$Force -ErrorAction Stop | Out-Null
                Get-MetadataNfo -DataObject $dataObject -Settings $Settings -R18ThumbCsv $r18ThumbCsv | Out-File -LiteralPath $fixedNfoPath -Force:$Force -ErrorAction 'Ignore'
            }

            if ($Settings.Metadata.'download-thumb-img' -eq 'True') {
                try {
                    if ($null -ne $dataObject.CoverUrl) {
                        if ($Force.IsPresent) {
                            $webClient.DownloadFile(($dataObject.CoverUrl).ToString(), $fixedCoverPath)
                        } elseif ((-not (Test-Path -LiteralPath $fixedCoverPath))) {
                            $webClient.DownloadFile(($dataObject.CoverUrl).ToString(), $fixedCoverPath)
                        }
                    }
                } catch {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] Error downloading cover images"
                    throw $_
                }

                try {
                    if ($Settings.Metadata.'download-poster-img' -eq 'True') {
                        # Double backslash to conform with Python path standards
                        if ($null -ne $dataObject.CoverUrl) {
                            $pythonCoverPath = $fixedCoverPath -replace '\\', '\\'
                            $pythonPosterPath = $posterPath -replace '\\', '\\'
                            if ($Force.IsPresent) {
                                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                    python $cropPath $pythonCoverPath $pythonPosterPath
                                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                    python3 $cropPath $pythonCoverPath $pythonPosterPath
                                }
                            } elseif ((-not (Test-Path -LiteralPath $posterPath))) {
                                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                    python $cropPath $pythonCoverPath $pythonPosterPath
                                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                    python3 $cropPath $pythonCoverPath $pythonPosterPath
                                }
                            }
                        }
                    }
                } catch {
                    Write-Warning "[$($MyInvocation.MyCommand.Name)] Error cropping cover to poster image"
                    throw $_
                }
            }

            try {
                if ($Settings.Metadata.'download-screenshot-img' -eq 'True') {
                    if ($null -ne $dataObject.ScreenshotUrl) {
                        New-Item -ItemType Directory -Name $dataObject.FolderName -Path $DestinationPath -Force:$Force -ErrorAction SilentlyContinue | Out-Null
                        $fixFolderPath = $folderPath.replace('[', '`[').replace(']', '`]')
                        New-Item -ItemType Directory -Name 'extrafanart' -Path $fixFolderPath -Force:$Force -ErrorAction SilentlyContinue | Out-Null
                        $index = 1
                        foreach ($screenshot in $dataObject.ScreenshotUrl) {
                            if ($Force.IsPresent) {
                                $webClient.DownloadFile($screenshot, (Join-Path -Path $screenshotPath -ChildPath "fanart$index.jpg"))
                            } elseif (-not (Test-Path -LiteralPath (Join-Path -Path $screenshotPath -ChildPath "fanart$index.jpg"))) {
                                $webClient.DownloadFile($screenshot, (Join-Path -Path $screenshotPath -ChildPath "fanart$index.jpg"))
                            }
                            $index++
                        }
                    }
                }
            } catch {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Error downloading screenshots"
                throw $_
            }

            try {
                if ($Settings.Metadata.'download-actress-img' -eq 'True') {
                    if ($null -ne $dataObject.ActressThumbUrl) {
                        $fixFolderPath = $folderPath.replace('[', '`[').replace(']', '`]')
                        New-Item -ItemType Directory -Name '.actors' -Path $fixFolderPath -Force:$Force -ErrorAction SilentlyContinue | Out-Null
                        for ($i = 0; $i -lt $dataObject.ActressThumbUrl.Count; $i++) {
                            if ($dataObject.ActressThumbUrl[$i] -match 'https:\/\/pics\.r18\.com\/mono\/actjpgs\/.*\.jpg') {
                                $first, $second = $dataObject.Actress[$i] -split ' '
                                if ($null -ne $second -or $second -ne '') {
                                    $actressFileName = $first + '_' + $second + '.jpg'
                                } else {
                                    $actressFileName = $first + '.jpg'
                                }
                                if ($Force.IsPresent) {
                                    $webClient.DownloadFile($dataObject.ActressThumbUrl[$i], (Join-Path -Path $actorPath -ChildPath $actressFileName))
                                } elseif (-not (Test-Path -LiteralPath (Join-Path -Path $actorPath -ChildPath $actressFileName))) {
                                    $webClient.DownloadFile($dataObject.ActressThumbUrl[$i], (Join-Path -Path $actorPath -ChildPath $actressFileName))
                                }
                            }
                        }
                    }
                }
            } catch {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Error downloading actress images"
                throw $_
            }

            try {
                if ($Settings.Metadata.'download-trailer-vid' -eq 'True') {
                    if ($null -ne $dataObject.TrailerUrl) {
                        if ($Force.IsPresent) {
                            $webClient.DownloadFile($dataObject.TrailerUrl, $trailerPath)
                        } elseif (-not (Test-Path -LiteralPath $trailerPath)) {
                            $webClient.DownloadFile($dataObject.TrailerUrl, $trailerPath)
                        }
                    }
                }
            } catch {
                Write-Warning "[$($MyInvocation.MyCommand.Name)] Error downloading trailer video"
                throw $_
            }
        }
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
