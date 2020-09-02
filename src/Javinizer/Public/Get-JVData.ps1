#Requires -Modules @{ ModuleName="Logging"; RequiredVersion="4.4.0" }
#Requires -PSEdition Core

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
        [Alias('scraper.movie.javbus')]
        [Boolean]$Javbus,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javbusja')]
        [Boolean]$JavbusJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javbuszh')]
        [Boolean]$JavbusZh,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.jav321')]
        [Boolean]$Jav321,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('javlibrary.baseurl')]
        [String]$JavlibraryBaseUrl = 'http://www.javlibrary.com',

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Id')]
        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Url')]
        [PSObject]$Settings,

        [Parameter(ParameterSetName = 'Url')]
        [PSObject]$Url
    )

    process {
        $javinizerDataObject = @()
        $Id = $Id.ToUpper()

        if ($Url) {
            $urlObject = $Url | Get-JVUrlLocation
        } elseif ($Settings) {
            $R18 = $Settings.'scraper.movie.r18'
            $R18Zh = $Settings.'scraper.movie.r18zh'
            $Jav321 = $Settings.'scraper.movie.jav321'
            $Javlibrary = $Settings.'scraper.movie.javlibrary'
            $JavlibraryJa = $Settings.'scraper.movie.javlibraryja'
            $JavlibraryZh = $Settings.'scraper.movie.javlibraryzh'
            $Dmm = $Settings.'scraper.movie.dmm'
            $Javbus = $Settings.'scraper.movie.javbus'
            $JavbusJa = $Settings.'scraper.movie.javbusja'
            $JavbusZh = $Settings.'scraper.movie.javbuszh'
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

            if ($R18) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - R18] [Url - $R18Url]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-R18" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:R18Url) {
                        $using:R18Url | Get-R18Data
                    } else {
                        Get-R18Url -Id $using:Id -Language en | Get-R18Data
                    }
                } | Out-Null
            }

            if ($R18Zh) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - R18Zh] [Url - $R18ZhUrl]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-R18Zh" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:R18ZhUrl) {
                        $using:R18ZhUrl | Get-R18Data
                    } else {
                        Get-R18Url -Id $using:Id -Language zh | Get-R18Data
                    }
                } | Out-Null
            }

            if ($Javlibrary) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javlibrary] [Url - $JavlibraryUrl]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-Javlibrary" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:JavlibraryUrl) {
                        $using:JavlibraryUrl | Get-JavlibraryData
                    } else {
                        Get-JavlibraryUrl -Id $using:Id -BaseUrl $using:JavlibraryBaseUrl -Language en | Get-JavlibraryData
                    }
                } | Out-Null
            }

            if ($JavlibraryJa) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavlibraryJa] [Url - $JavlibraryJaUrl]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-JavlibraryJa" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:JavlibraryJaUrl) {
                        $using:JavlibraryJaUrl | Get-JavlibraryData
                    } else {
                        Get-JavlibraryUrl -Id $using:Id -BaseUrl $using:JavlibraryBaseUrl -Language ja | Get-JavlibraryData
                    }
                } | Out-Null
            }

            if ($JavlibraryZh) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavlibraryZh] [Url - $JavlibraryZhUrl]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-JavlibraryZh" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:JavlibraryZhUrl) {
                        $using:JavlibraryZhUrl | Get-JavlibraryData
                    } else {
                        Get-JavlibraryUrl -Id $using:Id -BaseUrl $using:JavlibraryBaseUrl -Language zh | Get-JavlibraryData
                    }
                } | Out-Null
            }

            if ($Dmm) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Dmm] [Url - $DmmUrl]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-Dmm" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:DmmUrl) {
                        $using:DmmUrl | Get-DmmData
                    } else {
                        Get-DmmUrl -Id $using:Id | Get-DmmData
                    }
                } | Out-Null
            }

            if ($Javbus) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javbus] [Url - $JavbusUrl]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-Javbus" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:JavbusUrl) {
                        $using:JavbusUrl | Get-JavbusData
                    } else {
                        Get-JavbusUrl -Id $using:Id -Language en | Get-JavbusData
                    }
                } | Out-Null
            }

            if ($JavbusJa) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavbusJa] [Url - $JavbusJaUrl]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-JavbusJa" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:JavbusJaUrl) {
                        $using:JavbusJaUrl | Get-JavbusData
                    } else {
                        Get-JavbusUrl -Id $using:Id -Language ja | Get-JavbusData
                    }
                } | Out-Null
            }

            if ($JavbusZh) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavbusZh] [Url - $JavbusZhUrl]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-JavbusZh" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:JavbusZhUrl) {
                        $using:JavbusZhUrl | Get-JavbusData
                    } else {
                        Get-JavbusUrl -Id $using:Id -Language zh | Get-JavbusData
                    }
                } | Out-Null
            }

            if ($Jav321) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Jav321] [$Url - $Jav321Url]"
                Start-ThreadJob -ThrottleLimit 150 -Name "jvdata-Jav321" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:Jav321Url) {
                        $using:Jav321Url | Get-Jav321Data
                    } else {
                        Get-Jav321Url -Id $using:Id | Get-Jav321Data
                    }
                } | Out-Null
            }

            $jobCount = (Get-Job | Where-Object { $_.Name -like 'jvdata-*' }).Count
            $jobId = @((Get-Job | Where-Object { $_.Name -like "jvdata-*" } | Select-Object Id).Id)
            $jobName = @((Get-Job | Where-Object { $_.Name -like "jvdata-*" } | Select-Object Name).Name)

            if ($jobCount -eq 0) {
                Write-JVLog -Level Warning -Message "[$Id] No scrapers were run"
                return
            } else {
                Write-Debug "[$Id] [$($MyInvocation.MyCommand.Name)] [Waiting - Scraper jobs] [$jobName]"
                # Wait-Job is used separately rather than in a pipeline due to the PowerShell.Exit job that is being created during the first-run of this function
                Wait-Job -Id $jobId

                Write-Debug "[$Id] [$($MyInvocation.MyCommand.Name)] [Completed - Scraper jobs] [$jobName]"
                $javinizerDataObject = Get-Job -Id $jobId | Receive-Job

                $hasData = ($javinizerDataObject | Select-Object Source).Source
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Success - Scraper jobs] [$hasData]"

                $dataObject = [PSCustomObject]@{
                    Data = $javinizerDataObject
                }

                if ($null -ne $javinizerDataObject) {
                    Write-Output $dataObject
                }
            }
        } catch {
            Write-JVLog -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured during scraper jobs: $PSItem"
        } finally {
            # Remove all completed or running jobs before exiting this script
            # If jobs remain after closure, it may cause issues in concurrent runs
            Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Removed - Scraper jobs]"
            Get-Job | Remove-Job -Force
        }
    }
}
