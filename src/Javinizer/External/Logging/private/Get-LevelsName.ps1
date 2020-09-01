Function Get-LevelsName {
    [CmdletBinding()]
    param()

    return $Script:LevelNames.Keys | Where-Object {$_ -isnot [int]} | Sort-Object
}
