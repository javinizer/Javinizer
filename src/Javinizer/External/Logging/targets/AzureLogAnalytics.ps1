@{
    Name          = 'AzureLogAnalytics'
    Description   = 'Sends log data to a Azure Log Analytics Workspace'
    Configuration = @{
        WorkspaceId = @{Required = $true; Type = [string]; Default = $null }
        SharedKey   = @{Required = $true; Type = [string]; Default = $null }
        LogType     = @{Required = $false; Type = [string]; Default = "Logging" }
        Level       = @{Required = $false; Type = [string]; Default = $Logging.Level }
    }
    Logger        = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        Function GetAuthorizationSignature {
            [CmdletBinding()]
            param (
                $WorkspaceId,
                $SharedKey,
                $Hashable
            )

            $hashableBytes = [Text.Encoding]::UTF8.GetBytes($Hashable)
            $key = [Convert]::FromBase64String($SharedKey)
            $sha256 = New-Object System.Security.Cryptography.HMACSHA256
            $sha256.Key = $key
            $hash = $sha256.ComputeHash($hashableBytes)
            $authorization = 'SharedKey {0}:{1}' -f $WorkspaceId,
            [Convert]::ToBase64String($hash)

            return $authorization
        }

        Function WriteLogAnalyticsData {
            param (
                $WorkspaceId,
                $SharedKey,
                $LogType,
                $Body
            )
            $method = "POST"
            $contentType = "application/json"
            $resource = "/api/logs"
            $contentLength = $Body.Length
            $rfc1123date = [DateTime]::UtcNow.ToString("r")
            $xHeaders = "x-ms-date:" + $rfc1123date

            $hashable = $method, $contentLength, $contentType, $xHeaders, $resource -join "`n"
            $getAuthorizationSignatureSplat = @{

                WorkspaceId = $WorkspaceId
                SharedKey   = $SharedKey
                Hashable    = $hashable
            }
            $authorization = GetAuthorizationSignature @getAuthorizationSignatureSplat
            $uri = "https://${WorkspaceId}.ods.opinsights.azure.com${resource}?api-version=2016-04-01"

            $headers = @{

                Authorization          = $authorization
                'Log-Type'             = $LogType
                'x-ms-date'            = $rfc1123date
                'time-generated-field' = 'timestamputc'
            }

            $invokeWebRequestSplat = @{

                Uri             = $uri
                Method          = $method
                ContentType     = $contentType
                Headers         = $headers
                Body            = $Body
                UseBasicParsing = $true
            }
            Invoke-WebRequest @invokeWebRequestSplat
        }

        # Convert timestamp from utc to ISO 8601
        $Log.timestamputc = $Log.timestamputc | Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'

        # See if a Body was provided, that needs to be expanded.
        if ($Log.Body) {
            $Log = $Log + $Log.Body
            $Log.Remove('Body')
        }

        # Submit the data to the API endpoint
        $json = $Log | ConvertTo-Json
        $encodedJson = [System.Text.Encoding]::UTF8.GetBytes($json)
        $writeLogAnalyticsDataSplat = @{

            WorkspaceId = $Configuration.'WorkspaceId'
            SharedKey   = $Configuration.'SharedKey'
            LogType     = $Configuration.'LogType'
            Body        = $encodedJson
        }
        $null = WriteLogAnalyticsData @writeLogAnalyticsDataSplat
    }
}