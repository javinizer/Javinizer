function Convert-JavTitle {
    [CmdletBinding()]
    param (
        [ValidateScript( {
                if ( -Not ($_ | Test-Path) ) {
                    throw "$_ does not exist"
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [system.io.fileinfo]$Path
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
        $files = Get-VideoFile -Path $Path
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

        # Clean any trailing text if not removed by $RemoveStrings
        for ($x = 0; $x -lt $fileBaseNameUpper.Length; $x++) {
            #Match ID-###A, ID###B, etc.
            if ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[a-zA-Z]") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6}[a-zA-Z])"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
            }
            #Match ID-###-A, ID-###-B, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-][a-zA-Z]") {
                $fileP1, $fileP2, $fileP3, $fileP4 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})[-]([a-zA-Z])"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2 + $fileP3
            }
            # Match ID-###-1, ID-###-2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]\d$") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6}[-]\d)"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
            }
            # Match ID-###-01, ID-###-02, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]\d\d$") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6}[-]\d\d)"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
            }
            # Match ID-###-001, ID-###-02, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]\d\d\d$") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6}[-]\d\d\d)"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
            }
            # Match everything else
            else {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
            }

            if ($files.Count -eq '1') {
                $finalFileName = $fileBaseNameUpperCleaned[$x] + $files.Extension
                $originalFileName = $files.Name
                $fileExtension = $files.Extension
            } else {
                $finalFileName = $fileBaseNameUpperCleaned[$x] + $files.Extension[$x]
                $originalFileName = $files.Name[$x]
                $fileExtension = $files.Extension[$x]
            }

            $dataObject += [PSCustomObject]@{
                Id               = $fileBaseNameUpperCleaned[$x]
                NewFileName      = $finalFileName
                OriginalFileName = $originalFileName
                Extension        = $fileExtension
            }
        }

        Write-Output $dataObject
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
