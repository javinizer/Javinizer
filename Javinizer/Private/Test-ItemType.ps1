function Test-ItemType {
    if ([System.Environment]::OSVersion.Platform -eq 'Win32NT') {
        if ($PSVersionTable.PSVersion -like '7*') {
            $script:directoryMode = 'd----'
            $script:itemMode = '-a---'
        } else {
            $script:directoryMode = 'd-----'
            $script:itemMode = '-a----'
        }
    } elseif ([System.Environment]::OSVersion.Platform -eq 'Unix') {
        $script:directoryMode = 'd-----'
        $script:itemMode = '------'
    }
}
