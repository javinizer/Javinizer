function Get-TranslatedString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [String]$String,

        [String]$Language = 'en',

        [String]$TranslateDeeplApiKey,
        
        [ValidateSet('googletrans', 'google_trans_new', 'deepl')]
        [String]$Module
    )

    process {
        if ($Module -eq 'google_trans_new') {
            $translatePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'translate_new.py'
        } elseif($Module -eq 'googletrans') {
            $translatePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'translate.py'
        } else{
            $translatePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'translate_deepl.py'
        }

        if ($Language -eq 'en') {
            if ($String -match '[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff66-\uff9f]|[\u4e00-\u9faf]') {
                if ($null -ne $String -and $String -ne '') {
                    try {
                        if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                            $tempFile = python $translatePath $String $Language $TranslateDeeplApiKey
                        } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                            $tempFile = python3 $translatePath $String $Language $TranslateDeeplApiKey
                        }
                        $translatedString = Get-Content -Path $tempFile -Encoding utf8 -Raw
                    } finally {
                        Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
                    }
                }
            } else {
                $translatedString = $String
            }
        } else {
            if ($null -ne $String -and $String -ne '') {
                try {
                    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
                        $tempFile = python $translatePath $String $Language $TranslateDeeplApiKey
                    } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
                        $tempFile = python3 $translatePath $String $Language $TranslateDeeplApiKey
                    }
                    $translatedString = Get-Content -Path $tempFile -Encoding utf8 -Raw
                } finally {
                    Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
                }
            }
        }

        Write-Output $translatedString
    }
}
