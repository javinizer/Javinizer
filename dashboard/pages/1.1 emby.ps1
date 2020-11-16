function Get-EmbyActors {
    param (
        [String]$Url,
        [String]$ApiKey
    )

    $actressUrl = "$Url/emby/Persons/?api_key=$ApiKey"
    $request = (Invoke-RestMethod -Method Get -Uri $actressUrl -ErrorAction Stop -Verbose:$false).Items | Select-Object Name, Id, @{Name = 'Thumb'; Expression = { if ($null -ne $_.ImageTags.Thumb) { 'Exists' } else { 'NULL' } } }, @{Name = 'Primary'; Expression = { if ($null -ne $_.ImageTags.Primary) { 'Exists' } else { 'NULL' } } }
    Write-Output $request
}

New-UDPage -Name 'Emby/Jellyfin' -Content {
    New-UDScrollUp
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDPaper -Content {
                New-UDButton -Text 'View Server Actors' -OnClick {
                    if (!($cache:inProgressEmby)) {
                        $cache:inProgressEmby = $true
                        try {
                            Show-UDToast -CloseOnClick "Attempting to retrieve actors from Emby/Jellyfin, please wait" -Title 'Info' -Duration 5000 -Position bottomRight
                            $cache:embyData = Get-EmbyActors -Url $cache:settings.'emby.url' -ApiKey $cache:settings.'emby.apikey'
                        } catch {
                            Show-UDToast -CloseOnClick "Check that your URL and ApiKey are valid: $PSItem" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                            $cache:inProgressEmby = $false
                        }
                        Show-UDToast -Message ($cache:embyData)
                        Sync-UDElement -Id 'dynamic-emby-actortable'
                        $cache:inProgressEmby = $false
                    } else {
                        Show-UDToast -CloseOnClick -Message "Job is already in progress" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                    }
                }
                New-UDButton -Text 'Set Actor Thumbs' -OnClick {
                    if (!($cache:inProgressEmby)) {
                        $cache:inProgressEmby = $true
                        try {
                            Get-EmbyActors -Url $cache:settings.'emby.url' -ApiKey $cache:settings.'emby.apikey'
                        } catch {
                            Show-UDToast -CloseOnClick "Check that your URL and ApiKey are valid: $PSItem" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                            $cache:inProgressEmby = $false
                            return
                        }

                        try {
                            Show-UDToast -CloseOnClick "Setting Emby/Jellyfin actor thumbs -- the job will run in the background" -Title 'Info' -Duration 5000 -Position bottomRight
                            Javinizer -SetEmbyThumbs
                            $cache:inProgressEmby = $false
                            Show-UDToast -CloseOnClick -Message "Completed setting Emby/Jellyfin thumbs -- view log for details" -Title "Success" -TitleColor green -Duration 5000 -Position bottomRight

                        } catch {
                            Show-UDToast -CloseOnClick "$PSItem" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                            $cache:inProgressEmby = $false
                            return
                        }
                    } else {
                        Show-UDToast -CloseOnClick -Message "Job is already in progress" -Title 'Error' -TitleColor red -Duration 5000 -Position bottomRight
                    }
                }
            }
        }
        New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 12 -MediumSize 12 -Content {
            New-UDDynamic -Id 'dynamic-emby-actortable' -Content {
                New-UDTable -Title $cache:settings.'emby.url' -Data $cache:embyData -Sort -Filter -Search -PageSize 20 -Padding 'dense'
            }
        }
    }
}
