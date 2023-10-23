targetScope = 'resourceGroup'
param openAiResourceName string
param openAiModelName string
param openAiModelGpt4Name string
param openAiEmbeddingModelName string
param location string = resourceGroup().location
param openAiLocation string = resourceGroup().location
param devBoxPrivateEndpointSubnetId string
param devBoxOpenAiPrivateDnsZoneId string
param logAnalyticsWorkspaceId string
param tags object

resource openAi 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
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

resource devBoxSubnetPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = if (!empty(devBoxPrivateEndpointSubnetId)) {
  name: '${openAiResourceName}-devbox-private-endpoint'
  location: location
  properties: {
    subnet: {
      id: devBoxPrivateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${openAiResourceName}-private-link-service-connection'
        properties: {
          privateLinkServiceId: openAi.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
  resource dnsGroup 'privateDnsZoneGroups@2022-11-01' = {
    name: '${openAiResourceName}-devbox-private-endpoint-dns'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: '${openAiResourceName}-private-endpoint-cfg'
          properties: {
            privateDnsZoneId: devBoxOpenAiPrivateDnsZoneId
          }
        }
      ]
    }
  }
}

resource deploymentNew 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: openAiModelName
  parent: openAi
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
  parent: openAi
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
  parent: openAi
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


resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: openAi
  name: 'diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}


output id string = openAi.id
output openAiName string = openAi.name
output openAiEndpoint string = openAi.properties.endpoint
output modelName string = deploymentNew.name
output embeddingModelName string = embeddingDeploymentNew.name
