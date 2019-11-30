function Set-JavMovie {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$DataObject,
        [object]$Settings,
        [system.io.fileinfo]$Path,
        [system.io.fileinfo]$DestinationPath
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        $Path = (Get-Item $Path).FullName
        $DestinationPath = (Get-Item $DestinationPath).FullName
        $webClient = New-Object System.Net.WebClient
        $modulePath = (Get-Item $PSScriptroot).Parent
        $cropPath = Join-Path -Path $modulePath -ChildPath 'crop.py'
        $folderPath = Join-Path $DestinationPath -ChildPath $dataObject.FolderName
        $nfoPath = Join-Path -Path $folderPath -ChildPath ($dataObject.FileName + '.nfo')
        $coverPath = Join-Path -Path $folderPath -ChildPath ('fanart.jpg')
        $posterPath = Join-Path -Path $folderPath -ChildPath ('poster.jpg')
        $screenshotPath = Join-Path -Path $folderPath -ChildPath 'extrafanart'
        $newFileName = $dataObject.FileName + $Path.Extension

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Crop path: [$cropPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Folder path: [$folderPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Nfo path: [$nfoPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Cover path: [$coverPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Poster path: [$posterPath]"
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Screenshot path: [$screenshotPath]"
    }

    process {
        $dataObject = Test-RequiredMetadata -DataObject $DataObject -Settings $settings
        if ($null -ne $dataObject) {
            New-Item -ItemType Directory -Name $dataObject.FolderName -Path $DestinationPath -Force | Out-Null
            Get-MetadataNfo -DataObject $dataObject -Settings $Settings | Out-File -LiteralPath $nfoPath -Force
            Rename-Item -Path $Path -NewName $newFileName -PassThru | Move-Item -Destination $folderPath

            if ($Settings.Metadata.'download-thumb-img' -eq 'True') {
                if ($null -ne $dataObject.CoverUrl) {
                    $webClient.DownloadFile(($dataObject.CoverUrl).ToString(), $coverPath)
                    if ($Settings.Metadata.'download-poster-img' -eq 'True') {
                        # Double backslash to conform with Python path standards
                        $coverPath = $coverPath -replace '\\', '\\'
                        $posterPath = $posterPath -replace '\\', '\\'
                        if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                            python $cropPath $coverPath $posterPath
                        } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                            python $cropPath $coverPath $posterPath
                        }
                    }
                }
            }

            if ($Settings.Metadata.'download-screenshot-img' -eq 'True') {
                New-Item -ItemType Directory -Name 'extrafanart' -Path $folderPath -Force | Out-Null
                $index = 1
                foreach ($screenshot in $dataObject.ScreenshotUrl) {
                    $webClient.DownloadFile($screenshot, (Join-Path -Path $screenshotPath -ChildPath "fanart$index.jpg"))
                    $index++
                }
            }
        }
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
