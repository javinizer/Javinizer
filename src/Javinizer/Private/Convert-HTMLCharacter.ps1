function Convert-HTMLCharacter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [String]$String
    )

    process {
        $String = $String -replace '&quot;', '"' `
            -replace '&amp;', '&' `
            -replace '&apos;', "'" `
            -replace '&lt;', '<' `
            -replace '&gt;', '>' `
            -replace '&#039;', "'" `
            -replace '#39;s', "'" `
            -replace '※', '.*.' `
            -replace '&#39;', "'" `
            -replace '&#039', ''

        $newString = $String.Trim()
        Write-Output $newString
    }
}
