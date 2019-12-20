function Convert-JavTitle {
    [CmdletBinding()]
    param (
        [ValidateScript( {
                if (-Not ($_ | Test-Path) ) {
                    throw "$_ does not exist"
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,
        [object]$Settings,
        [switch]$Recurse
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
        # Unwanted strings in files to remove
        $RemoveStrings = @(
            # Prefixes
            'hjd2048.com-',
            '^[0-9]{4}',
            'xhd1080.com',
            'ShareSex.net',
            'jav365.com_',
            '069-3XPLANET-',
            'javl.in_',
            'Watch18plus-',
            '\[(.*?)\]',
            'FHD-',
            'FHD_',
            'fhd',
            'Watch ',
            # Suffixes (obsolete(?))
            '-h264',
            '-AV',
            '_www.avcens.download'
            '_JAV.1399.net',
            '_JAV-Video.net',
            '-VIDEOAV.NET',
            '-JAVTEG.NET',
            '.hevc.',
            '.javaddiction'
            'SmallJAV',
            ' AVFUL.TK',
            ' INCESTING.TK',
            'javnasty.tk',
            ' javhd21.com',
            ' avfullhd.tk',
            '.1080p',
            '.720p',
            '.480p',
            '-HD',
            'wmv',
            '.wmv',
            'avi',
            '.avi',
            'mp4',
            '.mp4',
            '_'
        )

        $dataObject = @()
        $fileBaseNameUpper = @()
        $fileBaseNameUpperCleaned = @()
        $finalFileName = @()
        $fileBaseNameHypen = $null
        $fileP1, $fileP2, $fileP3, $fileP4 = @()
    }

    process {
        $files = Get-VideoFile -Path $Path -Recurse:$Recurse -Settings $Settings
        $FileBaseNameOriginal = @($files.BaseName)
        # Iterate through each value in $RemoveStrings and replace from $FileBaseNameOriginal
        foreach ($string in $RemoveStrings) {
            if ($string -eq '_') {
                $FileBaseNameOriginal = $FileBaseNameOriginal -replace $string, '-'
            } else {
                $FileBaseNameOriginal = $FileBaseNameOriginal -replace $string, ''
            }
        }

        foreach ($file in $FileBaseNameOriginal) {
            $fileBaseNameUpper += $file.ToUpper()
        }

        # Iterate through each file in $files to add hypen(-) between title and ID if not exists
        $Counter = -1
        foreach ($file in $fileBaseNameUpper) {
            if ($file -notmatch 't28' -and $file -notmatch 't-28') {
                # Iterate through file name length
                for ($x = 0; $x -lt $file.Length; $x++) {
                    # Match if an alphabetical character index is next to a numerical index
                    if ($file[$x] -match '^[a-z]*$' -and $file[$x + 1] -match '^[0-9]$') {
                        # Write modified filename to $fileBaseNameHypen, inserting a '-' at the specified
                        # index between the alphabetical and numerical character, and appending extension
                        $fileBaseNameHypen = ($file.Insert($x + 1, '-'))
                    }
                }
                # Get index if file changed
                $Counter++
                # Rename changed files
                if ($null -ne $fileBaseNameHypen) {
                    $fileBaseNameUpper[$Counter] = $fileBaseNameHypen
                }
                $fileBaseNameHypen = $null
            }
        }

        # Clean any trailing text if not removed by $RemoveStrings
        for ($x = 0; $x -lt $fileBaseNameUpper.Length; $x++) {
            $filePartNumber = $null
            #Match ID-###A, ID###B, etc.
            if ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[a-iA-I]") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 1"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                if ($fileP3 -eq 'A') { $filePartNumber = '1' }
                elseif ($fileP3 -eq 'B') { $filePartNumber = '2' }
                elseif ($fileP3 -eq 'C') { $filePartNumber = '3' }
                elseif ($fileP3 -eq 'D') { $filePartNumber = '4' }
                elseif ($fileP3 -eq 'E') { $filePartNumber = '5' }
                elseif ($fileP3 -eq 'F') { $filePartNumber = '6' }
                elseif ($fileP3 -eq 'G') { $filePartNumber = '7' }
                elseif ($fileP3 -eq 'H') { $filePartNumber = '8' }
                elseif ($fileP3 -eq 'I') { $filePartNumber = '9' }
            }
            # Match ID-###-A, ID-###-B, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-][a-iA-I]") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 2"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $fileP3 = $fileP3 -replace '-', ''
                if ($fileP3 -eq 'A') { $filePartNumber = '1' }
                elseif ($fileP3 -eq 'B') { $filePartNumber = '2' }
                elseif ($fileP3 -eq 'C') { $filePartNumber = '3' }
                elseif ($fileP3 -eq 'D') { $filePartNumber = '4' }
                elseif ($fileP3 -eq 'E') { $filePartNumber = '5' }
                elseif ($fileP3 -eq 'F') { $filePartNumber = '6' }
                elseif ($fileP3 -eq 'G') { $filePartNumber = '7' }
                elseif ($fileP3 -eq 'H') { $filePartNumber = '8' }
                elseif ($fileP3 -eq 'I') { $filePartNumber = '9' }
            }
            #Match ID-###-A, ID-###-B, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-][a-iA-I]$") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 3"
                $fileP1, $fileP2, $fileP3, $fileP4 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})[-]([a-zA-Z])"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2 + $fileP3
            }
            # Match ID-###-1, ID-###-2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]\d$") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 4"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ($fileP3 -replace '-', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-###-01, ID-###-02, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]0\d$") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 5"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = (($fileP3 -replace '-', '') -replace '0', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-###-001, ID-###-002, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]00\d$") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 6"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = (($fileP3 -replace '-', '') -replace '0', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-### - pt1, ID-### - pt2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6} [-] pt") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 7"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ((($fileP3 -replace '-', '') -replace '0', '') -replace 'pt', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-### - part1, ID ### - part2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6} [-] part") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 8"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ((($fileP3 -replace '-', '') -replace '0', '') -replace 'pt', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-###-pt1, ID-###-pt2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]pt") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 9"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ((($fileP3 -replace '-', '') -replace '0', '') -replace 'pt', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-###-part1, ID-###-part2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]part") {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 10"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ((($fileP3 -replace '-', '') -replace '0', '') -replace 'pt', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match everything else
            else {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Match 11"
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
            }

            if ($fileBaseNameUpper[$x] -match '00\d') {
                $contentId = $fileBaseNameUpper[$x] -split '-'
                $contentId = $contentId[0] + '00' + $contentId[1]
            } elseif ($fileBaseNameUpper[$x] -match '0\d\d') {
                $contentId = $fileBaseNameUpper[$x] -split '-'
                $contentId = $contentId[0] + '00' + $contentId[1]
            } else {
                $contentId = $fileBaseNameUpper[$x] -split '-'
                $contentId = $contentId[0] + '00' + $contentId[1]
            }

            if ($files.Count -eq '1') {
                $finalFileName = $fileBaseNameUpperCleaned[$x] + $files.Extension
                $originalFileName = $files.Name
                $originalBaseName = $files.BaseName
                $originalDirectory = $files.Directory
                $fileExtension = $files.Extension
            } else {
                $finalFileName = $fileBaseNameUpperCleaned[$x] + $files.Extension[$x]
                $originalFileName = $files.Name[$x]
                $originalBaseName = $files.BaseName[$x]
                $originalDirectory = $files.Directory[$x]
                $fileExtension = $files.Extension[$x]
                $filePartNumber = $filePartNumber
            }

            $dataObject += [pscustomobject]@{
                Id                = $fileBaseNameUpperCleaned[$x]
                ContentId         = $contentId
                NewFileName       = $finalFileName
                OriginalFileName  = $originalFileName
                OriginalBaseName  = $originalBaseName
                OriginalDirectory = $originalDirectory
                Extension         = $fileExtension
                OriginalFullName  = if ($files.Count -eq 1) { $files.FullName } else { $files.fullname[$x] }
                PartNumber        = $filePartNumber
            }
        }

        Write-Output $dataObject
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}

<# function Rename-Definitions {
    param (
        [object]$Files
    )

    foreach ($file in $Files) {
        $newFileName = $file.BaseName -replace '\[HD\]', '' `
            -replace '\[FHD\]', '' `
            -replace '\[SD\]', '' `
            -replace '(SD)', '' `
            -replace '(HD)', '' `
            -replace '(FHD)', ''

        $cleanFiles += $newFileName
    }

    Write-Output $cleanFiles
} #>
