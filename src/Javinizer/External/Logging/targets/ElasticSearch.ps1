@{
    Name = 'ElasticSearch'
    Configuration = @{
        Index           = @{Required = $true;   Type = [string]; Default = $null}
        Type            = @{Required = $true;   Type = [string]; Default = $null}
        ServerName      = @{Required = $true;   Type = [string]; Default = $null}
        ServerPort      = @{Required = $true;   Type = [int]; Default = 9200}
        Flatten         = @{Required = $false;  Type = [bool]; Default = $false}
        Level           = @{Required = $false;  Type = [string]; Default = $Logging.Level}
        Authorization   = @{Required = $false;  Type = [string]; Default = $null}
        Https           = @{Required = $false;  Type = [bool]; Default = $false}
    }
    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        Function ConvertTo-FlatterHashTable {
            [CmdletBinding()]
            param(
                [hashtable] $Object
            )

            $ht = [hashtable] @{}

            foreach ($key in $Object.Keys) {
                if ($Object[$key] -is [hashtable]) {
                    $ht += ConvertTo-FlatterHashTable -Object $Object[$key]
                } else {
                    $ht[$key] = $Object[$key]
                }
            }

            return $ht
        }

        if ($Configuration.Https) {
            $httpType = "https"
        } else {
            $httpType = "http"
        }

        $Index = Replace-Token -String $Configuration.Index -Source $Log
        $Uri = '{0}://{1}:{2}/{3}/{4}' -f  $httpType, $Configuration.ServerName, $Configuration.ServerPort, $Index, $Configuration.Type

        if ($Configuration.Flatten) {
            $Message = ConvertTo-FlatterHashTable $Log | ConvertTo-Json -Compress
        } else {
            $Message = $Log | ConvertTo-Json -Compress
        }

        if ($Configuration.Authorization) {
            $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("$($Configuration.Authorization)")))
            Invoke-RestMethod -Method Post -Uri $Uri -Body $Message -Headers @{"Content-Type"="application/json";Authorization="Basic $base64Auth"}
        } else {
            Invoke-RestMethod -Method Post -Uri $Uri -Body $Message -Headers @{"Content-Type"="application/json"}
        }
    }
}