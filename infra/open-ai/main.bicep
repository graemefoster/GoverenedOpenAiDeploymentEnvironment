targetScope = 'resourceGroup'
param openAiResourceName string
param openAiModelName string
param openAiModelGpt4Name string
param openAiEmbeddingModelName string
param managedIdentityPrincipalId string
param openAiLocation string
param aadGroupId string
param tags object

resource openAiNew 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAiResourceName
  location: openAiLocation
  kind: 'OpenAI'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      ipRules: [
      ]
      virtualNetworkRules: [
      ]
    }
    customSubDomainName: openAiResourceName
  }
}

resource deploymentNew 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: openAiModelName
  parent: openAiNew
  sku: {
    name: 'Standard'
    capacity: 20
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0613'
    }
  }
}

resource gpt4DeploymentNew 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: openAiModelGpt4Name
  parent: openAiNew
  sku: {
    name: 'Standard'
    capacity: 20
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4'
      version: '0613'
    }
  }
  dependsOn: [
    deploymentNew
  ]
}

resource embeddingDeploymentNew 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: openAiEmbeddingModelName
  parent: openAiNew
  sku: {
    name: 'Standard'
    capacity: 20
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
  }
  dependsOn: [
    gpt4DeploymentNew
  ]
}

resource openAiRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
}

resource rbacModelReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${managedIdentityPrincipalId}-search-${openAiNew.id}')
  scope: openAiNew
  properties: {
    roleDefinitionId: openAiRole.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource aadGroupRbacModelReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(aadGroupId)) {
  name: guid('${aadGroupId}-modelreader-${openAiNew.id}')
  scope:  openAiNew
  properties: {
    roleDefinitionId: openAiRole.id
    principalId: aadGroupId
    principalType: 'Group'
  }
}

output id string = openAiNew.id
output openAiName string = openAiNew.name
output openAiEndpoint string = openAiNew.properties.endpoint
output modelName string = deploymentNew.name
output embeddingModelName string = embeddingDeploymentNew.name
