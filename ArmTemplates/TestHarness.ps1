
#$path="C:\Users\gobyers\OneDrive - Microsoft\CustomerSpecifics\Barclays\DCT-SubVend-FORK\Azure-Barclays-Platform\armlib\resourcegroups\EmptyResourceGroup.json"
$path="C:\ReposGitHub\Snippets\ArmTemplates\ResourceGroupWithStorage.json"

$templateParams = @{
    'rgName' = "gordarmtest4"
    'principalId' = "d39ba6a7-bd94-42bd-806b-dbce9e4dc198"
    'roleDefinition' = 'NetworkContributor'
}
New-AzSubscriptionDeployment -Location WestEurope -TemplateFile $path -TemplateParameterObject $templateParams -SkipTemplateParameterPrompt

$path = "C:\ReposGitHub\Snippets\ArmTemplates\ResourceGroupWithStorageAndFunctionHosting.json"
$templateParams = @{
    'rgName' = "gordarmtest8"
    'FunctionAppName' = "jammyjamjar"
}

New-AzSubscriptionDeployment -Location WestEurope -TemplateFile $path -TemplateParameterObject $templateParams -SkipTemplateParameterPrompt

