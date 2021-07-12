
function Test-JavlibraryCf {
    param (
        [PSObject]$Settings,
        [PSObject]$CfSession
    )

    $ProgressPreference = 'SilentlyContinue'

    if (!($CfSession)) {
        try {
            Invoke-WebRequest -Uri $Settings.'javlibrary.baseurl' -MaximumRetryCount 0 -Verbose:$false | Out-Null
        } catch {
            try {
                $CfSession = Get-CfSession -cf_chl_2:$Settings.'javlibrary.cookie.cf_chl_2' -cf_chl_prog:$Settings.'javlibrary.cookie.cf_chl_prog' -cf_clearance:$Settings.'javlibrary.cookie.cf_clearance' -UserAgent:$Settings.'javlibrary.browser.useragent' -BaseUrl $Settings.'javlibrary.baseurl'
                # Testing with the newly created session sometimes fails if there is no wait time
                Start-Sleep -Seconds 1
                Invoke-WebRequest -Uri $Settings.'javlibrary.baseurl' -WebSession $CfSession -UserAgent $CfSession.UserAgent -MaximumRetryCount 0 -Verbose:$false | Out-Null
            } catch {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] Unable reach Javlibrary, enter JAVLibrary cookies and browser useragent to use the scraper"
                $CfSession = Get-CfSession -BaseUrl $Settings.'javlibrary.baseurl'
                # Testing with the newly created session sometimes fails if there is no wait time
                Start-Sleep -Seconds 1
                try {
                    Invoke-WebRequest -Uri $Settings.'javlibrary.baseurl' -WebSession $CfSession -UserAgent $CfSession.UserAgent -MaximumRetryCount 0 -Verbose:$false | Out-Null
                    if ($CfSession) {
                        $originalSettingsContent = Get-Content -Path $SettingsPath
                        $cookies = $CfSession.Cookies.GetCookies($Settings.'javlibrary.baseurl')
                        $cf_clearance = ($cookies | Where-Object { $_.Name -eq 'cf_clearance' }).Value
                        $cf_chl_2 = ($cookies | Where-Object { $_.Name -eq 'cf_chl_2' }).Value
                        $cf_chl_prog = ($cookies | Where-Object { $_.Name -eq 'cf_chl_prog' }).Value
                        $userAgent = $CfSession.UserAgent
                        $settingsContent = $OriginalSettingsContent
                        $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cf_chl_2": ".*"', "`"javlibrary.cookie.cf_chl_2`": `"$cf_chl_2`""
                        $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cf_chl_prog": ".*"', "`"javlibrary.cookie.cf_chl_prog`": `"$cf_chl_prog`""
                        $settingsContent = $settingsContent -replace '"javlibrary\.cookie\.cf_clearance": ".*"', "`"javlibrary.cookie.cf_clearance`": `"$cf_clearance`""
                        $settingsContent = $settingsContent -replace '"javlibrary\.browser\.useragent": ".*"', "`"javlibrary.browser.useragent`": `"$userAgent`""

                        $settingsContent | Out-File -FilePath $SettingsPath
                        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$($MyInvocation.MyCommand.Name)] Replaced Javlibrary settings with updated values in [$SettingsPath]"
                    }
                } catch {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Unable reach Javlibrary, invalid websession values"
                }
            }
        }
    } else {
        try {
            Invoke-WebRequest -Uri $Settings.'javlibrary.baseurl' -WebSession $CfSession -UserAgent $CfSession.UserAgent -MaximumRetryCount 0 -Verbose:$false | Out-Null
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$($MyInvocation.MyCommand.Name)] Unable reach Javlibrary, invalid websession values"
        }
    }

    Write-Output $CfSession
}
