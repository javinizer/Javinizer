@{
    Name = 'Teams'
    Configuration = @{
        WebHook = @{Required = $true; Type = [string]; Default = $null }
        Details = @{Required = $false; Type = [bool]; Default = $true}
        Level   = @{Required = $false; Type = [string]; Default = $Logging.Level}
        Colors  = @{Required = $false; Type = [hashtable]; Default = @{
            'DEBUG' = 'blue'
            'INFO' = 'brightgreen'
            'WARNING' = 'orange'
            'ERROR' = 'red'
        }}
    }
    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        $Payload = [ordered] @{
            '@type' = 'MessageCard'
            '@context' = 'https://schema.org/extensions'
            summary = '[{0}] {1}' -f $Log.Level, $Log.Message
            themeColor = '#0078D7'
            title = $Log.Message
            text = '![{0}](https://raster.shields.io/static/v1?label=Logging&message={0}&color={1}&style=flat)' -f $Log.Level, $Configuration.Colors[$Log.Level]
        }

        $sections = @()

        if ($Log.Body) {
            $body = [ordered] @{}
            $body.activitySubtitle = 'Body'
            $body.text = $Log.Body | ConvertTo-Json -Depth 3 -Compress
            $sections += $body
        }

        if ($Configuration.Details) {
            $details = [ordered] @{}
            $details.activitySubtitle = 'Details'
            $details.facts = $Log.Keys | ?{$_ -notin 'message', 'body'} | sort | %{
                [ordered] @{
                    name = $_
                    value = if ([string]::IsNullOrEmpty($Log[$_])) {'(none)'} else {[string] $Log[$_]}
                }
            }
            $sections += $details
        }

        if ($sections) {
            $Payload.sections = $sections
        }

        $Payload = $Payload | ConvertTo-Json -Depth 5 -Compress

        Invoke-RestMethod -Method POST -Uri $Configuration.WebHook -Body $Payload -ContentType 'application/json; charset=UTF-8' | Out-Null
    }
}