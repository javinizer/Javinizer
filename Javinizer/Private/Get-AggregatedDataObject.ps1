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
        [string]$Id
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
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
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Type: [UrlLocation]"
            $currentSearch = $UrlLocation.Url
            foreach ($url in $UrlLocation) {
                if ($url.Result -contains 'r18') {
                    $r18Data = Get-R18DataObject -Url $url.Url
                }

                if ($url.Result -contains 'dmm') {
                    $dmmData = Get-DmmDataObject -Url $url.Url
                }

                if ($url.Result -contains 'javlibrary') {
                    $javlibraryData = Get-JavlibraryDataObject -Url $url.Url
                }
            }
        } elseif ($FileDetails) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Type: [FileDetails]"
            $currentSearch = $FileDetails.Id
            if ($r18.IsPresent) {
                $r18Data = Get-R18DataObject -Name $fileDetails.Id
            }

            if ($dmm.IsPresent) {
                $dmmData = Get-DmmDataObject -Name $fileDetails.Id
            }

            if ($javlibrary.IsPresent) {
                $javlibraryData = Get-JavlibraryDataObject -Name $fileDetails.Id
            }
        } elseif ($PSBoundParameters.ContainsKey('Id')) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Type: [Id]"
            $currentSearch = $Id
            if ($r18.IsPresent) {
                $r18Data = Get-R18DataObject -Name $Id
            }

            if ($dmm.IsPresent) {
                $dmmData = Get-DmmDataObject -Name $Id
            }

            if ($javlibrary.IsPresent) {
                $javlibraryData = Get-JavlibraryDataObject -Name $Id
            }
        }

        $aggregatedDataObject = [pscustomobject]@{
            Search           = $null
            Id               = $null
            Title            = $null
            AlternateTitle   = $null
            Description      = $null
            ReleaseDate      = $null
            ReleaseYear      = $null
            Runtime          = $null
            Director         = $null
            Maker            = $null
            Label            = $null
            Series           = $null
            Rating           = $null
            RatingCount      = $null
            Actress          = $null
            Genre            = $null
            ActressThumbUrl  = $null
            CoverUrl         = $null
            ScreenshotUrl    = $null
            TrailerUrl       = $null
            DisplayName      = $null
            FolderName       = $null
            FileName         = $null
            OriginalFileName = $null
            PartNumber       = $null
        }

        foreach ($priority in $actressPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.Actress) {
                foreach ($actress in $var.Value.Actress) {
                    # Remove secondary actress names
                    $cleanActressName = $actress -replace ' ?\((.*)\) ?', ''
                    if ($Settings.Metadata.'first-last-name-order' -eq 'True') {
                        if ($var.Value.Source -eq 'javlibrary') {
                            $temp = $cleanActressName.split(' ')
                            if ($temp[1].length -ne 0) {
                                $lastName, $firstName = $cleanActressName.split(' ')
                                $actressArray += "$firstName $lastName"
                            } else {
                                $actressArray += $cleanActressName.Trim()
                            }
                        } elseif ($var.Value.Source -eq 'r18') {
                            $actressArray += $cleanActressName
                        } else {
                            $actressArray += $cleanActressName
                        }
                    } else {
                        if ($var.Value.Source -eq 'javlibrary') {
                            $actressArray += $cleanActressName
                        } elseif ($var.Value.Source -eq 'r18') {
                            $temp = $cleanActressName.split(' ')
                            if ($temp[1].length -ne 0) {
                                $firstName, $lastName = $cleanActressName.split(' ')
                                $actressArray += "$lastName $firstName"
                            } else {
                                $actressArray += $actress.Trim()
                            }
                        }
                    }
                }
                $aggregatedDataObject.Actress = $actressArray
            }
        }

        foreach ($priority in $actressthumburlPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.ActressThumbUrl) {
                $aggregatedDataObject.ActressThumbUrl = $var.Value.ActressThumbUrl
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
            if ($null -eq $aggregatedDataObject.Description) {
                if ($Settings.Metadata.'translate-description' -eq 'true' -and $null -ne $var.Value.Description) {
                    $translatedDescription = Get-TranslatedString $var.Value.Description
                    $aggregatedDataObject.Description = $translatedDescription
                } else {
                    $aggregatedDataObject.Description = $var.Value.Description
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
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Ignored genres: [$ignoredGenres]"
                foreach ($genre in $var.Value.Genre) {
                    if ($ignoredGenres -notcontains $genre) {
                        $genreArray += $genre
                    }
                }
                $aggregatedDataObject.Genre = $genreArray
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
            if ($null -eq $aggregatedDataObject.ScreenshotUrl) {
                $aggregatedDataObject.ScreenshotUrl = $var.Value.ScreenshotUrl
            }
        }

        foreach ($priority in $trailerurlPriority) {
            $var = Get-Variable -Name "$($priority)Data"
            if ($null -eq $aggregatedDataObject.TrailerUrl) {
                if ($var.Value.TrailerUrl.Count -gt 1) {
                    if ($null -ne ($var.Value.TrailerUrl | Select-String -Pattern '_dmb_')) {
                        $aggregatedDataObject.TrailerUrl = ($var.Value.TrailerUrl | Select-String -Pattern '_dmb_')
                    } elseif ($null -ne ($var.Value.TrailerUrl | Select-String -Pattern '_dm_')) {
                        $aggregatedDataObject.TrailerUrl = ($var.Value.TrailerUrl | Select-String -Pattern '_dm_')
                    } elseif (($null -ne ($var.Value.TrailerUrl | Select-String -Pattern '_sm_'))) {
                        $aggregatedDataObject.TrailerUrl = ($var.Value.TrailerUrl | Select-String -Pattern '_sm_')
                    }
                } else {
                    $aggregatedDataObject.TrailerUrl = $var.Value.TrailerUrl
                }
            }
        }

        # Set part number for video before creating new filename
        $aggregatedDataObject.PartNumber = $FileDetails.PartNumber

        $fileDirName = Get-NewFileDirName -DataObject $aggregatedDataObject
        $aggregatedDataObject.FileName = $fileDirName.FileName
        $aggregatedDataObject.OriginalFileName = $fileDirName.OriginalFileName
        $aggregatedDataObject.FolderName = $fileDirName.FolderName
        $aggregatedDataObject.DisplayName = $fileDirName.DisplayName
        $aggregatedDataObject.Search = $currentSearch

        Write-Output $aggregatedDataObject
        $aggregatedDataObject | Out-String | Write-Debug
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
