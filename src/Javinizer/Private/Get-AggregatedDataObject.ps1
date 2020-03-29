function Get-AggregatedDataObject {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [object]$FileDetails,
        [object]$UrlLocation,
        [switch]$R18,
        [switch]$Dmm,
        [switch]$Javlibrary,
        [object]$Settings,
        [string]$Id,
        [string]$ScriptRoot
    )

    begin {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        $actressArray = @()
        $genreArray = @()
    }

    process {
        $actressPriority = Get-MetadataPriority -Settings $Settings -Type 'actress'
        $actressthumburlPriority = Get-MetadataPriority -Settings $Settings -Type 'actressthumburl'
        $alternatetitlePriority = Get-MetadataPriority -Settings $Settings -Type 'alternatetitle'
        $coverurlPriority = Get-MetadataPriority -Settings $Settings -Type 'coverurl'
        $descriptionPriority = Get-MetadataPriority -Settings $Settings -Type 'description'
        $directorPriority = Get-MetadataPriority -Settings $Settings -Type 'director'
        $genrePriority = Get-MetadataPriority -Settings $Settings -Type 'genre'
        $idPriority = Get-MetadataPriority -Settings $Settings -Type 'id'
        $labelPriority = Get-MetadataPriority -Settings $Settings -Type 'label'
        $runtimePriority = Get-MetadataPriority -Settings $Settings -Type 'runtime'
        $makerPriority = Get-MetadataPriority -Settings $Settings -Type 'maker'
        $ratingPriority = Get-MetadataPriority -Settings $Settings -Type 'rating'
        $ratingcountPriority = Get-MetadataPriority -Settings $Settings -type 'ratingcount'
        $releasedatePriority = Get-MetadataPriority -Settings $Settings -Type 'releasedate'
        $releaseyearPriority = Get-MetadataPriority -Settings $Settings -Type 'releaseyear'
        $seriesPriority = Get-MetadataPriority -Settings $Settings -Type 'series'
        $screenshoturlPriority = Get-MetadataPriority -Settings $Settings -Type 'screenshoturl'
        $titlePriority = Get-MetadataPriority -Settings $Settings -Type 'title'
        $trailerurlPriority = Get-MetadataPriority -Settings $Settings -Type 'trailerurl'

        if (-not ($PSBoundParameters.ContainsKey('r18')) -and `
            (-not ($PSBoundParameters.ContainsKey('dmm')) -and `
                (-not ($PSBoundParameters.ContainsKey('javlibrary')) -and `
                    (-not ($PSBoundParameters.ContainsKey('7mmtv')))))) {
            if ($settings.Main.'scrape-r18' -eq 'true') { $R18 = $true }
            if ($settings.Main.'scrape-dmm' -eq 'true') { $Dmm = $true }
            if ($settings.Main.'scrape-javlibrary' -eq 'true') { $Javlibrary = $true }
            if ($settings.Main.'scrape-7mmtv' -eq 'true') { $7mmtv = $true }
        }

        if ($UrlLocation) {
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Type: [UrlLocation]"
            $currentSearch = $UrlLocation.Url
            foreach ($url in $UrlLocation) {
                if ($url.Result -contains 'r18') {
                    $r18Data = Get-R18DataObject -Url $url.Url
                }

                if ($url.Result -contains 'dmm') {
                    $dmmData = Get-DmmDataObject -Url $url.Url
                }

                if ($url.Result -contains 'javlibrary') {
                    $javlibraryData = Get-JavlibraryDataObject -Url $url.Url -ScriptRoot $ScriptRoot
                }
            }
        } elseif ($FileDetails) {
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Type: [FileDetails]"
            $currentSearch = $FileDetails.Id
            if ($r18.IsPresent) {
                $r18Data = Get-R18DataObject -Name $fileDetails.Id -AltName $fileDetails.ContentId
            }

            if ($dmm.IsPresent) {
                $dmmData = Get-DmmDataObject -Name $fileDetails.Id  -AltName $fileDetails.ContentId
            }

            if ($javlibrary.IsPresent) {
                $javlibraryData = Get-JavlibraryDataObject -Name $fileDetails.Id -ScriptRoot $ScriptRoot
            }
        } elseif ($PSBoundParameters.ContainsKey('Id')) {
            Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Type: [Id]"
            $currentSearch = $Id
            if ($r18.IsPresent) {
                $r18Data = Get-R18DataObject -Name $Id
            }

            if ($dmm.IsPresent) {
                $dmmData = Get-DmmDataObject -Name $Id
            }

            if ($javlibrary.IsPresent) {
                $javlibraryData = Get-JavlibraryDataObject -Name $Id -ScriptRoot $ScriptRoot
            }
        }

        $aggregatedDataObject = [pscustomobject]@{
            Search               = $null
            Id                   = $null
            Title                = $null
            AlternateTitle       = $null
            Description          = $null
            ReleaseDate          = $null
            ReleaseYear          = $null
            Runtime              = $null
            Director             = $null
            Maker                = $null
            Label                = $null
            Series               = $null
            Rating               = $null
            RatingCount          = $null
            Actress              = $null
            Genre                = $null
            ActressThumbUrl      = $null
            CoverUrl             = $null
            ScreenshotUrl        = $null
            TrailerUrl           = $null
            DisplayName          = $null
            FolderName           = $null
            ScreenshotFolderName = $null
            ScreenshotImgName    = $null
            ActorImgFolderName   = $null
            FileName             = $null
            PosterName           = $null
            ThumbnailName        = $null
            TrailerName          = $null
            NfoName              = $null
            OriginalFileName     = $null
            OriginalDirectory    = $null
            PartNumber           = $null
        }

        # TODO: Confirm compatibility with find command with individual sources specified
        foreach ($priority in $actressPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Actress -or $null -eq $aggregatedDataObject.Actress[0]) {
                foreach ($actress in $var.Value.Actress) {
                    # Remove secondary actress names
                    $cleanActressName = ($actress -replace ' ?\((.*)\) ?', '') -replace '  ?\（(.*)）\ ?', ''
                    if ($Settings.Metadata.'first-last-name-order' -eq 'True') {
                        if ($var.Value.Source -eq 'javlibrary') {
                            $temp = $cleanActressName.split(' ')
                            if ($temp[1].length -ne 0) {
                                $lastName, $firstName = $cleanActressName.split(' ')
                                $actressArray += ($firstName + ' ' + $lastName).Trim()
                            } else {
                                $actressArray += $cleanActressName.Trim()
                            }
                        } elseif ($var.Value.Source -eq 'r18') {
                            $actressArray += $cleanActressName.Trim()
                        } else {
                            $actressArray += $cleanActressName.Trim()
                        }
                    } else {
                        if ($var.Value.Source -eq 'javlibrary') {
                            $actressArray += $cleanActressName
                        } elseif ($var.Value.Source -eq 'r18') {
                            $temp = $cleanActressName.split(' ')
                            if ($temp[1].length -ne 0) {
                                $firstName, $lastName = $cleanActressName.split(' ')
                                $actressArray += ($lastName + ' ' + $firstName).Trim()
                            } else {
                                $actressArray += $cleanActressName.Trim()
                            }
                        } else {
                            $actressArray += $cleanActressName.Trim()
                        }
                    }
                }
                #if ($actressArray.Count -eq 0) {
                #    $actressArray = $null
                #}
                $aggregatedDataObject.Actress = $actressArray
            }
        }

        foreach ($priority in $actressthumburlPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($actressPriority.Count -gt 1) {
                if ($actressPriority[0] -eq 'javlibrary') {
                    if ($null -ne $javlibraryData.Actress) {
                        $aggregatedDataObject.ActressThumbUrl = $null
                    } else {
                        if ($null -ne $r18Data.Actress) {
                            if ($null -eq $aggregatedDataObject.ActressThumbUrl -or $null -eq $aggregatedDataObject.ActressThumbUrl[0]) {
                                $aggregatedDataObject.ActressThumbUrl = $var.Value.ActressThumbUrl
                            }
                        }
                    }
                } else {
                    if ($null -eq $aggregatedDataObject.ActressThumbUrl -or $null -eq $aggregatedDataObject.ActressThumbUrl[0]) {
                        $aggregatedDataObject.ActressThumbUrl = $var.Value.ActressThumbUrl
                    }
                }
            } else {
                if ($actressPriority -eq 'javlibrary') {
                    if ($null -ne $javlibraryData.Actress) {
                        $aggregatedDataObject.ActressThumbUrl = $null
                    } else {
                        if ($null -ne $r18Data.Actress) {
                            if ($null -eq $aggregatedDataObject.ActressThumbUrl -or $null -eq $aggregatedDataObject.ActressThumbUrl[0]) {
                                $aggregatedDataObject.ActressThumbUrl = $var.Value.ActressThumbUrl
                            }
                        }
                    }
                } else {
                    if ($null -eq $aggregatedDataObject.ActressThumbUrl -or $null -eq $aggregatedDataObject.ActressThumbUrl[0]) {
                        $aggregatedDataObject.ActressThumbUrl = $var.Value.ActressThumbUrl
                    }
                }
            }
        }

        foreach ($priority in $alternatetitlePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.AlternateTitle) {
                $aggregatedDataObject.AlternateTitle = $var.Value.Title
            }
        }

        foreach ($priority in $coverurlPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.CoverUrl) {
                $aggregatedDataObject.CoverUrl = $var.Value.CoverUrl
            }
        }

        foreach ($priority in $descriptionPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Description -or $null -eq $aggregatedDataObject.Description[0]) {
                $description = ((((($var.Value.Description -replace '♪', '') -replace '●', '') -replace '…', '') -replace '』', '') -replace '『', '') -replace '・', ''
                if ($Settings.Metadata.'translate-description' -eq 'true' -and $null -ne $var.Value.Description) {
                    $translatedDescription = Get-TranslatedString $description -ScriptRoot $ScriptRoot
                    $aggregatedDataObject.Description = $translatedDescription
                } else {
                    $aggregatedDataObject.Description = $description
                }

                # Fall back to default description if translation fails
                if ($null -eq $aggregatedDataObject.Description) {
                    $aggregatedDataObject.Description = $description
                }
            }
        }

        foreach ($priority in $directorPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Director) {
                $aggregatedDataObject.Director = $var.Value.Director
            }
        }

        foreach ($priority in $genrePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Genre -or $null -eq $aggregatedDataObject.Genre[0]) {
                $ignoredGenres = Convert-CommaDelimitedString -String $Settings.Metadata.'ignored-genres'
                Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Ignored genres: [$ignoredGenres]"
                foreach ($genre in $var.Value.Genre) {
                    if ($ignoredGenres -notcontains $genre) {
                        $genreArray += $genre
                    }
                }
                $aggregatedDataObject.Genre = $genreArray
            }

            if ($aggregatedDataObject.Genre.Count -eq 0) {
                $aggregatedDataObject.Genre = $null
            }
        }

        foreach ($priority in $idPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Id) {
                $aggregatedDataObject.Id = $var.Value.Id
            }
        }

        foreach ($priority in $labelPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Label) {
                $aggregatedDataObject.Label = $var.Value.Label
            }
        }

        foreach ($priority in $runtimePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Runtime) {
                $aggregatedDataObject.Runtime = $var.Value.Runtime
            }
        }

        foreach ($priority in $makerPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Maker) {
                $aggregatedDataObject.Maker = $var.Value.Maker
            }
        }

        foreach ($priority in $titlePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Title) {
                $aggregatedDataObject.Title = $var.Value.Title
            }
        }

        foreach ($priority in $ratingPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Rating) {
                if ($aggregatedDataObject.Rating -eq '0') {
                    $aggregatedDataObject.Rating = $null
                } else {
                    $aggregatedDataObject.Rating = $var.Value.Rating
                }
            }
        }

        foreach ($priority in $ratingcountPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.RatingCount) {
                if ($aggregatedDataObject.RatingCount -eq '0') {
                    $aggregatedDataObject.RatingCount = $null
                } else {
                    $aggregatedDataObject.RatingCount = $var.Value.RatingCount
                }
            }
        }

        foreach ($priority in $releasedatePriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.ReleaseDate) {
                $aggregatedDataObject.ReleaseDate = $var.Value.Date
            }
        }

        foreach ($priority in $releaseyearPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.ReleaseYear) {
                $aggregatedDataObject.ReleaseYear = $var.Value.Year
            }
        }

        foreach ($priority in $seriesPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Series) {
                $aggregatedDataObject.Series = $var.Value.Series
            }
        }

        foreach ($priority in $screenshoturlPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.ScreenshotUrl -or $null -eq $aggregatedDataObject.ScreenshotUrl[0]) {
                $aggregatedDataObject.ScreenshotUrl = $var.Value.ScreenshotUrl
            }
        }

        foreach ($priority in $trailerurlPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.TrailerUrl -or $null -eq $aggregatedDataObject.TrailerUrl[0]) {
                if ($var.Value.TrailerUrl.Count -gt 1) {
                    if ($var.Value.TrailerUrl -match '_dmb') {
                        $aggregatedDataObject.TrailerUrl = ($var.Value.TrailerUrl -match '_dmb_')
                    } elseif ($var.Value.TrailerUrl -match '_dm_') {
                        $aggregatedDataObject.TrailerUrl = ($var.Value.TrailerUrl -match '_dm_')
                    } elseif ($var.Value.TrailerUrl -match '_sm_') {
                        $aggregatedDataObject.TrailerUrl = ($var.Value.TrailerUrl -match '_sm_')
                    }
                } else {
                    $aggregatedDataObject.TrailerUrl = $var.Value.TrailerUrl
                }
            }
        }

        # Set part number for video before creating new filename
        $aggregatedDataObject.PartNumber = $FileDetails.PartNumber
        $aggregatedDataObject.OriginalDirectory = $FileDetails.OriginalDirectory

        $fileDirName = Get-NewFileDirName -DataObject $aggregatedDataObject -Settings $Settings
        $aggregatedDataObject.FileName = $fileDirName.FileName
        $aggregatedDataObject.OriginalFileName = $fileDirName.OriginalFileName
        $aggregatedDataObject.FolderName = $fileDirName.FolderName
        $aggregatedDataObject.ScreenshotFolderName = $fileDirName.ScreenshotFolderName
        $aggregatedDataObject.ScreenshotImgName = $fileDirName.ScreenshotImgName
        $aggregatedDataObject.ActorImgFolderName = $fileDirName.ActorImgFolderName
        $aggregatedDataObject.DisplayName = $fileDirName.DisplayName
        $aggregatedDataObject.PosterName = $fileDirName.PosterName
        $aggregatedDataObject.ThumbnailName = $fileDirName.ThumbnailName
        $aggregatedDataObject.TrailerName = $fileDirName.TrailerName
        $aggregatedDataObject.NfoName = $fileDirName.NfoName
        $aggregatedDataObject.Search = $currentSearch

        Write-Output $aggregatedDataObject
        $aggregatedDataObject | Out-String | Write-Debug
    }

    end {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
