function Replace-Token {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
    [CmdletBinding()]
    param(
        [string] $String,
        [object] $Source
    )

    [string] $result = $String
    [regex] $tokenMatcher = '%{(?<token>\w+?)?(?::?\+(?<datefmtU>(?:%[ABCDGHIMRSTUVWXYZabcdeghjklmnprstuwxy].*?)+))?(?::?\+(?<datefmt>(?:.*?)+))?(?::(?<padding>-?\d+))?}'
    $tokenMatches = @()
    $tokenMatches += $tokenMatcher.Matches($String)

    [array]::Reverse($tokenMatches)

    foreach ($match in $tokenMatches) {
        $formattedEntry = [string]::Empty
        $tokenContent = [string]::Empty

        $token = $match.Groups["token"].value
        $datefmt = $match.Groups["datefmt"].value
        $datefmtU = $match.Groups["datefmtU"].value
        $padding = $match.Groups["padding"].value

        [hashtable] $dateParam = @{ }
        if (-not [string]::IsNullOrWhiteSpace($token)) {
            $tokenContent = $Source.$token
            $dateParam["Date"] = $tokenContent
        }

        if (-not [string]::IsNullOrWhiteSpace($datefmtU)) {
            $formattedEntry = Get-Date @dateParam -UFormat $datefmtU
        }
        elseif (-not [string]::IsNullOrWhiteSpace($datefmt)) {
            $formattedEntry = Get-Date @dateParam -Format $datefmt
        }
        else {
            $formattedEntry = $tokenContent
        }

        if ($padding) {
            $formattedEntry = "{0,$padding}" -f $formattedEntry
        }

        $result = $result.Substring(0, $match.Index) + $formattedEntry + $result.Substring($match.Index + $match.Length)
    }

    return $result
}