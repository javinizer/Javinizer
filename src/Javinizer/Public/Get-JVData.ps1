function Get-JVData {
    [CmdletBinding(DefaultParameterSetName = 'Id')]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [String]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.r18')]
        [Boolean]$R18,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.r18zh')]
        [Boolean]$R18Zh,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javlibrary')]
        [Boolean]$Javlibrary,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javlibraryja')]
        [Boolean]$JavlibraryJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javlibraryzh')]
        [Boolean]$JavlibraryZh,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.dmm')]
        [Boolean]$Dmm,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.dmmja')]
        [Boolean]$DmmJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javbus')]
        [Boolean]$Javbus,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javbusja')]
        [Boolean]$JavbusJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javbuszh')]
        [Boolean]$JavbusZh,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javdb')]
        [Boolean]$Javdb,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javdbzh')]
        [Boolean]$JavdbZh,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.jav321ja')]
        [Boolean]$Jav321Ja,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.dlgetchuja')]
        [Boolean]$DLgetchuJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.mgstageja')]
        [Boolean]$MgstageJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.aventertainment')]
        [Boolean]$Aventertainment,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.aventertainmentja')]
        [Boolean]$AventertainmentJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.tokyohot')]
        [Boolean]$Tokyohot,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.tokyohotja')]
        [Boolean]$TokyohotJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.tokyohotzh')]
        [Boolean]$TokyohotZh,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('javlibrary.baseurl')]
        [String]$JavlibraryBaseUrl = 'https://www.javlibrary.com',

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.option.dmm.scrapeactress')]
        [Boolean]$DmmScrapeActress,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Url')]
        [Alias('location.uncensorcsv')]
        [System.IO.FileInfo]$UncensorCsvPath = (Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'jvUncensor.csv'),

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Id')]
        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Url')]
        [PSObject]$Settings,

        [Parameter(ParameterSetName = 'Url')]
        [PSObject]$Url,

        [Parameter(ParameterSetName = 'Id')]
        [Switch]$Strict,

        [Parameter(ParameterSetName = 'Id')]
        [Switch]$AllResults,

        [Parameter(ParameterSetName = 'Url')]
        [Parameter(ParameterSetName = 'Id')]
        [PSObject]$Session,

        [Parameter(ParameterSetName = 'Url')]
        [Parameter(ParameterSetName = 'Id')]
        [PSObject]$JavdbSession
    )

    process {
        if ($PSVersionTable.PSVersion.Major -eq 6) {
            $throttleLimit = 50
        } else {
            $throttleLimit = 100
        }
        $ProgressPreference = 'SilentlyContinue'
        $javinizerDataObject = @()
        $Id = $Id.ToUpper()

        if ($Url) {
            $urlObject = $Url | Get-JVUrlLocation -Settings $Settings
        } elseif ($Settings) {
            $R18 = $Settings.'scraper.movie.r18'
            $R18Zh = $Settings.'scraper.movie.r18zh'
            $Jav321Ja = $Settings.'scraper.movie.jav321ja'
            $Javlibrary = $Settings.'scraper.movie.javlibrary'
            $JavlibraryJa = $Settings.'scraper.movie.javlibraryja'
            $JavlibraryZh = $Settings.'scraper.movie.javlibraryzh'
            $Tokyohot = $Settings.'scraper.movie.tokyohot'
            $TokyohotJa = $Settings.'scraper.movie.tokyohotja'
            $TokyohotZh = $Settings.'scraper.movie.tokyohotzh'
            $Dmm = $Settings.'scraper.movie.dmm'
            $DmmJa = $Settings.'scraper.movie.dmmja'
            $Javbus = $Settings.'scraper.movie.javbus'
            $JavbusJa = $Settings.'scraper.movie.javbusja'
            $JavbusZh = $Settings.'scraper.movie.javbuszh'
            $Javdb = $Settings.'scraper.movie.javdb'
            $JavdbZh = $Settings.'scraper.movie.javdbzh'
            $MgstageJa = $Settings.'scraper.movie.mgstageja'
            $Aventertainment = $Settings.'scraper.movie.aventertainment'
            $AventertainmentJa = $Settings.'scraper.movie.aventertainmentja'
            $DmmScrapeActress = $Settings.'scraper.option.dmm.scrapeactress'
            if ($Settings.'location.uncensorcsv' -ne '') {
                $UncensorCsvPath = $Settings.'location.uncensorcsv'
            }
        }

        if ($Settings) {
            $JavlibraryBaseUrl = $Settings.'javlibrary.baseurl'
        }

        if ($JavlibraryBaseUrl[-1] -eq '/') {
            # Remove the trailing slash if it is included to create the valid searchUrl
            $JavlibraryBaseUrl = $JavlibraryBaseUrl[0..($JavlibraryBaseUrl.Length - 1)] -join ''
        }

        try {
            # You need to change this path if you're running the script from outside of the Javinizer module folder
            $jvModulePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'Javinizer.psm1'

            foreach ($item in $urlObject) {
                Set-Variable -Name "$($item.Source)" -Value $true
                Set-Variable -Name "$($item.Source)Url" -Value $item.Url
            }

            if ($Dmm -or $DmmJa) {
                if ($Dmm) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Dmm] [Url - $DmmUrl]"
                    Start-ThreadJob -Name "jvdata-Dmm" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:DmmUrl)) {
                            $jvDmmUrl = Get-DmmUrl -Id $using:Id -Strict:$using:Strict -AllResults:$using:Allresults
                        }
                        if ($using:DmmUrl) {
                            $using:DmmUrl | Get-DmmData -ScrapeActress:$using:DmmScrapeActress
                        } elseif ($jvDmmUrl) {
                            $jvDmmUrl.En | Get-DmmData -ScrapeActress:$using:DmmScrapeActress
                        }
                    } | Out-Null
                }

                if ($DmmJa) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - DmmJa] [Url - $DmmJaUrl]"
                    Start-ThreadJob -Name "jvdata-DmmJa" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:DmmJaUrl)) {
                            $jvDmmUrl = Get-DmmUrl -Id $using:Id -Strict:$using:Strict -AllResults:$using:Allresults
                        }
                        if ($using:DmmJaUrl) {
                            $using:DmmJaUrl | Get-DmmData -ScrapeActress:$using:DmmScrapeActress
                        } elseif ($jvDmmUrl) {
                            $jvDmmUrl.Ja | Get-DmmData -ScrapeActress:$using:DmmScrapeActress
                        }
                    } | Out-Null
                }
            }

            if ($Aventertainment -or $AventertainmentJa) {
                if ($Aventertainment) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Aventertainment] [Url - $AventertainmentUrl]"
                    Start-ThreadJob -Name "jvdata-Aventertainment" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:AventertainmentUrl)) {
                            $jvAventertainmentUrl = Get-AventertainmentUrl -Id $using:Id
                        }
                        if ($using:AventertainmentUrl) {
                            $using:AventertainmentUrl | Get-AventertainmentData
                        } elseif ($jvAventertainmentUrl) {
                            $jvAventertainmentUrl.En | Get-AventertainmentData
                        }
                    } | Out-Null
                }

                if ($AventertainmentJa) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - AventertainmentJa] [Url - $AventertainmentJaUrl]"
                    Start-ThreadJob -Name "jvdata-AventertainmentJa" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:AventertainmentJaUrl)) {
                            $jvAventertainmentUrl = Get-AventertainmentUrl -Id $using:Id
                        }
                        if ($using:AventertainmentJaUrl) {
                            $using:AventertainmentJaUrl | Get-AventertainmentData
                        } elseif ($jvAventertainmentUrl) {
                            $jvAventertainmentUrl.Ja | Get-AventertainmentData
                        }
                    } | Out-Null
                }
            }

            if ($R18 -or $R18Zh) {
                if ($R18) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - R18] [Url - $R18Url]"
                    Start-ThreadJob -Name "jvdata-R18" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:R18Url)) {
                            $jvR18Url = Get-R18Url -Id $using:Id -Strict:$using:Strict -AllResults:$using:Allresults
                        }
                        if ($using:R18Url) {
                            $using:R18Url | Get-R18Data -UncensorCsvPath:$using:UncensorCsvPath
                        } elseif ($jvR18Url) {
                            if ($jvR18Url) {
                                $jvR18Url.En | Get-R18Data -UncensorCsvPath:$using:UncensorCsvPath
                            }
                        }
                    } | Out-Null
                }

                if ($R18Zh) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - R18Zh] [Url - $R18ZhUrl]"
                    Start-ThreadJob -Name "jvdata-R18Zh" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:R18ZhUrl)) {
                            $jvR18Url = Get-R18Url -Id $using:Id -Strict:$using:Strict -AllResults:$using:Allresults
                        }
                        if ($using:R18ZhUrl) {
                            $using:R18ZhUrl | Get-R18Data -UncensorCsvPath:$using:UncensorCsvPath
                        } elseif ($jvR18Url) {
                            if ($jvR18Url) {
                                $jvR18Url.Zh | Get-R18Data -UncensorCsvPath:$using:UncensorCsvPath
                            }
                        }
                    } | Out-Null
                }
            }

            if ($Javlibrary -or $JavlibraryJa -or $JavlibraryZh) {
                if ($Javlibrary) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javlibrary] [Url - $JavlibraryUrl]"
                    Start-ThreadJob -Name "jvdata-Javlibrary" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:JavlibraryUrl)) {
                            $jvJavlibraryUrl = Get-JavlibraryUrl -Id $using:Id -BaseUrl $using:JavlibraryBaseUrl -Session:$using:Session -AllResults:$using:Allresults
                        }
                        if ($using:JavlibraryUrl) {
                            $using:JavlibraryUrl | Get-JavlibraryData -JavlibraryBaseUrl $using:JavlibraryBaseUrl -Session:$using:Session
                        } elseif ($jvJavlibraryUrl) {
                            if ($jvJavlibraryUrl) {
                                $jvJavlibraryUrl.En | Get-JavlibraryData -JavlibraryBaseUrl $using:JavlibraryBaseUrl -Session:$using:Session
                            }
                        }
                    } | Out-Null
                }

                if ($JavlibraryJa) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavlibraryJa] [Url - $JavlibraryJaUrl]"
                    Start-ThreadJob -Name "jvdata-JavlibraryJa" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:JavlibraryJaUrl)) {
                            $jvJavlibraryUrl = Get-JavlibraryUrl -Id $using:Id -BaseUrl $using:JavlibraryBaseUrl -Session:$using:Session -AllResults:$using:Allresults
                        }
                        if ($using:JavlibraryJaUrl) {
                            $using:JavlibraryJaUrl | Get-JavlibraryData -JavlibraryBaseUrl $using:JavlibraryBaseUrl -Session:$using:Session
                        } elseif ($jvJavlibraryUrl) {
                            if ($jvJavlibraryUrl) {
                                $jvJavlibraryUrl.Ja | Get-JavlibraryData -JavlibraryBaseUrl $using:JavlibraryBaseUrl -Session:$using:Session
                            }
                        }
                    } | Out-Null
                }

                if ($JavlibraryZh) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavlibraryZh] [Url - $JavlibraryZhUrl]"
                    Start-ThreadJob -Name "jvdata-JavlibraryZh" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:JavlibraryZhUrl)) {
                            $jvJavlibraryUrl = Get-JavlibraryUrl -Id $using:Id -BaseUrl $using:JavlibraryBaseUrl -Session:$using:Session -AllResults:$using:Allresults
                        }
                        if ($using:JavlibraryZhUrl) {
                            $using:JavlibraryZhUrl | Get-JavlibraryData -JavlibraryBaseUrl $using:JavlibraryBaseUrl -Session:$using:Session
                        } elseif ($jvJavlibraryUrl) {
                            if ($jvJavlibraryUrl) {
                                $jvJavlibraryUrl.Zh | Get-JavlibraryData -JavlibraryBaseUrl $using:JavlibraryBaseUrl -Session:$using:Session
                            }
                        }
                    } | Out-Null
                }
            }

            if ($Javbus -or $JavbusJa -or $JavbusZh) {
                if ($Javbus) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javbus] [Url - $JavbusUrl]"
                    Start-ThreadJob -Name "jvdata-Javbus" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:JavbusUrl)) {
                            $jvJavbusUrl = Get-JavbusUrl -Id $using:Id -AllResults:$using:Allresults
                        }
                        if ($using:JavbusUrl) {
                            $using:JavbusUrl | Get-JavbusData
                        } elseif ($jvJavbusUrl) {
                            $jvJavbusUrl.En | Get-JavbusData
                        }
                    } | Out-Null
                }

                if ($JavbusJa) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavbusJa] [Url - $JavbusJaUrl]"
                    Start-ThreadJob -Name "jvdata-JavbusJa" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:JavbusJaUrl)) {
                            $jvJavbusUrl = Get-JavbusUrl -Id $using:Id -AllResults:$using:Allresults
                        }
                        if ($using:JavbusJaUrl) {
                            $using:JavbusJaUrl | Get-JavbusData
                        } elseif ($jvJavbusUrl) {
                            $jvJavbusUrl.Ja | Get-JavbusData
                        }
                    } | Out-Null
                }

                if ($JavbusZh) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavbusZh] [Url - $JavbusZhUrl]"
                    Start-ThreadJob -Name "jvdata-JavbusZh" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:JavbusZhUrl)) {
                            $jvJavbusUrl = Get-JavbusUrl -Id $using:Id -AllResults:$using:Allresults
                        }
                        if ($using:JavbusZhUrl) {
                            $using:JavbusZhUrl | Get-JavbusData
                        } elseif ($using:jvJavbusUrl) {
                            $jvJavbusUrl.Zh | Get-JavbusData
                        }
                    } | Out-Null
                }
            }

            if ($Jav321Ja) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Jav321Ja] [Url - $Jav321JaUrl]"
                Start-ThreadJob -Name "jvdata-Jav321" -ThrottleLimit $throttleLimit -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if (!($using:Jav321JaUrl)) {
                        $jvJav321Url = Get-Jav321Url -Id $using:Id -AllResults:$using:Allresults
                    }
                    if ($using:Jav321JaUrl) {
                        $using:Jav321JaUrl | Get-Jav321Data
                    } elseif ($jvJav321Url) {
                        $jvJav321Url.Ja | Get-Jav321Data
                    }
                } | Out-Null
            }

            if ($Javdb -or $JavdbZh) {
                if ($Javdb) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javdb] [Url - $JavdbUrl]"
                    Start-ThreadJob -Name "jvdata-Javdb" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:JavdbUrl)) {
                            $jvJavdbUrl = Get-JavdbUrl -Id $using:Id -Session $using:JavdbSession -AllResults:$using:Allresults
                        }
                        if ($using:JavdbUrl) {
                            $using:JavdbUrl | Get-JavdbData -Session $using:JavdbSession
                        } elseif ($jvJavdbUrl) {
                            if ($jvJavdbUrl) {
                                $jvJavdbUrl.En | Get-JavdbData -Session $using:JavdbSession
                            }
                        }
                    } | Out-Null
                }

                if ($JavdbZh) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavdbZh] [Url - $JavdbZhUrl]"
                    Start-ThreadJob -Name "jvdata-JavdbZh" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:JavdbZhUrl)) {
                            $jvJavdbUrl = Get-JavdbUrl -Id $using:Id -Session $using:JavdbSession -AllResults:$using:Allresults
                        }
                        if ($using:JavdbZhUrl) {
                            $using:JavdbZhUrl | Get-JavdbData -Session $using:JavdbSession
                        } elseif ($jvJavdbUrl) {
                            if ($jvJavdbUrl) {
                                $jvJavdbUrl.Zh | Get-JavdbData -Session $using:JavdbSession
                            }
                        }
                    } | Out-Null
                }
            }

            if ($MgstageJa) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - MgstageJa] [Url - $MgstageJaUrl]"
                Start-ThreadJob -Name "jvdata-MgstageJa" -ThrottleLimit $throttleLimit -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if (!($using:MgstageJaUrl)) {
                        $jvMgstageJaUrl = Get-MgstageUrl -Id $using:Id -AllResults:$using:Allresults
                    }
                    if ($using:MgstageJaUrl) {
                        $using:MgstageJaUrl | Get-MgstageData
                    } elseif ($jvMgstageJaUrl) {
                        $jvMgstageJaUrl.Ja | Get-MgstageData
                    }
                } | Out-Null
            }

            if ($Tokyohot -or $TokyohotJa -or $TokyohotZh) {
                if ($Tokyohot) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javlibrary] [Url - $TokyohotUrl]"
                    Start-ThreadJob -Name "jvdata-Tokyohot" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:TokyohotUrl)) {
                            $jvTokyohotUrl = Get-TokyohotUrl -Id $using:Id -AllResults:$using:Allresults
                        }
                        if ($using:TokyohotUrl) {
                            $using:TokyohotUrl | Get-TokyohotData
                        } elseif ($jvTokyohotUrl) {
                            if ($jvTokyohotUrl) {
                                $jvTokyohotUrl.En | Get-TokyohotData
                            }
                        }
                    } | Out-Null
                }

                if ($TokyohotJa) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - TokyohotJa] [Url - $TokyohotJaUrl]"
                    Start-ThreadJob -Name "jvdata-TokyohotJa" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:TokyohotJaUrl)) {
                            $jvTokyohotUrl = Get-TokyohotUrl -Id $using:Id -AllResults:$using:Allresults
                        }
                        if ($using:TokyohotJaUrl) {
                            $using:TokyohotJaUrl | Get-TokyohotData
                        } elseif ($jvTokyohotUrl) {
                            if ($jvTokyohotUrl) {
                                $jvTokyohotUrl.Ja | Get-TokyohotData
                            }
                        }
                    } | Out-Null
                }

                if ($TokyohotZh) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - TokyohotZh] [Url - $TokyohotZhUrl]"
                    Start-ThreadJob -Name "jvdata-TokyohotZh" -ThrottleLimit $throttleLimit -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if (!($using:TokyohotZhUrl)) {
                            $jvTokyohotUrl = Get-TokyohotUrl -Id $using:Id -AllResults:$using:Allresults
                        }
                        if ($using:TokyohotZhUrl) {
                            $using:TokyohotZhUrl | Get-TokyohotData
                        } elseif ($jvTokyohotUrl) {
                            if ($jvTokyohotUrl) {
                                $jvTokyohotUrl.Zh | Get-TokyohotData
                            }
                        }
                    } | Out-Null
                }
            }

            if ($DLgetchuJa) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - DLgetchuJa] [Url - $DLgetchuJaUrl]"
                Start-ThreadJob -Name "jvdata-DLgetchuJa" -ThrottleLimit $throttleLimit -ScriptBlock {
                    Import-Module $using:jvModulePath
                    $using:DLgetchuJaUrl | Get-DLgetchuData
                } | Out-Null
            }

            $jobCount = (Get-Job | Where-Object { $_.Name -like 'jvdata-*' }).Count
            $jobId = @((Get-Job | Where-Object { $_.Name -like "jvdata-*" } | Select-Object Id).Id)
            $jobName = @((Get-Job | Where-Object { $_.Name -like "jvdata-*" } | Select-Object Name).Name)

            if ($jobCount -eq 0) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] [$($MyInvocation.MyCommand.Name)] No scrapers were run"
                return
            } else {
                Write-Debug "[$Id] [$($MyInvocation.MyCommand.Name)] [Waiting - Scraper jobs] [$jobName]"
                # Wait-Job is used separately rather than in a pipeline due to the PowerShell.Exit job that is being created during the first-run of this function
                Wait-Job -Id $jobId | Out-Null

                Write-Debug "[$Id] [$($MyInvocation.MyCommand.Name)] [Completed - Scraper jobs] [$jobName]"
                $javinizerDataObject = Get-Job -Id $jobId | Receive-Job

                $hasData = ($javinizerDataObject | Select-Object Source).Source
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Success - Scraper jobs] [$hasData]"

                $dataObject = [PSCustomObject]@{
                    Data = $javinizerDataObject
                }

                if ($null -ne $javinizerDataObject) {
                    Write-Output $dataObject
                }
            }
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured during scraper jobs: $PSItem"
        } finally {
            # Remove all completed or running jobs before exiting this script
            # If jobs remain after closure, it may cause issues in concurrent runs
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Removed - Scraper jobs]"
            Get-Job | Remove-Job -Force
        }
    }
}
