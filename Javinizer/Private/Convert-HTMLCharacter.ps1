function Convert-HTMLCharacter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$String
    )

    begin {

    }

    process {
        $String = $String -replace '&quot;', '"' `
            -replace '&amp;', '&' `
            -replace '&apos;', "'" `
            -replace '&lt;', '<' `
            -replace '&gt;', '>'

        $String = $String.Trim()
    }

    end {
        Write-Output $String
    }
}
