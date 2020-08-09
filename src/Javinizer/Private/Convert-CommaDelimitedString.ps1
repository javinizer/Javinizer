function Convert-CommaDelimitedString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$String
    )

    begin {
        $stringArray = @()
    }

    process {
        $String = $String -replace '"', ''
        if ($String -match ',') {
            $stringArray = $String -split ','
        } else {
            $stringArray = $String
        }

        Write-JLog -Level Debug -Message "Begin string: [$String], End string [$stringArray]"
        Write-Output $stringArray
    }
}
