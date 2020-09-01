function Get-LevelNumber {
    [CmdletBinding()]
    param(
        $Level
    )
    if ($Level -is [int] -and $Level -in $Script:LevelNames.Keys) {return $Level}
    elseif ([string] $Level -eq $Level -and $Level -in $Script:LevelNames.Keys) {return $Script:LevelNames[$Level]}
    else {throw ('Level not a valid integer or a valid string: {0}' -f $Level)}
}
