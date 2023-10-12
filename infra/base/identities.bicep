param location string = resourceGroup().location
param tags object

resource openAiAccessIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  location: location
  tags: tags
  name: 'openai-access-identity'
}

output identityId string = openAiAccessIdentity.id
output identityName string = openAiAccessIdentity.name
output identityPrincipalId string = openAiAccessIdentity.properties.principalId
