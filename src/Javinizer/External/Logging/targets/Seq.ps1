@{
    Name          = 'Seq'
    Description   = 'Sends log data to the designated Seq server web service'
    Configuration = @{
        Url        = @{Required = $true;  Type = [string];    Default = $null}
        ApiKey     = @{Required = $false; Type = [string];    Default = $null}
        Properties = @{Required = $true;  Type = [hashtable]; Default = $null}
        Level      = @{Required = $false; Type = [string];    Default = $Logging.Level}
    }
    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        $Body = @{
          Events = @(@{
            Timestamp = [System.DateTimeOffset]::Now.ToString('o')
            Level = $Configuration.Level
            MessageTemplate = $Log.Message | ConvertTo-Json
            Properties = ($Log + $Configuration.Properties) | ConvertTo-Json
          })
        }

        if ($Configuration.ApiKey) {
            $Url = '{0}/api/events/raw?apiKey={1}' -f $Configuration.Url, $Configuration.ApiKey
        } else {
            $Url = '{0}/api/events/raw?' -f $Configuration.Url
        }

        Invoke-RestMethod -Uri $Url -Body ($Body | ConvertTo-Json) -ContentType "application/json" -Method POST | Out-Null
    }
}