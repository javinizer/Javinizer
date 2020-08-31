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
        [Alias('sort.maxpathlength')]
        [Boolean]$MaxPathLength,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.maxtitlelength')]
        [Boolean]$MaxTitleLength,
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
        [String]$PosterFormat,
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
        [Boolean]$NameOrder
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
        <# Pre-impact code #>
        if ($Settings) {
            $MoveToFolder = $Settings.'sort.movetofolder'
            $RenameFile = $Settings.'sort.renamefile'
            $MaxPathLength = $Settings.'sort.maxpathlength'
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
            $NameOrder = $Settings.'sort.metadata.nfo.firstnameorder'
        }

        $fileName = Convert-JVString -Data $Data -Format $FileFormat -PartNumber $PartNumber
        $folderName = Convert-JVString -Data $Data -Format $FolderFormat
        $nfoName = Convert-JVString -Data $Data -Format $NfoFormat
        $thumbName = Convert-JVString -Data $Data -Format $ThumbnailFormat
        $posterName = Convert-JVString -Data $Data -Format $PosterFormat
        $trailerName = Convert-JVString -Data $Data -Format $TrailerFormat
        $screenshotImgName = Convert-JVString -Data $Data -Format $ScreenshotImgFormat
        $screenshotFolderName = Convert-JVString -Data $Data -Format $ScreenshotFolderFormat
        $actorFolderName = Convert-JVString -Data $Data -Format $ActorFolderFormat

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

        Write-JLog -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] The destination folderPath is [$folderPath]"

        <#         $pathLength = (Join-Path -Path $folderPath -ChildPath $fileName).Length
        if ($pathLength -gt $MaxPathLength) {
            Write-Warning "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Skipped: [$($DataObject.OriginalFileName)] Folder path length limitations: [$pathLength characters]"
            continue
        } #>

        if ($Force -or $PSCmdlet.ShouldProcess($Path)) {
            # We do not want to recreate the destination folder if it already exists
            try {
                if (!(Test-Path -LiteralPath $folderPath)) {
                    New-Item -Path $folderPath -ItemType Directory -Force:$Force | Out-Null
                    Write-JLog -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] New directory created at path [$folderPath]"
                }
            } catch {
                Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating destination folder path [$folderPath]: $PSItem"
            }

            if ($CreateNfo) {
                Write-JLog -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Creating nfo file"
                try {
                    $nfoPath = Join-Path -Path $folderPath -ChildPath "$nfoName.nfo"
                    $nfoContents = $Data | Get-JVNfo -NameOrder $NameOrder -AddTag $AddTag
                    $nfoContents | Out-File -LiteralPath $nfoPath -Force:$Force
                    Write-JLog -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Nfo file created at path [$nfoPath]"
                } catch {
                    Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating nfo file [$nfoPath]: $PSItem"
                }
            }

            if ($DownloadThumbImg) {
                if ($null -ne $Data.CoverUrl) {
                    Write-JLog -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Creating thumbnail image"
                    try {
                        $webClient = New-Object System.Net.WebClient
                        $thumbPath = Join-Path -Path $folderPath -ChildPath "$thumbName.jpg"
                        if ($Force) {
                            $webClient.DownloadFile(($Data.CoverUrl).ToString(), $thumbPath)
                        } elseif ((!(Test-Path -LiteralPath $thumbPath))) {
                            $webClient.DownloadFile(($Data.CoverUrl).ToString(), $thumbPath)
                        }
                        Write-JLog -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Thumbnail image [$($Data.CoverUrl)] downloaded to path [$thumbPath]"
                    } catch {
                        Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating thumbnail image file [$thumbPath]: $PSItem"
                    }

                    if ($DownloadPosterImg) {
                        Write-JLog -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Creating poster image"
                        try {
                            $cropScript = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'crop.py'
                            Write-JLog -Level Debug "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] crop.py path located at path [$cropScript]"
                            $posterPath = Join-Path $folderPath -ChildPath "$posterName.jpg"
                            $pythonThumbPath = $thumbPath -replace '\\', '/'
                            $pythonPosterPath = $posterPath -replace '\\', '/'

                            if ($Force) {
                                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                    python $cropScript $pythonThumbPath $pythonPosterPath
                                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                    python3 $cropScript $pythonThumbPath $pythonPosterPath
                                }
                            } elseif (!(Test-Path -LiteralPath $posterPath)) {
                                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                    python $cropScript $pythonThumbPath $pythonPosterPath
                                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                    python3 $cropScript $pythonThumbPath $pythonPosterPath
                                }
                            }
                            Write-JLog -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Poster image [$thumbPath] cropped to path [$posterPath]"
                        } catch {
                            Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating poster image file [$posterPath]: $PSItem"
                        }
                    }
                }
            }

            if ($DownloadActressImg) {
                if ($null -ne $Data.Actress) {
                    Write-JLog -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Creating actress images"
                    try {
                        $webClient = New-Object System.Net.WebClient
                        $actorFolderPath = Join-Path -Path $folderPath -ChildPath $actorFolderName
                        if (!(Test-Path -LiteralPath $actorFolderPath)) {
                            New-Item -Path $actorFolderPath -ItemType Directory -Force:$Force | Out-Null
                        }

                        $nfoXML = [xml]$nfoContents
                        foreach ($actress in $nfoXML.movie.actor) {
                            if ($actress.thumb -ne '') {
                                $newName = ($actress.name -split ' ') -join '_'
                                $actressThumbPath = Join-Path -Path $actorFolderPath -ChildPath "$newName.jpg"

                                if ($Force) {
                                    $webClient.DownloadFile($actress.thumb, $actressThumbPath)
                                } elseif (!(Test-Path -LiteralPath $actressThumbPath)) {
                                    $webClient.DownloadFile($actress.thumb, $actressThumbPath)
                                }
                                Write-JLog -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Actress image file [$($actress.thumb)] downloaded to path [$actressThumbPath]"
                            }
                        }
                    } catch {
                        Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating actress image files: $PSItem"
                    }
                }
            }

            if ($DownloadScreenshotImg) {
                if ($null -ne $Data.ScreenshotUrl) {
                    Write-JLog -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Creating screenshot images"
                    try {
                        $index = 1
                        $webClient = New-Object System.Net.WebClient
                        $screenshotFolderPath = Join-Path $folderPath -ChildPath $screenshotFolderName
                        if (!(Test-Path -LiteralPath $screenshotFOlderPath)) {
                            New-Item -Path $screenshotFolderPath -ItemType Directory -Force:$Force -ErrorAction SilentlyContinue | Out-Null
                        }

                        foreach ($screenshot in $Data.ScreenshotUrl) {
                            $screenshotPath = Join-Path -Path $screenshotFolderPath -ChildPath "$screenshotImgName$index.jpg"
                            if ($Force.IsPresent) {
                                $webClient.DownloadFile($screenshot, $screenshotPath)
                            } elseif (!(Test-Path -LiteralPath $screenshotPath)) {
                                $webClient.DownloadFile($screenshot, $screenshotPath)
                            }
                            $index++
                            Write-JLog -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Screenshot image file [$screenshot] downloaded to path [$screenshotPath]"
                        }
                    } catch {
                        Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating screenshot image files: $PSItem"
                    }
                }
            }

            if ($DownloadTrailerVid) {
                if ($null -ne $Data.TrailerUrl) {
                    Write-JLog -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Creating trailer video"
                    try {
                        $trailerPath = Join-Path -Path $folderPath -ChildPath "$trailerName.mp4"
                        if ($Force.IsPresent) {
                            $webClient.DownloadFile($Data.TrailerUrl, $trailerPath)
                        } elseif (!(Test-Path -LiteralPath $trailerPath)) {
                            $webClient.DownloadFile($Data.TrailerUrl, $trailerPath)
                        }
                        Write-JLog -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Trailer video [$($Data.TrailerUrl)] downloaded to path [$trailerPath]"
                    } catch {
                        Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating trailer video file [$($Data.TrailerUrl)] to [$trailerName]: $PSItem"
                    }
                }
            }

            if ($RenameFile) {
                try {
                    $filePath = Join-Path -Path $folderPath -ChildPath "$fileName$((Get-Item -LiteralPath $Path).Extension)"
                    if ((Get-Item -LiteralPath $DestinationPath).Directory -ne (Get-Item -LiteralPath $Path).Directory) {
                        Move-Item -LiteralPath $Path -Destination $filePath -Force:$Force
                        Write-JLog -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path -> $filePath]"
                    }
                } catch {
                    Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when renaming and moving file [$Path] to [$filePath]: $PSItem"
                }
            } else {
                try {
                    $filePath = Join-Path -Path $folderPath -ChildPath (Get-Item -LiteralPath $Path).Name
                    if ((Get-Item -LiteralPath $DestinationPath).Directory -ne (Get-Item -LiteralPath $Path).Directory) {
                        Move-Item -LiteralPath $Path -Destination $filePath -Force:$Force
                        Write-JLog -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path -> $filePath]"

                    }
                } catch {
                    Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when renaming and moving file [$Path] to [$filePath]: $PSItem"
                }
            }
        }
    }
}
