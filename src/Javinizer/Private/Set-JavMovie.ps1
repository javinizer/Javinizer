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
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        $r18ThumbCsv = Import-Csv -LiteralPath (Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs.csv')
        $fixedPath = ($Path).replace('`[', '[').replace('`]', ']')
        $Path = (Get-Item -LiteralPath $fixedPath).FullName
        $fileExtension = (Get-Item -LiteralPath $fixedPath).Extension
        $fixedDestinationPath = ($DestinationPath).replace('`[', '[').replace('`]', ']')
        $DestinationPath = (Get-Item -LiteralPath $fixedDestinationPath).FullName
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent: Other")
        $cropPath = Join-Path -Path $ScriptRoot -ChildPath 'crop.py'

        if ($Settings.General.'move-to-folder' -eq 'True') {
            $folderPath = Join-Path -Path $fixedDestinationPath -ChildPath $DataObject.FolderName
        } else {
            $folderPath = (Get-Item -LiteralPath $DataObject.OriginalDirectory).FullName
        }

        $fixedFolderPath = ($folderPath.replace('[', '`[')).replace(']', '`]')


        if ($Settings.Metadata.'create-nfo-per-file' -eq 'True') {
            if ($Settings.General.'rename-file' -eq 'True') {
                $nfoPath = Join-Path -Path $folderPath -ChildPath ($DataObject.FileName + '.nfo')
            } else {
                $nfoPath = Join-Path -Path $folderPath -ChildPath ($DataObject.OriginalBaseName + '.nfo')
            }
        } else {
            $nfoPath = Join-Path -Path $folderPath -ChildPath ($DataObject.NfoName + '.nfo')
        }

        $coverPath = Join-Path -Path $folderPath -ChildPath ($DataObject.ThumbnailName + '.jpg')
        $posterPath = Join-Path -Path $folderPath -ChildPath ($DataObject.PosterName + '.jpg')
        $trailerPath = Join-Path -Path $folderPath -ChildPath ($DataObject.TrailerName + '.mp4')
        $screenshotPath = Join-Path -Path $folderPath -ChildPath $DataObject.ScreenshotFolderName
        $actorPath = Join-Path -Path $folderPath -ChildPath $DataObject.ActorImgFolderName
        $fixedNfoPath = ($nfoPath).replace('`[', '[').replace('`]', ']')
        $fixedCoverPath = ($coverPath).replace('`[', '[').replace('`]', ']')
        $fixedPosterPath = ($posterPath).replace('`[', '[').replace('`]', ']')
        $fixedTrailerPath = ($trailerPath).replace('`[', '[').replace('`]', ']')
        $fixedScreenshotPath = ($screenshotPath).replace('`[', '[').replace('`]', ']')
        $fixedActorPath = ($actorPath).replace('`[', '[').replace('`]', ']')
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Crop path: [$cropPath]"
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Folder path: [$folderPath]"
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Nfo path: [$nfoPath]"
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Cover path: [$coverPath]"
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Poster path: [$posterPath]"
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Screenshot path: [$screenshotPath]"
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Trailer path: [$trailerPath]"
    }

    process {
        $screenshotImgName = $DataObject.ScreenshotImgName
        $newFileName = $DataObject.FileName + $fileExtension
        $DataObject = Test-RequiredMetadata -DataObject $DataObject -Settings $settings

        if ($null -ne $DataObject) {
            if ($Settings.General.'move-to-folder' -eq 'True') {
                $fixedDestinationPath = $DestinationPath.replace('[', '`[').replace(']', '`]')

                # Check that folder path is not longer than 256 characters
                $pathLength = (Join-Path -Path $fixedDestinationPath -ChildPath $DataObject.FolderName).Length
                if ($pathLength -gt $Settings.General.'max-path-length') {
                    Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Skipped: [$($DataObject.OriginalFileName)] Folder path length limitations: [$pathLength characters]"
                    Write-Log -Log $javinizerLogPath -Level ERROR -OriginalFile $DataObject.OriginalFileName -DestinationFile (Join-Path -Path $fixedDestinationPath -ChildPath $DataObject.FolderName) -Text "Skipped: [$($DataObject.OriginalFileName)] Folder path length limitations [$pathLength characters] of 215"
                    continue
                }

                if (!(Test-Path -LiteralPath (Join-Path -Path $fixedDestinationPath -ChildPath $DataObject.FolderName))) {
                    New-Item -ItemType Directory -Name $DataObject.FolderName -Path $fixedDestinationPath -Force:$Force -ErrorAction Ignore | Out-Null
                }

                if ($Settings.Metadata.'create-nfo' -eq 'True') {
                    $nfoContents = Get-MetadataNfo -DataObject $DataObject -Settings $Settings -R18ThumbCsv $r18ThumbCsv -ErrorAction 'SilentlyContinue'
                    $nfoContents | Out-File -LiteralPath $fixednfoPath -Force:$Force -ErrorAction 'SilentlyContinue'
                    [xml]$nfoXML = Get-Content -LiteralPath $fixedNfoPath
                }

                if ($Settings.General.'rename-file' -eq 'True') {
                    Rename-Item -LiteralPath $Path -NewName $newFileName -PassThru -Force:$Force -ErrorAction Stop | Move-Item -Destination $folderPath -Force:$Force -ErrorAction 'Stop'
                } else {
                    Move-Item -LiteralPath $Path -Destination $folderPath -Force:$Force -ErrorAction 'Stop'
                }
            } else {
                if ($Settings.Metadata.'create-nfo' -eq 'True') {
                    $nfoContents = Get-MetadataNfo -DataObject $DataObject -Settings $Settings -R18ThumbCsv $r18ThumbCsv -ErrorAction 'SilentlyContinue'
                    $nfoContents | Out-File -LiteralPath $fixedNfoPath -Force:$Force -ErrorAction 'SilentlyContinue'
                    [xml]$nfoXML = Get-Content -LiteralPath $fixedNfoPath
                }

                if ($Settings.General.'rename-file' -eq 'True') {
                    Rename-Item -LiteralPath $Path -NewName $newFileName -PassThru -Force:$Force -ErrorAction 'Stop' | Out-Null
                }
            }

            if ($Settings.Metadata.'download-thumb-img' -eq 'True') {
                try {
                    if ($null -ne $DataObject.CoverUrl) {
                        $webClient = New-Object System.Net.WebClient
                        $webClient.Headers.Add("User-Agent: Other")
                        if ($Force.IsPresent) {
                            $webClient.DownloadFile(($DataObject.CoverUrl).ToString(), $fixedCoverPath)
                        } elseif ((!(Test-Path -LiteralPath $fixedCoverPath))) {
                            $webClient.DownloadFile(($DataObject.CoverUrl).ToString(), $fixedCoverPath)
                        }
                    }
                } catch {
                    Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error downloading cover images"
                    Write-Log -Log $javinizerLogPath -Level ERROR -OriginalFile $DataObject.OriginalFileName -Text "Skipped: [$($DataObject.OriginalFileName)] Error downloading cover images [$($PSItem.ToString())]"
                    throw $_
                }

                try {
                    if ($Settings.Metadata.'download-poster-img' -eq 'True') {
                        # Double backslash to conform with Python path standards
                        if ($null -ne $DataObject.CoverUrl) {
                            $pythonCoverPath = $fixedCoverPath -replace '\\', '/'
                            $pythonPosterPath = $posterPath -replace '\\', '/'
                            if ($Force.IsPresent) {
                                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                    python $cropPath $pythonCoverPath $pythonPosterPath
                                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                    python3 $cropPath $pythonCoverPath $pythonPosterPath
                                }
                            } elseif ((!(Test-Path -LiteralPath $posterPath))) {
                                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                    python $cropPath $pythonCoverPath $pythonPosterPath
                                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                    python3 $cropPath $pythonCoverPath $pythonPosterPath
                                }
                            }
                        }
                    }
                } catch {
                    Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error cropping cover to poster image"
                    Write-Log -Log $javinizerLogPath -Level ERROR -OriginalFile $DataObject.OriginalFileName -Text "Skipped: [$($DataObject.OriginalFileName)] Error cropping cover to poster image [$($PSItem.ToString())]"
                    throw $_
                }
            }

            try {
                if ($Settings.Metadata.'download-screenshot-img' -eq 'True') {
                    if ($null -ne $DataObject.ScreenshotUrl) {
                        New-Item -ItemType Directory -Name $DataObject.ScreenshotFolderName -Path $fixedFolderPath -Force:$Force -ErrorAction SilentlyContinue | Out-Null
                        $index = 1
                        foreach ($screenshot in $DataObject.ScreenshotUrl) {
                            $webClient = New-Object System.Net.WebClient
                            $webClient.Headers.Add("User-Agent: Other")
                            if ($Force.IsPresent) {
                                $webClient.DownloadFile($screenshot, (Join-Path -Path $fixedScreenshotPath -ChildPath ($screenshotImgName + $index + '.jpg')))
                            } elseif (!(Test-Path -LiteralPath (Join-Path -Path $fixedScreenshotPath -ChildPath ($screenshotImgName + $index + '.jpg')))) {
                                $webClient.DownloadFile($screenshot, (Join-Path -Path $fixedScreenshotPath -ChildPath ($screenshotImgName + $index + '.jpg')))
                            }
                            $index++
                        }
                    }
                }
            } catch {
                Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error downloading screenshots"
                Write-Log -Log $javinizerLogPath -Level ERROR -OriginalFile $DataObject.OriginalFileName -Text "Skipped: [$($DataObject.OriginalFileName)] Error downloading screenshots $($PSItem.ToString())"
                throw $_
            }

            try {
                if ($Settings.Metadata.'download-actress-img' -eq 'True') {
                    if ($null -ne $DataObject.ActressThumbUrl) {
                        $webClient = New-Object System.Net.WebClient
                        $webClient.Headers.Add("User-Agent: Other")
                        New-Item -ItemType Directory -Name $DataObject.ActorImgFolderName -Path $fixedFolderPath -Force:$Force -ErrorAction SilentlyContinue | Out-Null
                        $nfoActress = $nfoXml.movie.actor
                        foreach ($actress in $nfoActress) {
                            if ($actress.thumb -ne '') {
                                $firstName, $lastName = $actress.name -split ' '
                                if ($null -eq $lastName -or $lastName -eq '') {
                                    $actressFileName = $firstName + '.jpg'
                                } else {
                                    $actressFileName = $firstName + '_' + $lastName + '.jpg'
                                }
                                if ($Force.IsPresent) {
                                    $webClient.DownloadFile($actress.thumb, (Join-Path -Path $fixedActorPath -ChildPath $actressFileName))
                                } elseif (!(Test-Path -LiteralPath (Join-Path -Path $fixedActorPath -ChildPath $actressFileName))) {
                                    $webClient.DownloadFile($actress.thumb, (Join-Path -Path $fixedActorPath -ChildPath $actressFileName))
                                }
                            }
                        }
                    }
                }
            } catch {
                Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error downloading actress images"
                Write-Log -Log $javinizerLogPath -Level ERROR -OriginalFile $DataObject.OriginalFileName -Text "Skipped: [$($DataObject.OriginalFileName)] Error downloading actress images $($PSItem.ToString())"
                throw $_
            }

            try {
                if ($Settings.Metadata.'download-trailer-vid' -eq 'True') {
                    if ($null -ne $DataObject.TrailerUrl) {
                        $webClient = New-Object System.Net.WebClient
                        $webClient.Headers.Add("User-Agent: Other")
                        if ($Force.IsPresent) {
                            $webClient.DownloadFile($DataObject.TrailerUrl, $fixedTrailerPath)
                        } elseif (!(Test-Path -LiteralPath $trailerPath)) {
                            $webClient.DownloadFile($DataObject.TrailerUrl, $fixedTrailerPath)
                        }
                    }
                }
            } catch {
                Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error downloading trailer video"
                Write-Log -Log $javinizerLogPath -Level ERROR -OriginalFile $DataObject.OriginalFileName -Text "Skipped: [$($DataObject.OriginalFileName)] Error downloading trailer video $($PSItem.ToString())"
                throw $_
            }

            try {
                if ($Settings.JavLibrary.'set-owned' -eq 'True') {
                    if (!($javlibraryOwnedMovies -match $DataObject.Id)) {
                        Set-JavlibraryOwned -AjaxId $DataObject.AjaxId -JavlibraryUrl $DataObject.JavlibraryUrl -Settings $Settings
                    }
                }
            } catch {
                Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Error downloading trailer video"
                Write-Log -Log $javinizerLogPath -Level ERROR -OriginalFile $DataObject.OriginalFileName -Text "Skipped: [$($DataObject.OriginalFileName)] Error setting owned status on JavLibrary $($PSItem.ToString())"
                throw $_
            }
        }
    }

    end {
        # Write-Verbose "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Success: [$($DataObject.OriginalFileName)]"
        if ($Settings.General.'rename-file' -eq 'True') {
            Write-Log -Log $javinizerLogPath -Level INFO -OriginalFile $DataObject.OriginalFullName -DestinationFile (Join-Path -Path $folderPath -ChildPath $newFileName) -Text "Success: [$($DataObject.OriginalFileName)]"
        } else {
            Write-Log -Log $javinizerLogPath -Level INFO -OriginalFile $DataObject.OriginalFullName -DestinationFile (Join-Path -Path $folderPath -ChildPath $DataObject.OriginalFileName) -Text "Success: [$($DataObject.OriginalFileName)]"
        }
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
