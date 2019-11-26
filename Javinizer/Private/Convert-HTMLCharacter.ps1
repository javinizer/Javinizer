function Convert-HTMLCharacter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$String
    )

    process {
        $String = $String -replace '&quot;', '"' `
            -replace '&amp;', '&' `
            -replace '&apos;', "'" `
            -replace '&lt;', '<' `
            -replace '&gt;', '>' `
            -replace '&#039;', "'" `
            -replace '#39;s', "'"

        $String = $String.Trim()
        Write-Output $String
    }
}
