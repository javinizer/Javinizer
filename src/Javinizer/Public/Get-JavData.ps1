function Get-JavData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Id,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$R18,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$R18Zh,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$Javlibrary,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$JavlibraryJa,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$JavlibraryZh,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$Dmm,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$Javbus,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$JavbusJa,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$JavbusZh,
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Boolean]$Jav321
    )

    process {
        $javinizerDataObject = @()

        if ($R18) {
            Write-JLog -Level Info -Message "Searching [R18] for Id: [$Id]"
            $javinizerDataObject += Get-R18Url -Id $Id -Language en | Get-R18Data
        }

        if ($R18Zh) {
            Write-JLog -Level Info -Message "Searching [R18Zh] for Id: [$Id]"
            $javinizerDataObject += Get-R18Url -Id $Id -Language zh | Get-R18Data
        }

        if ($Javlibrary) {
            Write-JLog -Level Info -Message "Searching [Javlibrary] for Id: [$Id]"
            $javinizerDataObject += Get-JavlibraryUrl -Id $Id -Language en | Get-JavlibraryData
        }

        if ($JavlibraryJa) {
            Write-JLog -Level Info -Message "Searching [JavlibraryJa] for Id: [$Id]"
            $javinizerDataObject += Get-JavlibraryUrl -Id $Id -Language ja | Get-JavlibraryData
        }

        if ($JavlibraryZh) {
            Write-JLog -Level Info -Message "Searching [JavlibraryZh] for Id: [$Id]"
            $javinizerDataObject += Get-JavlibraryUrl -Id $Id -Language zh | Get-JavlibraryData
        }

        if ($Dmm) {
            Write-JLog -Level Info -Message "Searching [Dmm] for Id: [$Id]"
            $javinizerDataObject += Get-DmmUrl -Id $Id | Get-DmmData
        }

        if ($Javbus) {
            Write-JLog -Level Info -Message "Searching [Javbus] for Id: [$Id]"
            $javbusDataObject += Get-JavbusUrl -Id $Id -Language en | Get-JavbusData
        }

        if ($JavbusJa) {
            Write-JLog -Level Info -Message "Searching [JavbusJa] for Id: [$Id]"
            $javbusDataObject += Get-JavbusUrl -Id $Id -Language ja | Get-JavbusData
        }

        if ($JavbusZh) {
            Write-JLog -Level Info -Message "Searching [JavbusZh] for Id: [$Id]"
            $javbusDataObject += Get-JavbusUrl -Id $Id -Language zh | Get-JavbusData
        }

        if ($Jav321) {
            Write-JLog -Level Info -Message "Searching [Jav321] for Id: [$Id]"
            $javbusDataObject += Get-Jav321Url -Id $Id | Get-Jav321Data
        }

        Write-Output $javinizerDataObject
    }
}
