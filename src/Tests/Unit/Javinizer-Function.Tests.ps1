#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'Javinizer'
$PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
if (Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue') {
    #if the module is already in memory, remove it
    Remove-Module -Name $ModuleName -Force
}
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------
$WarningPreference = "SilentlyContinue"
#-------------------------------------------------------------------------
#Import-Module $moduleNamePath -Force

InModuleScope 'Javinizer' {
    #-------------------------------------------------------------------------
    $WarningPreference = "SilentlyContinue"
    #-------------------------------------------------------------------------
    Describe 'Javinizer Private Function Tests' -Tag Unit {
        Context 'FunctionName' {
            <#
            It 'should ...' {

            }#it
            #>
        }#context_FunctionName
    }#describe_PrivateFunctions
    Describe 'Javinizer Public Function Tests' -Tag Unit {
        Context 'FunctionName' {
            <#
                It 'should ...' {

                }#it
                #>
        }#context_FunctionName
    }#describe_testFunctions
}#inModule
