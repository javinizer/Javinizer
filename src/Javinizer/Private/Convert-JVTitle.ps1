function Convert-JVTitle {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PSObject]$Files,

        [Parameter()]
        [Switch]$Strict,

        [Parameter()]
        [Boolean]$RegexEnabled,

        [Parameter()]
        [String]$RegexString,

        [Parameter()]
        [Int]$RegexIdMatch,

        [Parameter()]
        [Int]$RegexPtMatch
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
            '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]',
            '.*\.com\@',
            '.*\.org\@',
            '.*\.xyz\-',
            '[@|-|_]?[a-zA-Z0-9]+(\.com|\.net|\.tk)[_|-]?',
            '^_'
            '^[0-9]{4}',
            '069-3XPLANET-',
            'Watch18plus-',
            '\[(.*?)\]',
            'FHD-',
            'FHD_',
            'fhd',
            'Watch ',
            # Suffixes (obsolete(?))
            '-h264',
            '_4K',
            '\.(?!part|pt|cd).*$',
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
            '\.HD',
            '-HD',
            'wmv',
            '.wmv',
            'avi',
            '.avi',
            'mp4',
            '.mp4',
            '_'
        )

        if ($RegexEnabled) {
            foreach ($file in $FileBaseNameOriginal) {
                $fileBaseNameUpper += $file.ToUpper()
            }

            $index = 0
            foreach ($file in $fileBaseNameUpper) {
                try {
                    $id = ($file | Select-String $RegexString).Matches.Groups[$RegexIdMatch].Value
                    $partNum = ($file | Select-String $RegexString).Matches.Groups[$RegexPtMatch].Value

                    # If ID#### and there's no hypen, subsequent searches will fail
                    <# if ($id -match '^([a-z]+)(\d+)$') {
                        $id = $Matches[1] + "-" + ($Matches[2] -replace '^0{1,5}', '').PadLeft(3, '0')
                    } #>
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "File [$file] not matched by regex"
                    break
                }
                if ($fileBaseNameUpper -eq 1) {
                    if ($partNum -ne '' -and $null -ne $partNum) {
                        $fileBaseNameUpper = "$id-pt$PartNum"
                    } elseif ($id -ne '') {
                        $fileBaseNameUpper = "$id"
                    } else {
                        $fileBaseNameUpper = $file
                    }
                } else {
                    if ($partNum -ne '' -and $null -ne $partNum) {
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
                if ($file -match '([a-zA-Z]?_?\d+)?([a-zA-Z]+\d{3,8})') {
                    # Extract content ID without prefixes if match
                    try {
                        $partNum = ($file | Select-String -Pattern '([a-zA-Z]?_?\d+)?([a-zA-Z]+\d{3,8})(.*)').Matches.Groups[3].Value
                        $file = ($file | Select-String -Pattern '([a-zA-Z]?_?\d+)?([a-zA-Z]+\d{3,8})').Matches.Groups[2].Value + $partNum
                    } catch {
                        # Don't re-assign if match fails
                    }
                }
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

                            # Clean content id values to their dvd id
                            if ($fileBaseNameHyphen -match '((?!-).)*00\d{3,3}') {
                                $fileBaseNameHyphen = ($fileBaseNameHyphen -split '00', 2) -join ''
                            }
                            break
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
            # Match ID-###A, ID###B, etc.
            # Match ID-###-A, ID-###-B, etc.
            # Match ID-### - A, ID-### - B, etc.

            if ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}Z?\s?[-]?\s?[A-Y]$") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6}Z?)"
                $fileBaseNameUpperCleaned += $fileP1 + "-" + (($fileP2 -replace '-', '') -replace '^0{1,5}', '').PadLeft(3, '0')
                $fileP3 = ($fileP3 -replace '-', '').Trim()
                try {
                    $asciiP3 = [int][char]$fileP3
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "Invalid multi-part format for file: [$file]"
                }
                if ($asciiP3 -gt 64 -and $asciiP3 -lt 90) {
                    $filePartNumber = $asciiP3 - 64
                }
            }
            <#
                #Match ID-###-A, ID-###-B, etc.
                elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}[-][a-iA-I]$") {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "Match 3"
                    $fileP1, $fileP2, $fileP3, $fileP4 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})[-]([a-zA-Z])"
                    $fileBaseNameUpperCleaned += $fileP1 + $fileP2 + $fileP3
                }
                #>
            # Match ID-###-1, ID-###-2, etc.
            # Match ID-###-01, ID-###-02, etc.
            # Match ID-###-001, ID-###-002, etc.
            # Match ID-###-pt1, ID-###-pt2, etc.
            # Match ID-### - pt1, ID-### - pt2, etc.
            # Match ID-###-part1, ID-###-part2, etc.
            # Match ID-### - part1, ID ### - part2, etc.
            # Match ID-###-cd1, ID-###-cd2, etc.
            # Match ID-### - cd1, ID-### - cd2, etc.
            elseif ($fileBaseNameUpper[$x] -match "[-][0-9]{1,6}Z?\s?[-|\.]\s?(cd|part|pt)?[-]?\d{1,3}") {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6}Z?\s?[-|\.])"

                if ($fileBaseNameUpper[$x] -match '^0{2,5}') {
                    # If match contentid format: DMM00234-1
                    $fileBaseNameUpperCleaned += $fileP1 + "-" + (($fileP2 -replace '-', '' -replace '\.', '') -replace '^0{1,5}', '').Trim().PadLeft(3, '0')
                } else {
                    # If match dvdid format: DMM-070807-1
                    $fileBaseNameUpperCleaned += $fileP1 + "-" + (($fileP2 -replace '-', '' -replace '\.', '')).Trim()
                }
                $filePartNum = ((($fileP3.Trim() -replace '-', '' -replace '\.', '') -replace '^0{1,5}', '') -replace '(cd|part|pt)', '')
                if ($filePartNum -match '^\d+$') {
                    $filePartNumber = [int]$filePartNum
                }
            }

            elseif ($RegexEnabled) {
                $fileP1, $fileP2 = $fileBaseNameUpper[$x] -split "-pt"

                $filePartNum = ((($fileP2 -replace '-', '' -replace '\.', '') -replace '^0{1,5}', '') -replace '(cd|part|pt)', '')
                if ($filePartNum -match '^\d+$') {
                    $filePartNumber = [int]$filePartNum
                    $fileBaseNameUpperCleaned += $fileP1
                } else {
                    $fileBaseNameUpperCleaned += $fileBaseNameUpper[$x]
                }

            }

            # Match everything else
            else {
                $fileP1, $fileP2, $fileP3 = $fileBaseNameUpper[$x] -split "([-][0-9]{1,6})"
                if ($fileP3 -match '^[ZER]') {
                    $fileBaseNameUpperCleaned += $fileP1 + $fileP2 + $fileP3
                } else {
                    $fileBaseNameUpperCleaned += $fileP1 + $fileP2
                }
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
                if (($splitId[1])[-1] -match '\D') {
                    $appendChar = ($splitId[1])[-1]
                    $splitId[1] = $splitId[1] -replace '\D', ''
                }
                $contentId = $splitId[0] + $splitId[1].PadLeft(5, '0') + $appendChar
                $contentId = $contentId.Trim()
            } elseif ($RegexEnabled) {
                $movieId = $fileBaseNameUpperCleaned[$x]
                $contentId = $fileBaseNameUpperCleaned[$x]
            } else {
                $movieId = ($fileBaseNameUpperCleaned[$x] -split '\d', 3 | Where-Object { $_ -ne '' }) -join '-'
                $contentId = $fileBaseNameUpperCleaned[$x]
            }

            if ($Files.Count -eq '1') {
                $originalFileName = $Files.Name
                $originalBaseName = $Files.BaseName
                $originalDirectory = $Files.Directory
                $fileExtension = $Files.Extension
                $filePartNumber = if ($RegexEnabled) { $partNum } else { $filePartNumber }
            } else {
                $originalFileName = $Files.Name[$x]
                $originalBaseName = $Files.BaseName[$x]
                $originalDirectory = $Files.Directory[$x]
                $fileExtension = $Files.Extension[$x]
                $filePartNumber = if ($RegexEnabled) { $partNum } else { $filePartNumber }
            }

            # Turn on strict filematching if the movie does not appear to be a standard DVD Id format
            # This will require less reliance on using -Strict during commandline usage
            if ($movieId -notmatch '([a-zA-Z|tT28]+-\d+[zZ]?[eE]?)' -and $RegexEnabled -eq $false) {
                $Strict = $true
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
                Write-Host "Strict"
            }

            if ($Strict.IsPresent) {
                $dataObject += [PSCustomObject]@{
                    Id         = $originalBaseName
                    ContentId  = $contentId
                    FileName   = $originalFileName
                    BaseName   = $originalBaseName
                    Directory  = $originalDirectory
                    FullName   = if ($Files.Count -eq 1) { $Files.FullName } else { $Files.fullname[$x] }
                    Extension  = $fileExtension
                    Length     = [Math]::Round($Files.Length[$x] / 1MB, 2)
                    PartNumber = $filePartNumber
                }
            } else {
                $dataObject += [PSCustomObject]@{
                    Id         = $movieId
                    ContentId  = $contentId
                    FileName   = $originalFileName
                    BaseName   = $originalBaseName
                    Directory  = $originalDirectory
                    FullName   = if ($Files.Count -eq 1) { $Files.FullName } else { $Files.fullname[$x] }
                    Extension  = $fileExtension
                    Length     = [Math]::Round($Files.Length[$x] / 1MB, 2)
                    PartNumber = $filePartNumber
                }
            }
        }
        Write-Output $dataObject
    }
}
