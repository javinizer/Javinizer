function Get-VideoFile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$Path,
        [int]$FileSize,
        [switch]$Recurse,
        [object]$Settings
    )

    begin {
        $fileExtensions = @()
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function started"
        $FileSize = $Settings.General.'minimum-filesize-to-sort'
    }

    process {
        $fixedPath = ($Path).replace('`[', '[').replace('`]', ']')
        $excludedStrings = Convert-CommaDelimitedString -String $Settings.General.'excluded-file-strings'
        $extensionArray = Convert-CommaDelimitedString -String $Settings.General.'included-file-extensions'
        foreach ($extension in $extensionArray) {
            $fileExtensions += ('.' + $extension)
        }

        if ($excludedStrings) {
            $files = Get-ChildItem -LiteralPath $fixedPath -Recurse:$Recurse -Exclude:$excludedStrings | Where-Object {
                $_.Extension -in $fileExtensions `
                    -and $_.Length -ge ($FileSize * 1MB)
            }
        } else {
            $files = Get-ChildItem -LiteralPath $fixedPath -Recurse:$Recurse | Where-Object {
                $_.Extension -in $fileExtensions `
                    -and $_.Length -ge ($FileSize * 1MB)
            }
        }

        if ($Settings.General.'regex-match' -eq 'True') {
            $files = $files | Where-Object { $_.BaseName -match ($Settings.General.regex) }
        }

        Write-Output $files
    }

    end {
        Write-Debug "[$(Get-TimeStamp)][$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
