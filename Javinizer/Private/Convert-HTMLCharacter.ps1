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
            -replace '#39;s', "'" `
            -replace '※', '*' `
            -replace '&#39;', "'" `
            -replace '&#039', ''

        $newString = $String.Trim()
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Begin String: [$String]; End string: [$newString]"
        Write-Output $newString

    }
}
