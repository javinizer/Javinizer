function Get-JVSortData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.IO.FileInfo]$Path,

        [Parameter(Mandatory = $true, Position = 1)]
        [System.IO.DirectoryInfo]$DestinationPath,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [PSObject]$Data,

        [Parameter(Mandatory = $true)]
        [PSObject]$Settings,

        [Parameter()]
        [Switch]$Update,

        [Parameter()]
        [Int]$PartNumber,

        [Parameter()]
        [Switch]$Force
    )

    process {
        if ($Settings) {
            $MoveToFolder = $Settings.'sort.movetofolder'
            $RenameFolder = $Settings.'sort.renamefolderinplace'
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
            $OutputFolderFormat = $Settings.'sort.format.outputfolder'
            $PosterFormat = $Settings.'sort.format.posterimg'
            $ThumbnailFormat = $Settings.'sort.format.thumbimg'
            $TrailerFormat = $Settings.'sort.format.trailervid'
            $NfoFormat = $Settings.'sort.format.nfo'
            $ScreenshotImgFormat = $Settings.'sort.format.screenshotimg'
            $ScreenshotFolderFormat = $Settings.'sort.format.screenshotfolder'
            $ActorFolderFormat = $Settings.'sort.format.actressimgfolder'
            $DisplayName = $Settings.'sort.metadata.nfo.displayname'
            $FirstNameOrder = $Settings.'sort.metadata.nfo.firstnameorder'
            $DelimiterFormat = $Settings.'sort.format.delimiter'
            $ActressLanguageJa = $Settings.'sort.metadata.nfo.actresslanguageja'
            $OriginalPath = $Settings.'sort.metadata.nfo.originalpath'
            $AltNameRole = $Settings.'sort.metadata.nfo.altnamerole'
            $GroupActress = $Settings.'sort.format.groupactress'
        }

        if ($RenameFile) {
            $fileName = Convert-JVString -Data $Data -Format $FileFormat -PartNumber $PartNumber -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress
        } else {
            $fileName = (Get-Item -LiteralPath $Path).BaseName
        }
        if ($outputFolderFormat -ne '') {
            $outputFolders = @()
            foreach ($format in $outputFolderFormat) {
                $outputFolders += Convert-JVstring -Data $Data -Format $format -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress
            }
            $outputFolderName = $outputFolders -replace '(\.*$)', '' -join '/'
        }

        # If there are trailing periods in the path, we need to remove them
        # Windows does not support trailing periods in directory paths
        # We are replacing them in the $outputFolderName as well
        $folderName = (Convert-JVString -Data $Data -Format $FolderFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress) -replace '(\.*$)', ''
        $thumbName = Convert-JVString -Data $Data -Format $ThumbnailFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress
        $trailerName = Convert-JVString -Data $Data -Format $TrailerFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress
        $screenshotImgName = Convert-JVString -Data $Data -Format $ScreenshotImgFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress
        $screenshotFolderName = Convert-JVString -Data $Data -Format $ScreenshotFolderFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress
        $actorFolderName = Convert-JVString -Data $Data -Format $ActorFolderFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress

        if ($CreateNfo) {
            $nfoName = Convert-JVString -Data $Data -Format $NfoFormat -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress
            if ($CreateNfoPerFile) {
                $nfoName = $fileName
            }
        }


        if ($MoveToFolder) {
            if ($DestinationPath) {
                if ($outputFolderName -ne '' -and $null -ne $outputFolderName) {
                    $folderPath = Join-Path -Path $DestinationPath -ChildPath $outputFolderName -AdditionalChildPath $folderName
                } else {
                    $folderPath = Join-Path -Path $DestinationPath -ChildPath $folderName
                }
            } else {
                if ($outputFolderName -ne '' -and $null -ne $outputFolderName) {
                    $folderPath = Join-Path -Path $Path -ChildPath $outputFolderName -AdditionalChildPath $folderName
                } else {
                    $folderPath = Join-Path -Path $Path -ChildPath $folderName
                }
            }
        } else {
            if ($RenameFolder) {
                $folderPath = Join-Path -Path (Get-Item -LiteralPath $Path).Directory.Parent -ChildPath $folderName
            } elseif ($DestinationPath) {
                $folderPath = $DestinationPath
            } else {
                $folderPath = (Get-Item -LiteralPath $Path).Directory
            }
        }

        if ($Update) {
            $folderPath = (Get-Item -LiteralPath $Path).Directory
        }

        if ($CreateNfo) {
            $nfoPath = Join-Path -Path $folderPath -ChildPath "$nfoName.nfo"
        }

        if ($DownloadThumbImg) {
            if ($null -ne $Data.CoverUrl) {
                $thumbPath = Join-Path -Path $folderPath -ChildPath "$thumbName.jpg"
            }
        }

        if ($DownloadPosterImg) {
            $posterName = @()
            $posterPath = @()
            foreach ($format in $PosterFormat) {
                $posterName += Convert-JVString -Data $Data -Format $format -MaxTitleLength $MaxTitleLength -Delimiter $DelimiterFormat -ActressLanguageJa:$ActressLanguageJa -FirstNameOrder:$FirstNameOrder -GroupActress:$GroupActress
            }
            foreach ($poster in $posterName) {
                $posterPath += @(Join-Path $folderPath -ChildPath "$poster.jpg")
            }
        }

        if ($DownloadActressImg) {
            if ($null -ne $Data.Actress) {
                $actressThumbPath = @()
                $actorFolderPath = Join-Path -Path $folderPath -ChildPath $actorFolderName
                $nfoXML = [xml]$nfoContents
                foreach ($actress in $nfoXML.movie.actor) {
                    if ($actress.thumb -ne '') {
                        $newName = ($actress.name -split ' ') -join '_'
                        $actressThumbPath += @(Join-Path -Path $actorFolderPath -ChildPath "$newName.jpg")
                    }
                }
            }
        }

        if ($DownloadScreenshotImg) {
            $screenshotPath = @()
            if ($null -ne $Data.ScreenshotUrl) {
                $index = 1
                $screenshotFolderPath = Join-Path $folderPath -ChildPath $screenshotFolderName

                foreach ($screenshot in $Data.ScreenshotUrl) {
                    $screenshotPath += @(Join-Path -Path $screenshotFolderPath -ChildPath "$screenshotImgName$index.jpg")
                    $index++
                }
            }
        }

        if ($DownloadTrailerVid) {
            if ($null -ne $Data.TrailerUrl -and $Data.TrailerUrl -ne '') {
                $trailerPath = Join-Path -Path $folderPath -ChildPath "$trailerName.mp4"
            }
        }

        if ($RenameFile -and (!($Update))) {
            $filePath = Join-Path -Path $folderPath -ChildPath "$fileName$((Get-Item -LiteralPath $Path).Extension)"
        } else {
            if (!($Update)) {
                $filePath = Join-Path -Path $folderPath -ChildPath (Get-Item -LiteralPath $Path).Name
            }
        }

        $pathObject = [PSCustomObject]@{
            FileName             = $fileName
            FolderName           = $folderName
            ThumbName            = $thumbName
            PosterName           = $posterName
            TrailerName          = $trailerName
            ScreenshotImgName    = $screenshotImgName
            ScreenshotFolderName = $screenshotFolderName
            ActorFolderName      = $actorFolderName
            RenameNewPath        = ((Get-Item -LiteralPath $Path).Directory.Parent).ToString()
            ParentPath           = ((Get-Item -LiteralPath $Path).Directory).ToString()
            FilePath             = $filePath
            FolderPath           = $folderPath
            NfoPath              = $nfoPath
            ThumbPath            = $thumbPath
            PosterPath           = $posterPath
            ActorFolderPath      = $actorFolderPath
            ScreenshotFolderPath = $screenshotFolderPath
            TrailerPath          = $trailerPath
            PartNumber           = $PartNumber
        }

        $object = @{
            Data     = $Data
            SortData = $pathObject
        }

        Write-Output $object
    }
}
