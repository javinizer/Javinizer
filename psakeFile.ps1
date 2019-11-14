Properties {
    # Disable "compiling" module into monolithinc PSM1.
    # This modifies the default behavior from the "Build" task
    # in the PowerShellBuild shared psake task module
    $PSBPreference.Build.CompileModule = $false

    # Create Pester testresults.xml file in root directory
    $PSBPreference.Test.OutputFile = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "tests") -ChildPath "testresults.xml"

    # Set PSScriptAnalyzer settings file path to Tests/ScriptAnalyzerSettings.psd1
    $PSBPreference.Test.ScriptAnalysis.SettingsPath = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "Tests") -ChildPath "ScriptAnalyzerSettings.psd1"

    # PSGallery Publish task parameters
    #$PSBPreference.Publish.PSRepository = "PSGallery"
    #$PSBPreference.Publish.PSRepositoryApiKey = ""
    #$PSBPreference.Publish.PSRepositoryCredential
}

Task default -depends Test

Task Test -FromModule PowerShellBuild -Version '0.4.0'

# Task to publish to PSGallery
#Task Publish -FromModule PowerShellBuild -Version '0.4.0'

