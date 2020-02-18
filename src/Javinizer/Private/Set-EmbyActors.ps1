function Set-EmbyActors {
    [CmdletBinding()]
    param (
        [object]$Settings,
        [string]$ScriptRoot
    )

    begin {
        $embyActorObject = @()
        # Check settings file for config
        $embyServerUri = $Settings.'Emby/Jellyfin'.'server-url'
        $embyApiKey = $Settings.'Emby/Jellyfin'.'server-api-key'
        $r18ImportPath = Join-Path -Path $ScriptRoot -ChildPath 'r18-thumbs.csv'
    }

    process {
        # Write Emby actors and id to object
        Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Getting actors from Emby"
        $embyActors = (Invoke-RestMethod -Method Get -Uri "$embyServerUri/emby/Persons/?api_key=$embyApiKey" -ErrorAction Stop -Verbose:$false).Items | Select-Object Name, Id, ImageTags

        # Import R18 actors and thumburls to object
        Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Importing R18 actors with thumb urls"
        $R18ThumbCsv = Import-Csv -LiteralPath $r18ImportPath -ErrorAction Stop

        if ($Settings.Metadata.'first-last-name-order' -eq 'True') {
            $csvFullName = $R18ThumbCsv.FullName
            $csvFullNameAlias = $R18ThumbCsv.Alias
        } else {
            $csvFullName = $R18ThumbCsv.FullNameReversed
            $csvFullNameAlias = $R18ThumbCsv.Alias
        }

        foreach ($actor in $embyActors) {
            if ($actor.ImageTags -like $null) {
                if (($csvFullName -like $actor.Name) -or ($csvFullNameAlias -like $actor.Name)) {
                    $index = $csvFullname.IndexOf("$($actor.Name)")
                    if ($index -eq -1) {
                        $index = $csvFullnameAlias.IndexOf("$($actor.Name)")
                    }
                    $actorId = $actor.Id
                    $thumbUrl = $R18ThumbCsv.ThumbUrl[$index]

                    Write-Host "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Writing thumburl [$thumbUrl] to actor [$($actor.Name)]"
                    Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [POST] on Uri [$embyServerUri/emby/Items/$actorId/RemoteImages/Download?Type=Thumb&ImageUrl=$thumbUrl&api_key=$embyApiKey]"
                    $rest = Invoke-RestMethod -Method Post -Uri "$embyServerUri/emby/Items/$actorId/RemoteImages/Download?Type=Thumb&ImageUrl=$thumbUrl&api_key=$embyApiKey" -ErrorAction Continue -Verbose:$false
                    Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Performing [POST] on Uri [$embyServerUri/emby/Items/$actorId/RemoteImages/Download?Type=Primary&ImageUrl=$thumbUrl&api_key=$embyApiKey]"
                    $rest = Invoke-RestMethod -Method Post -Uri "$embyServerUri/emby/Items/$actorId/RemoteImages/Download?Type=Primary&ImageUrl=$thumbUrl&api_key=$embyApiKey" -ErrorAction Continue -Verbose:$false
                }
            }
        }
    }
}
