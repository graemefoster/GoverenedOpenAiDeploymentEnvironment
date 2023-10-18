targetScope = 'resourceGroup'
param openAiResourceName string
param openAiModelName string
param openAiModelGpt4Name string
param openAiEmbeddingModelName string
param managedIdentityPrincipalId string
param location string = resourceGroup().location
param openAiLocation string = resourceGroup().location
param privateEndpointSubnetId string
param privateDnsZoneId string
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
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    customSubDomainName: openAiResourceName
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = {
  name: '${openAiResourceName}-private-endpoint'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${openAiResourceName}-private-link-service-connection'
        properties: {
          privateLinkServiceId: openAiNew.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }

  resource dnsGroup 'privateDnsZoneGroups@2022-11-01' = {
    name: '${openAiResourceName}-private-endpoint-dns'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: '${openAiResourceName}-private-endpoint-cfg'
          properties: {
            privateDnsZoneId: privateDnsZoneId
          }
        }
      ]
    }
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

resource gpt4DeploymentNew 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = if (!empty(openAiModelGpt4Name)) {
  name: empty(openAiModelGpt4Name) ? 'IGNORE' : openAiModelGpt4Name //fix Bicep issue which blows up if name is empty
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
  dependsOn: empty(gpt4DeploymentNew) ? [ deploymentNew ] : [ gpt4DeploymentNew ]
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

output id string = openAiNew.id
output openAiName string = openAiNew.name
output openAiEndpoint string = openAiNew.properties.endpoint
output modelName string = deploymentNew.name
output embeddingModelName string = embeddingDeploymentNew.name
