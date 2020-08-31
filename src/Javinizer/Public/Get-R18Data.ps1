function Get-R18Data {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()
        $replaceHashTable = @{
            'S********l'                     = 'Schoolgirl'
            'S*********l'                    = 'School girl'
            'S**t'                           = 'Shit'
            'H*********n'                    = 'Humiliation'
            'G*******g'                      = 'Gang bang'
            'G******g'                       = 'Gangbang'
            'H*******m'                      = 'Hypnotism'
            'S*****t'                        = 'Student'
            'C***d'                          = 'Child'
            'D***king'                       = 'Drinking'
            'D***k'                          = 'Drunk'
            'V*****t'                        = 'Violent'
            'M******r'                       = 'Molester'
            'M****ter'                       = 'Molester'
            'Sch**lgirl'                     = 'Schoolgirl'
            'Sch**l'                         = 'School'
            '[Recommended For Smartphones] ' = ''
            'F***'                           = 'Fuck'
            'U**verse'                       = 'Universe'
            'V*****ed'                       = 'Violated'
            'V*****es'                       = 'Violates'
            'V*****e'                        = 'Violate'
            'Y********l'                     = 'Young Girl'
            'I****t'                         = 'Incest'
            'S***e'                          = 'Slave'
            'T*****e'                        = 'Torture'
            'R**e'                           = 'Rape'
            'R**ed'                          = 'Raped'
            'R****g'                         = 'Raping'
            'M****t'                         = 'Molest'
            'A*****ted'                      = 'Assaulted'
            'A*****t'                        = 'Assault'
            'D**gged'                        = 'Drugged'
            'D**g'                           = 'Drug'
            'SK**ls'                         = 'Skills'
            'B***d'                          = 'Blood'
            'S******g'                       = 'Sleeping'
            'S***p'                          = 'Sleep'
            'P****hment'                     = 'Punishment'
            'P****h'                         = 'Punish'
            'StepB****************r'         = 'StepBrother'
            'K****p'                         = 'Kidnap'
            'S********n'                     = 'Subjugation'
            'K**ler'                         = 'Killer'
            'K**l'                           = 'Kill'
            'A***e'                          = 'Abuse'
        }

        try {
            Write-JLog -Level Debug -Message "Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -Verbose:$false
        } catch {
            Write-JLog -Level Error -Message "Error [GET] on URL [$Url]: $PSItem"
        }

        $movieDataObject = [PSCustomObject]@{
            Source        = if ($Url -match 'lg=zh') { 'r18zh' } else { 'r18' }
            Url           = $Url
            ContentId     = Get-R18ContentId -WebRequest $webRequest
            Id            = Get-R18Id -WebRequest $webRequest
            Title         = Get-R18Title -WebRequest $webRequest -Replace $replaceHashTable
            Description   = Get-R18Description -WebRequest $webRequest
            ReleaseDate   = Get-R18ReleaseDate -WebRequest $webRequest
            ReleaseYear   = Get-R18ReleaseYear -WebRequest $webRequest
            Runtime       = Get-R18Runtime -WebRequest $webRequest
            Director      = Get-R18Director -WebRequest $webRequest
            Maker         = Get-R18Maker -WebRequest $webRequest
            Label         = Get-R18Label -WebRequest $webRequest
            Series        = Get-R18Series -WebRequest $webRequest -Replace $replaceHashTable
            Rating        = Get-R18Rating -WebRequest $webRequest
            Actress       = Get-R18Actress -WebRequest $webRequest
            Genre         = Get-R18Genre -WebRequest $webRequest -Replace $replaceHashTable
            CoverUrl      = Get-R18CoverUrl -WebRequest $webRequest
            ScreenshotUrl = Get-R18ScreenshotUrl -WebRequest $webRequest
            TrailerUrl    = Get-R18TrailerUrl -WebRequest $webRequest
        }

        Write-JLog -Level Debug -Message "R18 data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
