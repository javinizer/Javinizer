function Convert-CommaDelimitedString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
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

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Begin string: [$String], End string [$stringArray]"
        Write-Output $stringArray
    }
}
