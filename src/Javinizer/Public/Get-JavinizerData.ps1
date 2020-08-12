function Get-JavinizerData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String]$Id,
        [Parameter()]
        [Switch]$R18,
        [Parameter()]
        [Switch]$R18Zh,
        [Parameter()]
        [Switch]$Javlibrary,
        [Parameter()]
        [Switch]$JavlibraryJa,
        [Parameter()]
        [Switch]$JavlibraryZh,
        [Parameter()]
        [Switch]$Dmm,
        [Parameter()]
        [Switch]$Javbus,
        [Parameter()]
        [Switch]$JavbusJa,
        [Parameter()]
        [Switch]$JavbusZh,
        [Parameter()]
        [Switch]$Jav321
    )

    process {
        $javinizerDataObject = @()

        if ($R18) {
            $javinizerDataObject += Get-R18Url -Id $Id -Language en | Get-R18Data
        }

        if ($R18Zh) {
            $javinizerDataObject += Get-R18Url -Id $Id -Language zh | Get-R18Data
        }

        if ($Javlibrary) {
            $javinizerDataObject += Get-JavlibraryUrl -Id $Id -Language en | Get-JavlibraryData
        }

        if ($JavlibraryJa) {
            $javinizerDataObject += Get-JavlibraryUrl -Id $Id -Language ja | Get-JavlibraryData
        }

        if ($JavlibraryZh) {
            $javinizerDataObject += Get-JavlibraryUrl -Id $Id -Language zh | Get-JavlibraryData
        }

        if ($Dmm) {
            $javinizerDataObject += Get-DmmUrl -Id $Id | Get-DmmData
        }

        if ($Javbus) {
            $javbusDataObject += Get-JavbusUrl -Id $Id -Language en | Get-JavbusData
        }

        if ($JavbusJa) {
            $javbusDataObject += Get-JavbusUrl -Id $Id -Language ja | Get-JavbusData
        }

        if ($JavbusZh) {
            $javbusDataObject += Get-JavbusUrl -Id $Id -Language zh | Get-JavbusData
        }

        if ($Jav321) {
            $javbusDataObject += Get-Jav321Url -Id $Id | Get-Jav321Data
        }

        Write-Output $javinizerDataObject
    }

}
