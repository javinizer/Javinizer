#Requires -PSEdition Core

function Get-R18Data {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Url
    )

    process {
        $movieDataObject = @()
        $replaceHashTable = @{
            '[Recommended For Smartphones] '    = ''
            'A*****t'               = 'Assault'
            'A*****ted'             = 'Assaulted'
            'A****p'                = 'Asleep'
            'A***e'                 = 'Abuse'
            'B***d'                 = 'Blood'
            'B**d'                  = 'Bled'
            'C***d'                 = 'Child'
            'D******ed'             = 'Destroyed'
            'D******eful'           = 'Shameful'
            'D***k'                 = 'Drunk'
            'D***king'              = 'Drinking'
            'D**g'                  = 'Drug'
            'D**gged'               = 'Drugged'
            'F***'                  = 'Fuck'
            'F*****g'               = 'Forcing'
            'F***e'                 = 'Force'
            'G*********d'           = 'Gang Banged'
            'G*******g'             = 'Gang bang'
            'G******g'              = 'Gangbang'
            'H*********n'           = 'Humiliation'
            'H*******ed'            = 'Hypnotized'
            'H*******m'             = 'Hypnotism'
            'I****t'                = 'Incest'
            'I****tuous'            = 'Incestuous'
            'K****p'                = 'Kidnap'
            'K**l'                  = 'Kill'
            'K**ler'                = 'Killer'
            'K*d'                   = 'Kid'
            'Ko**ji'                = 'Komyo-ji'
            'Lo**ta'                = 'Lolita'
            'M******r'              = 'Molester'
            'M****t'                = 'Molest'
            'M****ted'              = 'Molested'
            'M****ter'              = 'Molester'
            'M****ting'             = 'Molesting'
            'P****h'                = 'Punish'
            'P****hment'            = 'Punishment'
            'P*A'                   = 'PTA'
            'R****g'                = 'Raping'
            'R**e'                  = 'Rape'
            'R**ed'                 = 'Raped'
            'S*********l'           = 'School Girl'
            'S*********ls'          = 'School Girls'
            'S********l'            = 'Schoolgirl'
            'S********n'            = 'Submission'
            'S******g'              = 'Sleeping'
            'S*****t'               = 'Student'
            'S***e'                 = 'Slave'
            'S***p'                 = 'Sleep'
            'S**t'                  = 'Shit'
            'Sch**l'                = 'School'
            'Sch**lgirl'            = 'Schoolgirl'
            'Sch**lgirls'           = 'Schoolgirls'
            'SK**lful'              = 'Skillful'
            'SK**ls'                = 'Skills'
            'StepB****************r'    = 'Stepbrother and Sister'
            'StepM************n'    =' Stepmother and Son'
            'StumB**d'              = 'Stumbled'
            'T*****e'               = 'Torture'
            'U*********sly'         = 'Unconsciously'
            'U**verse'              = 'Universe'
            'V*****e'               = 'Violate'
            'V*****ed'              = 'Violated'
            'V*****es'              = 'Violates'
            'V*****t'               = 'Violent'
            'Y********l'            = 'Young Girl'
        }

        try {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "Performing [GET] on URL [$Url]"
            $webRequest = Invoke-WebRequest -Uri $Url -Method Get -Verbose:$false
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "Error [GET] on URL [$Url]: $PSItem"
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

        Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "R18 data object: $($movieDataObject | ConvertTo-Json -Depth 32 -Compress)"
        Write-Output $movieDataObject
    }
}
