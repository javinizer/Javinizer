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

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [PSObject]$SortData,

        [Parameter()]
        [Switch]$Update,

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
        [Alias('sort.metadata.nfo.firstnameorder')]
        [Boolean]$FirstNameOrder,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.nfo.actresslanguageja')]
        [Boolean]$ActressLanguageJa,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.nfo.originalpath')]
        [Boolean]$OriginalPath,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.metadata.nfo.altnamerole')]
        [Boolean]$AltNameRole,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.format.screenshotimg.padding')]
        [Int]$ScreenshotImgPadding,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('sort.movesubtitles')]
        [Boolean]$MoveSubtitles
    )

    begin {
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }

        # Add custom webclient class to extend timeout durations
        # https://stackoverflow.com/questions/40431173/powershell-script-webclient-timeout-140-calling-an-ssrs-report
        $Source = @"
#pragma warning disable SYSLIB0014
using System.Net;

public class ExtendedWebClient : WebClient {
    public int Timeout;

    protected override WebRequest GetWebRequest(System.Uri address) {
        WebRequest request = base.GetWebRequest(address);
        if (request != null) {
            request.Timeout = Timeout;
        }
        return request;
    }

    public ExtendedWebClient() {
        Timeout = 100000; // Timeout value by default
    }
}
"@;

        Add-Type -TypeDefinition $Source -Language CSharp

        function New-WebClient {
            param (
                [Switch]$Proxy,
                [String]$ProxyUrl,
                [String]$ProxyUser,
                [String]$ProxyPass
            )

            # $webClient = New-Object System.Net.WebClient

            $webClient = New-Object ExtendedWebClient;
            $webClient.Timeout = $Settings.'sort.download.timeoutduration'
            $webclient.Headers.Add("User-Agent: Other")
            if ($Proxy) {
                $newProxy = New-Object System.Net.WebProxy
                $newProxy.Address = $ProxyUrl
                $webClient.Proxy = $newProxy
                if ($ProxyUser -ne '' -or $ProxyPass -ne '') {
                    $cred = New-Object System.Net.NetworkCredential -ArgumentList $ProxyUser, $ProxyPass
                    $webClient.Credentials = $cred
                }
            }

            return $webClient
        }
    }

    process {
        if ($Settings) {
            $MoveToFolder = $Settings.'sort.movetofolder'
            $RenameFile = $Settings.'sort.renamefile'
            $RenameFolder = $Settings.'sort.renamefolderinplace'
            $MaxTitleLength = $Settings.'sort.maxtitlelength'
            $CreateNfo = $Settings.'sort.create.nfo'
            $CreateNfoPerFile = $Settings.'sort.create.nfoperfile'
            $DownloadActressImg = $Settings.'sort.download.actressimg'
            $DownloadThumbImg = $Settings.'sort.download.thumbimg'
            $DownloadPosterImg = $Settings.'sort.download.posterimg'
            $DownloadScreenshotImg = $Settings.'sort.download.screenshotimg'
            $DownloadTrailerVid = $Settings.'sort.download.trailervid'
            $FirstNameOrder = $Settings.'sort.metadata.nfo.firstnameorder'
            $ActressLanguageJa = $Settings.'sort.metadata.nfo.actresslanguageja'
            $OriginalPath = $Settings.'sort.metadata.nfo.originalpath'
            $AltNameRole = $Settings.'sort.metadata.nfo.altnamerole'
            $AddGenericRole = $Settings.'sort.metadata.nfo.addgenericrole'
            $ScreenshotImgPadding = $Settings.'sort.format.screenshotimg.padding'
            $Proxy = $Settings.'proxy.enabled'
            $ProxyUrl = $Settings.'proxy.host'
            $ProxyUser = $Settings.'proxy.username'
            $ProxyPass = $Settings.'proxy.password'
            $MoveSubtitles= $Settings.'sort.movesubtitles'
        }

        if ($OriginalPath) {
            $nfoContents = $Data | Get-JVNfo -NameOrder $FirstNameOrder -ActressLanguageJa:$ActressLanguageJa -OriginalPath:$Path -AltNameRole:$AltNameRole -AddGenericRole:$AddGenericRole -AddAliases:$Settings.'sort.metadata.nfo.addaliases'
        } else {
            $nfoContents = $Data | Get-JVNfo -NameOrder $FirstNameOrder -ActressLanguageJa:$ActressLanguageJa -AltNameRole:$AltNameRole -AddGenericRole:$AddGenericRole -AddAliases:$Settings.'sort.metadata.nfo.addaliases'
        }

        if ($Force -or $PSCmdlet.ShouldProcess($Path)) {
            # Windows directory paths do not allow trailing dots/periods but do not throw an error on creation
            $sortData.FolderPath = ([String]$sortData.FolderPath).TrimEnd('.')

            # We do not want to recreate the destination folder if it already exists
            try {
                if ($RenameFolder) {
                    # Force multipart movies to wait to avoid race condition when renaming the folder
                    if ($sortData.PartNumber -gt 0) {
                        Start-Sleep -Seconds 5
                    }
                    Rename-Item -LiteralPath $sortData.ParentPath -NewName $sortData.FolderName -ErrorAction SilentlyContinue
                    $Path = Join-Path -Path $sortData.RenameNewPath -ChildPath $sortData.FolderName -AdditionalChildPath $Path.Name
                } else {
                    if (!(Test-Path -LiteralPath $sortData.FolderPath) -and (!($Update))) {
                        New-Item -Path $sortData.FolderPath -ItemType Directory -Force:$Force | Out-Null
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Directory] created at path [$($sortData.FolderPath)]"
                    }
                }
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating destination folder path [$($sortData.FolderPath)]: $PSItem"
            }

            if ($CreateNfo) {
                try {
                    $nfoContents | Out-File -LiteralPath $sortData.NfoPath -Force:$Force
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Nfo] created at path [$($sortData.NfoPath)]"
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating nfo file [$($sortData.NfoPath)]: $PSItem"
                }
            }

            if ($DownloadThumbImg) {
                if ($null -ne $Data.CoverUrl) {
                    try {
                        $webClient = New-WebClient -Proxy:$Proxy -ProxyUrl $ProxyUrl -ProxyUser $ProxyUser -ProxyPass $ProxyPass
                        if ($sortData.PartNumber -eq 0 -or $sortData.PartNumber -eq 1) {
                            if ($Force) {
                                if (Test-Path -LiteralPath $sortData.ThumbPath) {
                                    Remove-Item -LiteralPath $sortData.ThumbPath -Force
                                }
                                $webClient.DownloadFile(($Data.CoverUrl).ToString(), $sortData.ThumbPath)
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Thumbnail - $($Data.CoverUrl)] downloaded to path [$($sortData.ThumbPath)]"
                            } elseif (!(Test-Path -LiteralPath $sortData.ThumbPath)) {
                                $webClient.DownloadFile(($Data.CoverUrl).ToString(), $sortData.ThumbPath)
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Thumbnail - $($Data.CoverUrl)] downloaded to path [$($sortData.ThumbPath)]"
                            }
                        } else {
                            if (!(Test-Path -LiteralPath $sortData.ThumbPath)) {
                                Start-Sleep -Seconds 2
                                if (!(Test-Path -LiteralPath $sortData.ThumbPath)) {
                                    $webClient.DownloadFile(($Data.CoverUrl).ToString(), $sortData.ThumbPath)
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Thumbnail - $($Data.CoverUrl)] downloaded to path [$($sortData.ThumbPath)]"
                                }
                            }
                        }
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating thumbnail image file [$($sortData.ThumbPath)]: $PSItem"
                    }

                    if ($DownloadPosterImg) {
                        try {
                            $cropScriptPath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'crop.py'
                            if (Test-Path -LiteralPath $cropScriptPath) {
                                foreach ($poster in $sortData.PosterPath) {
                                    $pythonThumbPath = $sortData.ThumbPath -replace '\\', '/'
                                    $pythonPosterPath = $poster -replace '\\', '/'
                                    if ($sortData.PartNumber -eq 0 -or $sortData.PartNumber -eq 1) {
                                        if ($Force) {
                                            if (Test-Path -LiteralPath $sortData.PosterPath) {
                                                Remove-Item -LiteralPath $sortData.PosterPath -Force
                                            }
                                            if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                                python $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $($sortData.ThumbPath)] cropped to path [$($poster)]"
                                            } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                                python3 $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $($sortData.ThumbPath)] cropped to path [$($poster)]"
                                            }
                                        } elseif (!(Test-Path -LiteralPath $poster)) {
                                            if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                                python $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $($sortData.ThumbPath)] cropped to path [$($poster)]"
                                            } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                                python3 $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $($sortData.ThumbPath)] cropped to path [$($poster)]"
                                            }
                                        }
                                    } else {
                                        if (!(Test-Path -LiteralPath $poster)) {
                                            Start-Sleep -Seconds 2
                                            if (!(Test-Path -LiteralPath $poster)) {
                                                if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                                    python $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $sortData.ThumbPath] cropped to path [$poster]"
                                                } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                                    python3 $cropScriptPath $pythonThumbPath $pythonPosterPath
                                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Poster - $sortData.ThumbPath] cropped to path [$poster]"
                                                }
                                            }
                                        }
                                    }
                                }

                            } else {
                                Write-JLog -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Crop.py file is missing or cannot be found at path [$cropScriptPath]"
                            }
                        } catch {
                            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating poster image file [$($poster)]: $PSItem"
                        }
                    }
                }
            }

            if ($DownloadActressImg) {
                if ($null -ne $Data.Actress) {
                    try {
                        if (!(Test-Path -LiteralPath $sortData.ActorFolderPath)) {
                            New-Item -Path $sortData.ActorFolderPath -ItemType Directory -Force:$Force | Out-Null
                        }

                        $nfoXML = [xml]$nfoContents
                        foreach ($actress in $nfoXML.movie.actor) {
                            if ($actress.thumb -ne '') {
                                $webClient = New-WebClient -Proxy:$Proxy -ProxyUrl $ProxyUrl -ProxyUser $ProxyUser -ProxyPass $ProxyPass
                                $newName = ($actress.name -split ' ') -join '_'
                                $actressThumbPath = Join-Path -Path $sortData.ActorFolderPath -ChildPath "$newName.jpg"

                                if ($sortData.PartNumber -eq 0 -or $sortData.PartNumber -eq 1) {
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
                        if (!(Test-Path -LiteralPath $sortData.ScreenshotFolderPath)) {
                            New-Item -Path $sortData.ScreenshotFolderPath -ItemType Directory -Force:$Force -ErrorAction SilentlyContinue | Out-Null
                        }

                        foreach ($screenshot in $Data.ScreenshotUrl) {
                            $webClient = New-WebClient -Proxy:$Proxy -ProxyUrl $ProxyUrl -ProxyUser $ProxyUser -ProxyPass $ProxyPass
                            $paddedIndex = $index.ToString().PadLeft($ScreenshotImgPadding, '0')
                            $screenshotName = "$($sortData.ScreenshotImgName)$paddedIndex.jpg"
                            $screenshotPath = Join-Path -Path $sortData.ScreenshotFolderPath -ChildPath $screenshotName
                            if ($sortData.PartNumber -eq 0 -or $sortData.PartNumber -eq 1) {
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
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating screenshot image file [$screenshot] from to [$screenshotPath]: $PSItem"
                    }
                }
            }

            if ($DownloadTrailerVid) {
                if ($null -ne $Data.TrailerUrl -and $Data.TrailerUrl -ne '') {
                    try {
                        $webClient = New-WebClient -Proxy:$Proxy -ProxyUrl $ProxyUrl -ProxyUser $ProxyUser -ProxyPass $ProxyPass
                        if ($sortData.PartNumber -eq 0 -or $sortData.PartNumber -eq 1) {
                            if ($Force.IsPresent) {
                                if (Test-Path -LiteralPath $sortData.TrailerPath) {
                                    Remove-Item -LiteralPath $sortData.TrailerPath
                                }
                                $webClient.DownloadFile($Data.TrailerUrl, $sortData.TrailerPath)
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [TrailerVid - $($Data.TrailerUrl)] downloaded to path [$($sortData.TrailerPath)]"
                            } elseif (!(Test-Path -LiteralPath $sortData.TrailerPath)) {
                                $webClient.DownloadFile($Data.TrailerUrl, $sortData.TrailerPath)
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [TrailerVid - $($Data.TrailerUrl)] downloaded to path [$($sortData.TrailerPath)]"
                            }
                        } else {
                            if (!(Test-Path -LiteralPath $sortData.TrailerPath)) {
                                Start-Sleep -Seconds 2
                                if (!(Test-Path -LiteralPath $sortData.TrailerPath)) {
                                    $webClient.DownloadFile($Data.TrailerUrl, $sortData.TrailerPath)
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [TrailerVid - $($Data.TrailerUrl)] downloaded to path [$($sortData.TrailerPath)]"
                                }
                            }
                        }
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when creating trailer video file [$($Data.TrailerUrl)] to [$($sortData.TrailerName)]: $PSItem"
                    }
                }
            }

            if ($MoveSubtitles) {
                try {
                    $languageCodes = Import-Csv -Path (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'languageCodes.csv')
                    $subtitleFiles = Get-ChildItem -Path $sortData.ParentPath | Where-Object {$_.extension -match '\.ass|\.ssa|\.srt|\.smi|\.vtt' }

                    foreach ($file in $subtitleFiles) {
                        $simpleLanguageCheck = ($file.BaseName -split '\.')[1]

                        if (($simpleLanguageCheck -in $languageCodes.'Alpha3b_Code') -or ($simpleLanguageCheck -in $languageCodes.'Alpha2_Code')) {
                            $subtitleLanguage = $simpleLanguageCheck
                        } else {
                            # Default to english if the subtitle language is not correctly matched
                            # This is operating under the assumption that in the majority of cases that english is the desired subtitle language
                            $subtitleLanguage = "eng"
                        }

                        $subtitleName = "$($sortData.FileName).$($subtitleLanguage)$($file.Extension)"
                        $sortedSubtitlePath = Join-Path -Path $sortData.FolderPath -ChildPath $subtitleName

                        # If 'eng' was already matched, then let the rest continue as-is if not matched
                        Rename-Item $file -NewName $subtitleName -ErrorAction 'SilentlyContinue'
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [Subtitle] moved to path [$($sortedSubtitlePath)]"
                    }

                    # Move all subtitle files after updating them
                    Get-ChildItem -Path $sortData.ParentPath | Where-Object {$_.extension -match '\.ass|\.ssa|\.srt|\.smi|\.vtt' } | Move-Item -Destination $sortData.FolderPath
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when moving subtitle: $PSItem"
                }
            }

            if ($RenameFile -and !$Update) {
                try {
                    if ($RenameFolder) {
                        if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                            Move-Item -LiteralPath $Path -Destination $sortData.FilePath -Force:$Force
                        } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                            if ($Force) {
                                try {
                                    Move-Item $Path $sortData.FilePath --force
                                } catch {
                                    Move-Item -LiteralPath $Path -Destination $sortData.FilePath -Force
                                }
                            } else {
                                try {
                                    Move-Item $Path $sortData.FilePath --no-clobber
                                } catch {
                                    Move-Item -LiteralPath $Path -Destination $sortData.FilePath
                                }
                            }
                        }
                    } else {
                        if ((Get-Item -LiteralPath $DestinationPath).Directory -ne (Get-Item -LiteralPath $Path).Directory) {
                            if ((Get-Item -LiteralPath $Path).FullName -ne $sortData.FilePath) {
                                if (!(Test-Path -LiteralPath $sortData.FilePath)) {
                                    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                        Move-Item -LiteralPath $Path -Destination $sortData.FilePath -Force:$Force
                                    } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                        if ($Force) {
                                            try {
                                                Move-Item $Path $sortData.FilePath --force
                                            } catch {
                                                Move-Item -LiteralPath $Path -Destination $sortData.FilePath -Force
                                            }
                                        } else {
                                            try {
                                                Move-Item $Path $sortData.FilePath --no-clobber
                                            } catch {
                                                Move-Item -LiteralPath $Path -Destination $sortData.FilePath
                                            }
                                        }
                                    }
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path] => [$($sortData.FilePath)]"
                                } else {
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path] but did not move as the destination file already exists"
                                }
                            } else {
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Updated [$Path]"
                            }
                        }
                    }
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Error occurred when renaming and moving file [$Path] to [$($sortData.FilePath)]: $PSItem"
                }
            } else {
                if (!($Update)) {
                    try {
                        if ((Get-Item -LiteralPath $DestinationPath).Directory -ne (Get-Item -LiteralPath $Path).Directory) {
                            if ((Get-Item -LiteralPath $Path).FullName -ne $sortData.FilePath) {
                                if (!(Test-Path -LiteralPath $sortData.FilePath)) {
                                    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                                        Move-Item -LiteralPath $Path -Destination $sortData.FilePath -Force:$Force
                                    } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                                        if ($Force) {
                                            try {
                                                Move-Item $Path $sortData.FilePath --force
                                            } catch {
                                                Move-Item -LiteralPath $Path -Destination $sortData.FilePath -Force
                                            }
                                        } else {
                                            try {
                                                Move-Item $Path $sortData.FilePath --no-clobber
                                            } catch {
                                                Move-Item -LiteralPath $Path -Destination $sortData.FilePath
                                            }
                                        }
                                    }
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path] => [$($sortData.FilePath)]"
                                } else {
                                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Completed [$Path] but did not move as the destination file already exists"
                                }
                            } else {
                                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Info "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] Updated [$Path]"
                            }
                        }
                    } catch {
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($Data.Id)] [$($MyInvocation.MyCommand.Name)] [$($MyInvocation.MyCommand.Name)] Error occurred when renaming and moving file [$Path] to [$($sortData.FilePath)]: $PSItem"
                    }
                }
            }
        }
    }
}
