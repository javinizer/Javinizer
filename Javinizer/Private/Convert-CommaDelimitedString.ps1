function Convert-CommaDelimitedString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$String
    )

    begin {
        $stringArray = @()
    }

    process {
        if ($String -match ',') {
            $stringArray = $String -split ','
        } else {
            $stringArray = $String
        }

        Write-Output $stringArray
    }
}
