function Convert-JVCleanString {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$String
    )

    $invalidSymbols = @(
        '\',
        '/',
        ':',
        '*',
        '?',
        '"',
        '<',
        '>',
        '|',
        "'"
    )

    foreach ($symbol in $invalidSymbols) {
        if ([regex]::Escape($symbol) -eq '/') {
            $String = $String -replace [regex]::Escape($symbol), '-'
        } else {
            $String = $String -replace [regex]::Escape($symbol), ''
        }
    }

    Write-Output $String
}
