function Test-JVData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [PSObject]$Data,

        [Parameter(Mandatory = $true, Position = 1)]
        [Array]$RequiredFields
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
            NullFields = $nullFields
        }

        Write-Output $dataObject

    }
}
