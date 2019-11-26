function Convert-JavTitle {
    [CmdletBinding()]
    param (
        [ValidateScript( {
                if ( -Not ($_ | Test-Path) ) {
                    throw "File or folder does not exist"
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [system.io.fileinfo]$Path
    )

    function Get-Files {
        [CmdletBinding()]
        param (
            [Parameter()]
            [string]$Path
        )

        $script:Files = Get-Item -Path $Path | Where-Object {
            $_.Name -like '*.mp4'`
                -or $_.Name -like '*.avi'`
                -or $_.Name -like '*.mkv'`
                -or $_.Name -like '*.wmv'`
                -or $_.Name -like '*.flv'`
                -or $_.Name -like '*.mov'`
                -and $_.Name -notlike '*1pon*'`
                -and $_.Name -notlike '*carib*' `
                -and $_.Name -notlike '*t28*'`
                -and $_.Name -notlike '*fc2*'`
                -and $_.Name -notlike '*COS☆ぱこ*'`
                -and $_.Length -ge ($FileSize * 1MB)`
        }
    }

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

    $FileBaseNameOriginal = @($Files.BaseName)
    $FileExtension = @($Files.Extension)
    $FileBaseNameUpper = @()
    $FileBaseNameUpperCleaned = @()
    $FinalFileName = @()
    $FileBaseNameHyphen = $null
    $FileP1, $FileP2, $FileP3, $FileP4 = @()

    Get-Files -Path $Path

    # Iterate through each value in $RemoveStrings and replace from $FileBaseNameOriginal
    foreach ($String in $RemoveStrings) {
        if ($String -eq '_') {
            $FileBaseNameOriginal = $FileBaseNameOriginal -replace $String, '-'
        } else {
            $FileBaseNameOriginal = $FileBaseNameOriginal -replace $String, ''
        }
    }

    foreach ($File in $FileBaseNameOriginal) {
        $FileBaseNameUpper += $File.ToUpper()
    }

    # Iterate through each file in $Files to add hypen(-) between title and ID if not exists
    $Counter = -1
    foreach ($File in $FileBaseNameUpper) {
        # Iterate through file name length
        for ($x = 0; $x -lt $File.Length; $x++) {
            # Match if an alphabetical character index is next to a numerical index
            if ($File[$x] -match '^[a-z]*$' -and $File[$x + 1] -match '^[0-9]$') {
                # Write modified filename to $FileBaseNameHyphen, inserting a '-' at the specified
                # index between the alphabetical and numerical character, and appending extension
                $FileBaseNameHyphen = ($File.Insert($x + 1, '-'))
            }
        }
        # Get index if file changed
        $Counter++
        # Rename changed files
        if ($null -ne $FileBaseNameHyphen) {
            $FileBaseNameUpper[$Counter] = $FileBaseNameHyphen
        }
        $FileBaseNameHyphen = $null
    }

    # Clean any trailing text if not removed by $RemoveStrings
    for ($x = 0; $x -lt $FileBaseNameUpper.Length; $x++) {
        #Match ID-###A, ID###B, etc.
        if ($FileBaseNameUpper[$x] -match "[-][0-9]{1,6}[a-zA-Z]") {
            $FileP1, $FileP2, $FileP3 = $FileBaseNameUpper[$x] -split "([-][0-9]{1,6}[a-zA-Z])"
            $FileBaseNameUpperCleaned += $FileP1 + $FileP2
        }
        #Match ID-###-A, ID-###-B, etc.
        elseif ($FileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-][a-zA-Z]") {
            $FileP1, $FileP2, $FileP3, $FileP4 = $FileBaseNameUpper[$x] -split "([-][0-9]{1,6})[-]([a-zA-Z])"
            $FileBaseNameUpperCleaned += $FileP1 + $FileP2 + $FileP3
        }
        # Match ID-###-1, ID-###-2, etc.
        elseif ($FileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]\d$") {
            $FileP1, $FileP2, $FileP3 = $FileBaseNameUpper[$x] -split "([-][0-9]{1,6}[-]\d)"
            $FileBaseNameUpperCleaned += $FileP1 + $FileP2
        }
        # Match ID-###-01, ID-###-02, etc.
        elseif ($FileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]\d\d$") {
            $FileP1, $FileP2, $FileP3 = $FileBaseNameUpper[$x] -split "([-][0-9]{1,6}[-]\d\d)"
            $FileBaseNameUpperCleaned += $FileP1 + $FileP2
        }
        # Match ID-###-001, ID-###-02, etc.
        elseif ($FileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]\d\d\d$") {
            $FileP1, $FileP2, $FileP3 = $FileBaseNameUpper[$x] -split "([-][0-9]{1,6}[-]\d\d\d)"
            $FileBaseNameUpperCleaned += $FileP1 + $FileP2
        }
        # Match everything else
        else {
            $FileP1, $FileP2, $FileP3 = $FileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
            $FileBaseNameUpperCleaned += $FileP1 + $FileP2
        }
    }

    $FinalFileName = "$FileBaseNameUpperCleaned$FileExtension"

    $dataObject = [PSCustomObject]@{
        Id       = $FileBaseNameUpperCleaned
        FileName = $FinalFileName
    }

    return $dataObject
}
