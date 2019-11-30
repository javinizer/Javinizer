function Convert-CommaDelimitedString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$String
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
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

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
