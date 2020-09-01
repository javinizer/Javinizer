function Merge-DefaultConfig {
    param(
        [string] $Target,
        [hashtable] $Configuration
    )

    $DefaultConfiguration = $Script:Logging.Targets[$Target].Defaults
    $ParamsRequired = $Script:Logging.Targets[$Target].ParamsRequired

    $result = @{}

    foreach ($Param in $DefaultConfiguration.Keys) {
        if ($Param -in $ParamsRequired -and $Param -notin $Configuration.Keys) {
            throw ('Configuration {0} is required for target {1}; please provide one of type {2}' -f $Param, $Target, $DefaultConfiguration[$Param].Type)
        }

        if ($Configuration.ContainsKey($Param)) {
            if ($Configuration[$Param] -is $DefaultConfiguration[$Param].Type) {
                $result[$Param] = $Configuration[$Param]
            } else {
                throw ('Configuration {0} has to be of type {1} for target {2}' -f $Param, $DefaultConfiguration[$Param].Type, $Target)
            }
        } else {
            $result[$Param] = $DefaultConfiguration[$Param].Default
        }
    }

    return $result
}
