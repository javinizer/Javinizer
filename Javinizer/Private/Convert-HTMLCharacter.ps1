function Convert-HTMLCharacter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$String
    )

    begin {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        $String = $String -replace '&quot;', '"' `
            -replace '&amp;', '&' `
            -replace '&apos;', "'" `
            -replace '&lt;', '<' `
            -replace '&gt;', '>' `
            -replace '&#039;', "'" `
            -replace '#39;s', "'" `
            -replace '※', '*'

        $String = $String.Trim()
        Write-Output $String
    }

    end {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
