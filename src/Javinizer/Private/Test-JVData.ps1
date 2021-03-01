function Test-JVData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [PSObject]$Data,

        [Parameter(Mandatory = $true, Position = 1)]
        [Array]$RequiredFields,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PSObject]$AllData,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PSObject]$Selected
    )

    process {
        $nullFields = @()
        $errors = 0

        if ($null -ne $RequiredFields) {
            foreach ($field in $RequiredFields) {
                if ($null -eq $Data.($field) -or $Data.($field) -eq '') {
                    $nullFields += $field
                    $errors++
                }
            }
            $nullFields = $nullFields -join ', '
        }

        if ($nullFields.Count -eq 0) {
            $nullFields = $null
        }

        $dataObject = [PSCustomObject]@{
            Data       = $Data
            AllData    = $AllData
            Selected   = $Selected
            NullFields = $nullFields
        }

        Write-Output $dataObject

    }
}
