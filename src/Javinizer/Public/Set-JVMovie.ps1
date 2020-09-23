#Requires -PSEdition Core

function Set-JVMovie {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.IO.FileInfo]$Path,

        [Parameter(Mandatory = $true, Position = 1)]
        [System.IO.DirectoryInfo]$DestinationPath,

        [Parameter(Mandatory = $true)]
        [PSObject]$Settings,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [PSObject]$Data,

        [Parameter()]
        [Switch]$Update,

        [Parameter()]
        [Int]$PartNumber,

        [Parameter()]
        [Switch]$Force,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.movetofolder')]
        [Boolean]$MoveToFolder,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.renamefile')]
        [Boolean]$RenameFile,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.maxtitlelength')]
        [Int]$MaxTitleLength,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.create.nfo')]
        [Boolean]$CreateNfo,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.create.nfoperfile')]
        [Boolean]$CreateNfoPerFile,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.download.actressimg')]
        [Boolean]$DownloadActressImg,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.download.thumbimg')]
        [Boolean]$DownloadThumbImg,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.download.posterimg')]
        [Boolean]$DownloadPosterImg,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.download.screenshotimg')]
        [Boolean]$DownloadScreenshotImg,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.download.trailervid')]
        [Boolean]$DownloadTrailerVid,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.file')]
        [String]$FileFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.folder')]
        [String]$FolderFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.posterimg')]
        [Array]$PosterFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.thumbimg')]
        [String]$ThumbnailFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.trailervid')]
        [String]$TrailerFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.nfo')]
        [String]$NfoFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.screenshotimg')]
        [String]$ScreenshotImgFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.screenshotfolder')]
        [String]$ScreenshotFolderFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.actressimgfolder')]
        [String]$ActressFolderFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.nfo.displayname')]
        [String]$DisplayName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.nfo.seriesastag')]
        [Boolean]$AddTag,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.nfo.firstnameorder')]
        [Boolean]$FirstNameOrder,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.format.delimiter')]
        [String]$DelimiterFormat,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Setting')]
        [Alias('sort.metadata.nfo.actresslanguageja')]
        [Boolean]$ActressLanguageJa
    )

    begin {
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
    }

    process {
        if ($Settings) {
            $MoveToFolder = $Settings.'sort.movetofolder'
            $RenameFile = $Settings.'sort.renamefile'
            $MaxTitleLength = $Settings.'sort.maxtitlelength'
            $CreateNfo = $Settings.'sort.create.nfo'
            $CreateNfoPerFile = $Settings.'sort.create.nfoperfile'
            $DownloadActressImg = $Settings.'sort.download.actressimg'
            $DownloadThumbImg = $Settings.'sort.download.thumbimg'
            $DownloadPosterImg = $Settings.'sort.download.posterimg'
            $DownloadScreenshotImg = $Settings.'sort.download.screenshotimg'
            $DownloadTrailerVid = $Settings.'sort.download.trailervid'
            $FileFormat = $Settings.'sort.format.file'
            $FolderFormat = $Settings.'sort.format.folder'
            $PosterFormat = $Settings.'sort.format.posterimg'
            $ThumbnailFormat = $Settings.'sort.format.thumbimg'
            $TrailerFormat = $Settings.'sort.format.trailervid'
            $NfoFormat = $Settings.'sort.format.nfo'
            $ScreenshotImgFormat = $Settings.'sort.format.screenshotimg'
            $ScreenshotFolderFormat = $Settings.'sort.format.screenshotfolder'
            $ActorFolderFormat = $Settings.'sort.format.actressimgfolder'
            $DisplayName = $Settings.'sort.metadata.nfo.displayname'
            $AddTag = $Settings.'sort.metadata.nfo.seriesastag'
            $FirstNameOrder = $Settings.'sort.metadata.nfo.firstnameorder'
            $DelimiterFormat = $Settings.'sort.format.delimiter'
            $ActressLanguageJa = $Settings.'sort.metadata.nfo.actresslanguageja'
        }

        if ($RenameFile) {
            $fileName = Convert-JVString -Data $Data -Format $FileFormat -PartNumber $PartNumber -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder
        } else {
            $fileName = (Get-Item -LiteralPath $Path).BaseName
        }
        $folderName = Convert-JVString -Data $Data -Format $FolderFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder
        $thumbName = Convert-JVString -Data $Data -Format $ThumbnailFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder
        $trailerName = Convert-JVString -Data $Data -Format $TrailerFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder
        $screenshotImgName = Convert-JVString -Data $Data -Format $ScreenshotImgFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder
        $screenshotFolderName = Convert-JVString -Data $Data -Format $ScreenshotFolderFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder
        $actorFolderName = Convert-JVString -Data $Data -Format $ActorFolderFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder

        $posterName = @()
        foreach ($format in $PosterFormat) {
            $posterName += Convert-JVString -Data $Data -Format $format -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder
        }

        if ($CreateNfo) {
            $nfoName = Convert-JVString -Data $Data -Format $NfoFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder
            if ($CreateNfoPerFile) {
                $nfoName = $fileName
            }
        }

        if ($MoveToFolder) {
            if ($DestinationPath) {
                $folderPath = Join-Path -Path $DestinationPath -ChildPath $folderName
            } else {
                $folderPath = Join-Path -Path $Path -ChildPath $folderName
            }
        } else {
            if ($DestinationPath) {
                $folderPath = $DestinationPath
            } else {
                $folderPath = (Get-Item -LiteralPath $Path).Directory
            }
        }

        if ($Update) {
            $folderPath = (Get-Item -LiteralPath $Path).Directory
        }

        <#         $pathLength = (Join-Path -Path $folderPath -ChildPath $fileName).Length
        if ($pathLength -gt $MaxPathLength) {
            Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Skipped: [$($DataObject.OriginalFileName)] Folder path length limitations: [$pathLength characters]"
            continue
        } #>

        if ($Force -or $PSCmdlet.ShouldProcess($Path)) {
            # We do not want to recreate the destination folder if it already exists
            try {
                if (!(Test-Path -LiteralPath $folderPath) -and (!($Update))) {
                    New-Item -Path $folderPath -ItemType Directory -Force:$Force | Out-Null
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Directory] created at path [$folderPath]"
                }
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating destination folder path [$folderPath]: $PSItem"
            }

            if ($CreateNfo) {
                try {
                    $nfoPath = Join-Path -Path $folderPath -ChildPath "$nfoName.nfo"
                    $nfoContents = $Data | Get-JVNfo -NameOrder $FirstNameOrder -AddTag $AddTag -ActressLanguageJa:$ActressLanguageJa
                    $nfoContents | Out-File -LiteralPath $nfoPath -Force:$Force
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Nfo] created at path [$nfoPath]"
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating nfo file [$nfoPath]: $PSItem"
                }
            }

            if ($DownloadThumbImg) {
                if ($null -ne $Data.CoverUrl) {
                    try {
                        $webClient = New-Object System.Net.WebClient
                        $webclient.Headers.Add("User-Agent: Other")
                        $thumbPath = Join-Path -Path $folderPath -ChildPath "$thumbName.jpg"
                        if ($PartNumber -eq 0 -or $PartNumber -eq 1) {
                            if ($Force) {
                                if (Test-Path -LiteralPath $thumbPath) {
                                    Remove-Item -LiteralPath $thumbPath -Force
                                }
                                $webClient.DownloadFile(($Data.CoverUrl).ToString(), $thumbPath)
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Thumbnail - $($Data.CoverUrl)] downloaded to path [$thumbPath]"
                            } elseif (!(Test-Path -LiteralPath $thumbPath)) {
                                $webClient.DownloadFile(($Data.CoverUrl).ToString(), $thumbPath)
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Thumbnail - $($Data.CoverUrl)] downloaded to path [$thumbPath]"
                            }
                        } else {
                            if (!(Test-Path -LiteralPath $thumbPath)) {
                                Start-Sleep -Seconds 2
                                if (!(Test-Path -LiteralPath $thumbPath)) {
                                    $webClient.DownloadFile(($Data.CoverUrl).ToString(), $thumbPath)
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Thumbnail - $($Data.CoverUrl)] downloaded to path [$thumbPath]"
                                }
                            }
                        }
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating thumbnail image file [$thumbPath]: $PSItem"
                    }

                    if ($DownloadPosterImg) {
                        try {
                            $cropScriptPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'crop.py'
                            if (Test-Path -LiteralPath $cropScriptPath) {
                                foreach ($poster in $posterName) {
                                    $posterPath = Join-Path $folderPath -ChildPath "$poster.jpg"
                                    $pythonThumbPath = $thumbPath -replace '\\', '/'
                                    $pythonPosterPath = $posterPath -replace '\\', '/'
                                    if ($PartNumber -eq 0 -or $PartNumber -eq 1) {
                                        if ($Force) {
                                            if (Test-Path -LiteralPath $posterPath) {
                                                Remove-Item -LiteralPath $posterPath -Force
                                            }
                                            if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                                python $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $thumbPath] cropped to path [$posterPath]"
                                            } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                                python3 $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $thumbPath] cropped to path [$posterPath]"
                                            }
                                        } elseif (!(Test-Path -LiteralPath $posterPath)) {
                                            if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                                python $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $thumbPath] cropped to path [$posterPath]"
                                            } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                                python3 $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $thumbPath] cropped to path [$posterPath]"

                                            }
                                        }
                                    } else {
                                        if (!(Test-Path -LiteralPath $posterPath)) {
                                            Start-Sleep -Seconds 2
                                            if (!(Test-Path -LiteralPath $posterPath)) {
                                                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                                    python $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $thumbPath] cropped to path [$posterPath]"
                                                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                                    python3 $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $thumbPath] cropped to path [$posterPath]"
                                                }
                                            }
                                        }
                                    }
                                }

                            } else {
                                Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Crop.py file is missing or cannot be found at path [$cropScriptPath]"
                            }
                        } catch {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating poster image file [$posterPath]: $PSItem"
                        }
                    }
                }
            }

            if ($DownloadActressImg) {
                if ($null -ne $Data.Actress) {
                    try {
                        $actorFolderPath = Join-Path -Path $folderPath -ChildPath $actorFolderName
                        if (!(Test-Path -LiteralPath $actorFolderPath)) {
                            New-Item -Path $actorFolderPath -ItemType Directory -Force:$Force | Out-Null
                        }

                        $nfoXML = [xml]$nfoContents
                        foreach ($actress in $nfoXML.movie.actor) {
                            if ($actress.thumb -ne '') {
                                $webClient = New-Object System.Net.WebClient
                                $webclient.Headers.Add("User-Agent: Other")
                                $newName = ($actress.name -split ' ') -join '_'
                                $actressThumbPath = Join-Path -Path $actorFolderPath -ChildPath "$newName.jpg"

                                if ($PartNumber -eq 0 -or $PartNumber -eq 1) {
                                    if ($Force) {
                                        if (Test-Path -LiteralPath $actressThumbPath) {
                                            Remove-Item -LiteralPath $actressThumbPath -Force
                                        }
                                        $webClient.DownloadFile($actress.thumb, $actressThumbPath)
                                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [ActressImg - $($actress.thumb)] downloaded to path [$actressThumbPath]"
                                    } elseif (!(Test-Path -LiteralPath $actressThumbPath)) {
                                        $webClient.DownloadFile($actress.thumb, $actressThumbPath)
                                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [ActressImg - $($actress.thumb)] downloaded to path [$actressThumbPath]"
                                    }
                                } else {
                                    if (!(Test-Path -LiteralPath $actressThumbPath)) {
                                        Start-Sleep -Seconds 2
                                        if (!(Test-Path -LiteralPath $actressThumbPath)) {
                                            $webClient.DownloadFile($actress.thumb, $actressThumbPath)
                                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [ActressImg - $($actress.thumb)] downloaded to path [$actressThumbPath]"
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating actress image files: $PSItem"
                    }
                }
            }

            if ($DownloadScreenshotImg) {
                if ($null -ne $Data.ScreenshotUrl) {
                    try {
                        $index = 1
                        $screenshotFolderPath = Join-Path $folderPath -ChildPath $screenshotFolderName
                        if (!(Test-Path -LiteralPath $screenshotFolderPath)) {
                            New-Item -Path $screenshotFolderPath -ItemType Directory -Force:$Force -ErrorAction SilentlyContinue | Out-Null
                        }

                        foreach ($screenshot in $Data.ScreenshotUrl) {
                            $webClient = New-Object System.Net.WebClient
                            $webclient.Headers.Add("User-Agent: Other")
                            $screenshotPath = Join-Path -Path $screenshotFolderPath -ChildPath "$screenshotImgName$index.jpg"
                            if ($PartNumber -eq 0 -or $PartNumber -eq 1) {
                                if ($Force.IsPresent) {
                                    if (Test-Path -LiteralPath $screenshotPath) {
                                        Remove-Item -LiteralPath $screenshotPath -Force
                                    }
                                    $webClient.DownloadFile($screenshot, $screenshotPath)
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [ScreenshotImg - $screenshot] downloaded to path [$screenshotPath]"
                                } elseif (!(Test-Path -LiteralPath $screenshotPath)) {
                                    $webClient.DownloadFile($screenshot, $screenshotPath)
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [ScreenshotImg - $screenshot] downloaded to path [$screenshotPath]"
                                }
                                $index++
                            } else {
                                if (!(Test-Path -LiteralPath $screenshotPath)) {
                                    Start-Sleep -Seconds 2
                                    if (!(Test-Path -LiteralPath $screenshotPath)) {
                                        $webClient.DownloadFile($screenshot, $screenshotPath)
                                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [ScreenshotImg - $screenshot] downloaded to path [$screenshotPath]"
                                    }
                                }
                            }
                        }
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating screenshot image files: $PSItem"
                    }
                }
            }

            if ($DownloadTrailerVid) {
                if ($null -ne $Data.TrailerUrl -and $Data.TrailerUrl -ne '') {
                    try {
                        $webClient = New-Object System.Net.WebClient
                        $webclient.Headers.Add("User-Agent: Other")
                        $trailerPath = Join-Path -Path $folderPath -ChildPath "$trailerName.mp4"
                        if ($PartNumber -eq 0 -or $PartNumber -eq 1) {
                            if ($Force.IsPresent) {
                                if (Test-Path -LiteralPath $trailerPath) {
                                    Remove-Item -LiteralPath $trailerPath
                                }
                                $webClient.DownloadFile($Data.TrailerUrl, $trailerPath)
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [TrailerVid - $($Data.TrailerUrl)] downloaded to path [$trailerPath]"
                            } elseif (!(Test-Path -LiteralPath $trailerPath)) {
                                $webClient.DownloadFile($Data.TrailerUrl, $trailerPath)
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [TrailerVid - $($Data.TrailerUrl)] downloaded to path [$trailerPath]"
                            }
                        } else {
                            if (!(Test-Path -LiteralPath $trailerPath)) {
                                Start-Sleep -Seconds 2
                                if (!(Test-Path -LiteralPath $trailerPath)) {
                                    $webClient.DownloadFile($Data.TrailerUrl, $trailerPath)
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [TrailerVid - $($Data.TrailerUrl)] downloaded to path [$trailerPath]"
                                }
                            }
                        }
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating trailer video file [$($Data.TrailerUrl)] to [$trailerName]: $PSItem"
                    }
                }
            }

            if ($RenameFile -and (!($Update))) {
                try {
                    $filePath = Join-Path -Path $folderPath -ChildPath "$fileName$((Get-Item -LiteralPath $Path).Extension)"
                    if ((Get-Item -LiteralPath $DestinationPath).Directory -ne (Get-Item -LiteralPath $Path).Directory) {
                        if ((Get-Item -LiteralPath $Path).FullName -ne $filePath) {
                            if (!(Test-Path -LiteralPath $filePath)) {
                                Move-Item -LiteralPath $Path -Destination $filePath -Force:$Force
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path] => [$filePath]"
                            } else {
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path] but did not move as the destination file already exists"
                            }
                        } else {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Updated [$Path]"
                        }
                    }
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when renaming and moving file [$Path] to [$filePath]: $PSItem"
                }
            } else {
                if (!($Update)) {
                    try {
                        $filePath = Join-Path -Path $folderPath -ChildPath (Get-Item -LiteralPath $Path).Name
                        if ((Get-Item -LiteralPath $DestinationPath).Directory -ne (Get-Item -LiteralPath $Path).Directory) {
                            if ((Get-Item -LiteralPath $Path).FullName -ne $filePath) {
                                if (!(Test-Path -LiteralPath $filePath)) {
                                    Move-Item -LiteralPath $Path -Destination $filePath -Force:$Force
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path] => [$filePath]"
                                } else {
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path] but did not move as the destination file already exists"
                                }
                            } else {
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Updated [$Path]"
                            }
                        }
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [$($MyInvocation.MyCommand.Name)] Error occurred when renaming and moving file [$Path] to [$filePath]: $PSItem"
                    }
                }
            }
        }
    }
}
