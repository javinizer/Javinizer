function Get-JVData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
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

        try {
            if ($R18) {
                Write-JLog -Level Info -Message "Searching [R18] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-R18" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-R18Url -Id $using:Id -Language en | Get-R18Data
                } | Out-Null
            }
    
            if ($R18Zh) {
                Write-JLog -Level Info -Message "Searching [R18Zh] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-R18Zh" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-R18Url -Id $using:Id -Language zh | Get-R18Data
                } | Out-Null
            }
    
            if ($Javlibrary) {
                Write-JLog -Level Info -Message "Searching [Javlibrary] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-Javlibrary" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-JavlibraryUrl -Id $using:Id -Language en | Get-JavlibraryData
                } | Out-Null
            }
    
            if ($JavlibraryJa) {
                Write-JLog -Level Info -Message "Searching [JavlibraryJa] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-JavlibraryJa" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-JavlibraryUrl -Id $using:Id -Language ja | Get-JavlibraryData
                } | Out-Null
            }
    
            if ($JavlibraryZh) {
                Write-JLog -Level Info -Message "Searching [JavlibraryZh] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-JavlibraryZh" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-JavlibraryUrl -Id $using:Id -Language zh | Get-JavlibraryData
                } | Out-Null
            }
    
            if ($Dmm) {
                Write-JLog -Level Info -Message "Searching [Dmm] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-Dmm" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-DmmUrl -Id $using:Id | Get-DmmData
                } | Out-Null
            }
    
            if ($Javbus) {
                Write-JLog -Level Info -Message "Searching [Javbus] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-Javbus" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-JavbusUrl -Id $using:Id -Language en | Get-JavbusData
                } | Out-Null
            }
    
            if ($JavbusJa) {
                Write-JLog -Level Info -Message "Searching [JavbusJa] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-JavbusJa" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-JavbusUrl -Id $using:Id -Language ja | Get-JavbusData
                } | Out-Null
            }
    
            if ($JavbusZh) {
                Write-JLog -Level Info -Message "Searching [JavbusZh] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-JavbusZh" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-JavbusUrl -Id $using:Id -Language zh | Get-JavbusData
                } | Out-Null
            }
    
            if ($Jav321) {
                Write-JLog -Level Info -Message "Searching [Jav321] for Id: [$Id]"
                Start-ThreadJob -Name "$Id-Jav321" -ScriptBlock {
                    Import-Module X:\git\Projects\JAV-Organizer\src\Javinizer\Javinizer.psm1
                    Get-Jav321Url -Id $using:Id | Get-Jav321Data
                } | Out-Null
            }
    
            # Wait for all jobs to complete to write to the combined data object
            $javinizerDataObject = Get-Job | Receive-Job -AutoRemoveJob -Wait -Force


            $dataObject = [PSCustomObject]@{
                Data     = $javinizerDataObject
                Settings = $Settings
            }
            
            Write-Output $dataObject

        } catch {
            Write-JLog -Level Error -Message "Error occured during scraper jobs: $PSItem"
        } finally {
            # Remove all completed or running jobs before exiting this script
            # If jobs remain after closure, it may cause issues in concurrent runs
            Write-JLog -Level Debug -Message "Stopping/removing all completed/running jobs"
            Get-Job | Remove-Job -Force
        }
    }
}
