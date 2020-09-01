function Get-JVData {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [String]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.r18')]
        [Boolean]$R18,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.r18zh')]
        [Boolean]$R18Zh,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.javlibrary')]
        [Boolean]$Javlibrary,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.javlibraryja')]
        [Boolean]$JavlibraryJa,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.javlibraryzh')]
        [Boolean]$JavlibraryZh,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.dmm')]
        [Boolean]$Dmm,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.javbus')]
        [Boolean]$Javbus,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.javbusja')]
        [Boolean]$JavbusJa,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.javbuszh')]
        [Boolean]$JavbusZh,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('scraper.movie.jav321')]
        [Boolean]$Jav321,

        [Parameter(ValueFromPipeline = $true)]
        [PSObject]$Settings
    )

    process {
        $javinizerDataObject = @()
        $Id = $Id.ToUpper()

        if ($Settings) {
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

        try {
            # You need to change this path if you're running the script from outside of the Javinizer module folder
            $jvModulePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'Javinizer.psm1'

            if ($R18) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - R18]"
                Start-ThreadJob -Name "$Id-R18" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-R18Url -Id $using:Id -Language en | Get-R18Data
                } | Out-Null
            }

            if ($R18Zh) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - R18Zh]"
                Start-ThreadJob -Name "$Id-R18Zh" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-R18Url -Id $using:Id -Language zh | Get-R18Data
                } | Out-Null
            }

            if ($Javlibrary) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javlibrary]"
                Start-ThreadJob -Name "$Id-Javlibrary" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-JavlibraryUrl -Id $using:Id -Language en | Get-JavlibraryData
                } | Out-Null
            }

            if ($JavlibraryJa) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavlibraryJa]"
                Start-ThreadJob -Name "$Id-JavlibraryJa" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-JavlibraryUrl -Id $using:Id -Language ja | Get-JavlibraryData
                } | Out-Null
            }

            if ($JavlibraryZh) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavlibraryZh]"
                Start-ThreadJob -Name "$Id-JavlibraryZh" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-JavlibraryUrl -Id $using:Id -Language zh | Get-JavlibraryData
                } | Out-Null
            }

            if ($Dmm) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Dmm]"
                Start-ThreadJob -Name "$Id-Dmm" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-DmmUrl -Id $using:Id | Get-DmmData
                } | Out-Null
            }

            if ($Javbus) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javbus]"
                Start-ThreadJob -Name "$Id-Javbus" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-JavbusUrl -Id $using:Id -Language en | Get-JavbusData
                } | Out-Null
            }

            if ($JavbusJa) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavbusJa]"
                Start-ThreadJob -Name "$Id-JavbusJa" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-JavbusUrl -Id $using:Id -Language ja | Get-JavbusData
                } | Out-Null
            }

            if ($JavbusZh) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavbusZh]"
                Start-ThreadJob -Name "$Id-JavbusZh" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-JavbusUrl -Id $using:Id -Language zh | Get-JavbusData
                } | Out-Null
            }

            if ($Jav321) {
                Write-JVLog -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Jav321]"
                Start-ThreadJob -Name "$Id-Jav321" -ScriptBlock {
                    Import-Module $using:jvModulePath
                    Get-Jav321Url -Id $using:Id | Get-Jav321Data
                } | Out-Null
            }

            # Wait-Job is used separately rather than in a pipeline due to the PowerShell.Exit job that is being created during the first-run of this function

            $jobId = @((Get-Job | Where-Object { $_.Name -like "$Id*" } | Select-Object Id).Id)
            $jobName = @((Get-Job | Where-Object { $_.Name -like "$Id*" } | Select-Object Name).Name)
            Write-Debug "[$Id] [$($MyInvocation.MyCommand.Name)] [Waiting - Scraper jobs] [$jobName]"
            Wait-Job -Id $jobId | Out-Null

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
