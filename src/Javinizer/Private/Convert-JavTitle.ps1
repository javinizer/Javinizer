function Convert-JavTitle {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]$Files,
        [Parameter()]
        [switch]$Strict,
        [Parameter()]
        [string]$RegexEnabled,
        [Parameter()]
        [string]$RegexString,
        [Parameter()]
        [int]$RegexIdMatch,
        [Parameter()]
        [int]$RegexPtMatch
    )

    process {
        $dataObject = @()
        $fileBaseNameUpper = @()
        $fileBaseNameUpperCleaned = @()
        $fileBaseNameHyphen = $null
        $fileP1, $fileP2, $fileP3, $fileP4 = @()
        $fileBaseNameOriginal = @($Files.BaseName)

        # Unwanted strings in files to remove
        $RemoveStrings = @(
            # Prefixes
            'hjd2048.com-',
            '1080fhd.com_',
            '^[0-9]{4}',
            'xhd1080.com',
            'ShareSex.net',
            'jav365.com_',
            '069-3XPLANET-',
            'fun2048.com@',
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

        if ($RegexEnabled -eq 'True') {
            foreach ($file in $FileBaseNameOriginal) {
                $fileBaseNameUpper += $file.ToUpper()
            }

            $index = 0
            foreach ($file in $fileBaseNameUpper) {
                try {
                    $id = ($file | Select-String $RegexString).Matches.Groups[$RegexIdMatch].Value
                    $partNum = ($file | Select-String $RegexString).Matches.Groups[$RegexPtMatch].Value
                } catch {
                    Write-JLog -Level Debug -Message "File [$file] not matched by regex"
                    break
                }
                if ($fileBaseNameUpper -eq 1) {
                    if ($partNum -ne '') {
                        $fileBaseNameUpper = "$id-pt$PartNum"
                    } elseif ($id -ne '') {
                        $fileBaseNameUpper = "$id"
                    } else {
                        $fileBaseNameUpper = $file
                    }
                } else {
                    if ($partNum -ne '') {
                        $fileBaseNameUpper[$index] = "$id-pt$PartNum"
                    } elseif ($id -ne '') {
                        $fileBaseNameUpper[$index] = "$id"
                    } else {
                        $fileBaseNameUpper[$index] = $file
                    }
                }

                $index++
            }
        } else {
            # Iterate through each value in $RemoveStrings and replace from $FileBaseNameOriginal
            foreach ($string in $RemoveStrings) {
                if ($string -eq '_') {
                    $fileBaseNameOriginal = $fileBaseNameOriginal -replace $string, '-'
                } else {
                    $fileBaseNameOriginal = $fileBaseNameOriginal -replace $string, ''
                }
            }

            foreach ($file in $FileBaseNameOriginal) {
                $fileBaseNameUpper += $file.ToUpper()
            }

            # Iterate through each file in $Files to add hypen(-) between title and ID if not exists
            $counter = -1
            foreach ($file in $fileBaseNameUpper) {
                if ($file -match '^t28' -or $file -match '^t-28' -or $file -match '^r18' -or $file -match '^r-18') {
                    if ($file -match '^t28' -or $file -match '^t-28') {
                        $file = $file -replace 't-28', 't28'
                        if ($file -notmatch '-') {
                            $file = ($file -split 't28') -join 'T28-'
                            $fileBaseNameUpper[$counter] = $file
                        }
                    } elseif ($file -match '^r18' -or $file -match '^r-18') {
                        $file = $file -replace 'r-18', 'r18'
                        if ($file -notmatch '-') {
                            $file = ($file -split 'r18') -join 'R18-'
                            $fileBaseNameUpper[$counter] = $file
                        }
                    } else {
                        $fileBaseNameUpper[$counter] = $file
                    }
                } else {
                    # Iterate through file name length
                    for ($x = 0; $x -lt $file.Length; $x++) {
                        # Match if an alphabetical character index is next to a numerical index
                        if ($file[$x] -match '^[a-z]*$' -and $file[$x + 1] -match '^[0-9]$') {
                            # Write modified filename to $fileBaseNameHyphen, inserting a '-' at the specified
                            # index between the alphabetical and numerical character, and appending extension
                            $fileBaseNameHyphen = ($file.Insert($x + 1, '-'))
                        }
                    }
                    # Get index if file changed
                    $counter++
                    # Rename changed files
                    if ($null -ne $fileBaseNameHyphen) {
                        $fileBaseNameUpper[$counter] = $fileBaseNameHyphen
                    }
                    $fileBaseNameHyphen = $null
                }
            }
        }

        # Clean any trailing text if not removed by $RemoveStrings
        for ($x = 0; $x -lt $fileBaseNameUpper.Length; $x++) {
            $filePartNumber = $null
            #Match ID-###A, ID###B, etc.
            if ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[a-dA-D]") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                if ($fileP3 -eq 'A') { $filePartNumber = '1' }
                elseif ($fileP3 -eq 'B') { $filePartNumber = '2' }
                elseif ($fileP3 -eq 'C') { $filePartNumber = '3' }
                elseif ($fileP3 -eq 'D') { $filePartNumber = '4' }
                #elseif ($fileP3 -eq 'E') { $filePartNumber = '5' }
                #elseif ($fileP3 -eq 'F') { $filePartNumber = '6' }
                #elseif ($fileP3 -eq 'G') { $filePartNumber = '7' }
                #elseif ($fileP3 -eq 'H') { $filePartNumber = '8' }
                #elseif ($fileP3 -eq 'I') { $filePartNumber = '9' }
            }
            # Match ID-###-A, ID-###-B, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-][a-dA-D]") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $fileP3 = $fileP3 -replace '-', ''
                if ($fileP3 -eq 'A') { $filePartNumber = '1' }
                elseif ($fileP3 -eq 'B') { $filePartNumber = '2' }
                elseif ($fileP3 -eq 'C') { $filePartNumber = '3' }
                elseif ($fileP3 -eq 'D') { $filePartNumber = '4' }
                #elseif ($fileP3 -eq 'E') { $filePartNumber = '5' }
                #elseif ($fileP3 -eq 'F') { $filePartNumber = '6' }
                #elseif ($fileP3 -eq 'G') { $filePartNumber = '7' }
                #elseif ($fileP3 -eq 'H') { $filePartNumber = '8' }
                #elseif ($fileP3 -eq 'I') { $filePartNumber = '9' }
            }
            <#
                #Match ID-###-A, ID-###-B, etc.
                elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-][a-iA-I]$") {
                    Write-JLog -Level Debug -Message "Match 3"
                    $fileP1, $fileP2, $fileP3, $fileP4 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})[-]([a-zA-Z])"
                    $fileBaseNameUpperCleaned += $fileP1 + $fileP2 + $fileP3
                }
                #>
            # Match ID-###-1, ID-###-2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]\d$") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ($fileP3 -replace '-', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-###-01, ID-###-02, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]0\d$") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = (($fileP3 -replace '-', '') -replace '0', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-###-001, ID-###-002, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]00\d$") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = (($fileP3 -replace '-', '') -replace '0', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-### - pt1, ID-### - pt2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6} [-] pt|PT") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ((($fileP3 -replace '-', '') -replace '0', '') -replace 'pt', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-### - part1, ID ### - part2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6} [-] part|PART") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ((($fileP3 -replace '-', '') -replace '0', '') -replace 'pt', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-###-pt1, ID-###-pt2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]pt|PT") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ((($fileP3 -replace '-', '') -replace '0', '') -replace 'pt', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-###-part1, ID-###-part2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]part|PART") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ((($fileP3 -replace '-', '') -replace '0', '') -replace 'pt', '')[1]
                $filePartNumber = $filePartNum
            }
            # Match ID-###-cd1, ID-###-cd2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-]cd|CD") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                $filePartNum = ((($fileP3 -replace '-', '') -replace '0', '') -replace 'cd', '')[1]
                $filePartNumber = $filePartNum
            }

            # Match everything else
            else {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                $fileBaseNameUpperCleaned += $fileP1 + $fileP2
            }
            <#             if ($fileBaseNameUpper[$x] -match '([a-zA-Z|tT28]+-\d+z{0,1}Z{0,1}e{0,1}E{0,1})') {
                $movieId = $fileBaseNameUpper[$x]
                $splitId = $fileBaseNameUpper[$x] -split '-'
                $contentId = $splitId[0] + $splitId[1].PadLeft(5, '0')
            } else {
                $movieId = ($fileBaseNameUpper[$x] -split '\d', 3 | Where-Object { $_ -ne '' }) -join '-'
                $contentId = $fileBaseNameUpper[$x]
            } #>


            if ($fileBaseNameUpper[$x] -match '(([a-zA-Z|tT28|rR18]+)-(\d+z{0,1}Z{0,1}e{0,1}E{0,1}))') {
                $movieId = $fileBaseNameUpperCleaned[$x]
                $splitId = $fileBaseNameUpperCleaned[$x] -split '-'
                $contentId = $splitId[0] + $splitId[1].PadLeft(5, '0')
            } else {
                $movieId = ($fileBaseNameUpperCleaned[$x] -split '\d', 3 | Where-Object { $_ -ne '' }) -join '-'
                $contentId = $fileBaseNameUpperCleaned[$x]
            }


            if ($Files.Count -eq '1') {
                $originalFileName = $Files.Name
                $originalBaseName = $Files.BaseName
                $originalDirectory = $Files.Directory
                $fileExtension = $Files.Extension
                $filePartNumber = $filePartNumber
            } else {
                $originalFileName = $Files.Name[$x]
                $originalBaseName = $Files.BaseName[$x]
                $originalDirectory = $Files.Directory[$x]
                $fileExtension = $Files.Extension[$x]
                $filePartNumber = $filePartNumber
            }

            if ($Strict.IsPresent) {
                $dataObject += [pscustomobject]@{
                    Id                = $originalBaseName
                    ContentId         = $contentId
                    OriginalFileName  = $originalFileName
                    OriginalBaseName  = $originalBaseName
                    OriginalDirectory = $originalDirectory
                    OriginalFullName  = if ($Files.Count -eq 1) { $Files.FullName } else { $Files.fullname[$x] }
                    Extension         = $fileExtension
                    PartNumber        = $filePartNumber
                }
            } else {
                $dataObject += [pscustomobject]@{
                    Id                = $movieId
                    ContentId         = $contentId
                    OriginalFileName  = $originalFileName
                    OriginalBaseName  = $originalBaseName
                    OriginalDirectory = $originalDirectory
                    OriginalFullName  = if ($Files.Count -eq 1) { $Files.FullName } else { $Files.fullname[$x] }
                    Extension         = $fileExtension
                    PartNumber        = $filePartNumber
                }
            }
        }
        Write-Output $dataObject
    }
}
