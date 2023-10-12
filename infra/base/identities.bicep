param location string = resourceGroup().location

resource openAiAccessIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  location: location
  name: 'openai-access-identity'
}

output identityId string = openAiAccessIdentity.id
output identityName string = openAiAccessIdentity.name
output identityPrincipalId string = openAiAccessIdentity.properties.principalId
