Write-Host "Connecting to Azure"
Connect-AzAccount -Subscription $env:AZURE_SUBSCRIPTION_ID -TenantId $env:AZURE_TENANT_ID
Write-Host "Connected to Azure"

if ($null -eq $env:OPEN_AI_OPS_GROUP_NAME) {
    Write-Host "Please use ""azd env set OPEN_AI_OPS_GROUP_NAME <group-name>"" to the name of the AAD group that will contain the Ops users who can create the devbox's"
    exit 1
} else {
    Write-Host "Creating AAD Groups for Open AI Ops users $env:OPEN_AI_OPS_GROUP_NAME"
}
$AadOpsUserGroupName=$env:OPEN_AI_OPS_GROUP_NAME

if ($null -eq $env:OPEN_AI_USERS_GROUP_NAME) {
    Write-Host "Please use ""azd env set OPEN_AI_USERS_GROUP_NAME <group-name>"" to the name of the AAD group that will contain the Open AI Ops users who will use the devbox's"
    exit 1
} else {
    Write-Host "Creating AAD Groups for Open AI users $env:OPEN_AI_USERS_GROUP_NAME"
}
$AadDevBoxUsersGroupName=$env:OPEN_AI_USERS_GROUP_NAME

if ($null -eq $env:OPEN_AI_TEAM_LEADS_GROUP_NAME) {
    Write-Host "Please use ""azd env set OPEN_AI_TEAM_LEADS_GROUP_NAME <group-name>"" to the name of the AAD group that will contain the group who can deploy the OpenAI Sandbox environment"
    exit 1
} else {
    Write-Host "Creating AAD Groups for Open AI Team Leads $env:OPEN_AI_TEAM_LEADS_GROUP_NAME"
}
$AadDevBoxTeamLeadsGroupName=$env:OPEN_AI_TEAM_LEADS_GROUP_NAME

Write-Host "Looking for AAD Group '$AadOpsUserGroupName'"
$aadOpsUserGroup = Get-AzADGroup -SearchString $AadOpsUserGroupName
if ($null -eq $aadOpsUserGroup) {
    Write-Host "Creating new AAD Group $AadOpsUserGroupName"
    $aadOpsUserGroup = New-AzADGroup -DisplayName $AadOpsUserGroupName -MailNickname $AadOpsUserGroupName
}

Write-Host "Looking for AAD Group '$AadDevBoxUsersGroupName'"
$aadDevBoxUserGroup = Get-AzADGroup -SearchString $AadDevBoxUsersGroupName
if ($null -eq $aadDevBoxUserGroup) {
    Write-Host "Creating new AAD Group '$AadDevBoxUsersGroupName'"
    $aadDevBoxUserGroup = New-AzADGroup -DisplayName $AadDevBoxUsersGroupName -MailNickname $AadDevBoxUsersGroupName
}
    
Write-Host "Looking for AAD Group '$AadDevBoxTeamLeadsGroupName'"
$aadDevBoxTeamLeadGroup = Get-AzADGroup -SearchString $AadDevBoxTeamLeadsGroupName
if ($null -eq $aadDevBoxTeamLeadGroup) {
    Write-Host "Creating new AAD Group '$AadDevBoxTeamLeadsGroupName'"
    $aadDevBoxTeamLeadGroup = New-AzADGroup -DisplayName $AadDevBoxTeamLeadsGroupName -MailNickname $AadDevBoxTeamLeadsGroupName
}
    
#return the group ids in a dictionary
$groups = @{
    "AadOpsUserGroupId"         = $aadOpsUserGroup.Id
    "AadDevBoxUsersGroupId"     = $aadDevBoxUserGroup.Id
    "AadDevBoxTeamLeadsGroupId" = $aadDevBoxTeamLeadGroup.Id
}

#Write the group ids into a simple json file so we can later load it in Bicep
#get the current script folder

$groups | ConvertTo-Json | Out-File -FilePath "$PSScriptRoot\..\..\infra\aad-group-ids.json"
