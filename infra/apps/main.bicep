param aspId string
param privateEndpointSubnetId string
param vnetIntegrationSubnetId string
param privateDnsZoneId string
param sampleAppName string
param azureMonitorWorkspaceId string
param azureMonitorWorkspaceName string
param openAiUrl string
param openAiModelName string
param location string = resourceGroup().location


resource lanalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: azureMonitorWorkspaceName
}

resource app 'Microsoft.Web/sites@2022-09-01' = {
  name: sampleAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: aspId
    vnetRouteAllEnabled: true
    virtualNetworkSubnetId: vnetIntegrationSubnetId
    clientAffinityEnabled: false
    siteConfig: {
      minTlsVersion: '1.2'
      alwaysOn: true
      vnetRouteAllEnabled: true
      ipSecurityRestrictions: []
      scmIpSecurityRestrictions: []
      linuxFxVersion: 'DOCKER|graemefoster/aicentralcommand:0.4.2'
      appSettings: [
        {
          name: 'AICentralCommand__AuthProviders__0__Type'
          value: 'NoAuth'
        }
        {
          name: 'AICentralCommand__AuthProviders__0__Name'
          value: 'no-auth'
        }
        {
          name: 'AICentralCommand__Endpoints__0__Type'
          value: 'AzureOpenAIEndpoint'
        }
        {
          name: 'AICentralCommand__Endpoints__0__Name'
          value: 'openai-1'
        }
        {
          name: 'AICentralCommand__Endpoints__0__Properties__LanguageEndpoint'
          value: openAiUrl
        }
        {
          name: 'AICentralCommand__Endpoints__0__Properties__ModelName'
          value: openAiModelName
        }
        {
          name: 'AICentralCommand__Endpoints__0__Properties__AuthenticationType'
          value: 'EntraPassThrough'
        }
        {
          name: 'AICentralCommand__EndpointSelectors__0__Type'
          value: 'SingleEndpoint'
        }
        {
          name: 'AICentralCommand__EndpointSelectors__0__Name'
          value: 'default'
        }
        {
          name: 'AICentralCommand__EndpointSelectors__0__Properties__Endpoint'
          value: 'openai-1'
        }
        {
          name: 'AICentralCommand__Pipelines__0__Name'
          value: 'SynchronousPipeline'
        }
        {
          name: 'AICentralCommand__Pipelines__0__Name'
          value: 'SynchronousPipeline'
        }
        {
          name: 'AICentralCommand__Pipelines__0__Path'
          value: '/openai/deployments/Gpt35Turbo0613/chat/completions'
        }
        {
          name: 'AICentralCommand__Pipelines__0__EndpointSelector'
          value: 'default'
        }
        {
          name: 'AICentralCommand__Pipelines__0__AuthProvider'
          value: 'no-auth'
        }
        {
          name: 'AICentralCommand__Pipelines__0__Steps__0__StepType'
          value: 'AzureMonitorLogger'
        }
        {
          name: 'AICentralCommand__Pipelines__0__Steps__0__Properties__WorkspaceId'
          value: azureMonitorWorkspaceId
        }
        {
          name: 'AICentralCommand__Pipelines__0__Steps__0__Properties__Key'
          value: listKeys(lanalytics.id, '2020-08-01').primarySharedKey
        }
        {
          name: 'AICentralCommand__Pipelines__0__Steps__0__Properties__LogPrompt'
          value: 'true'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://index.docker.io/v1'
        }
      ]
    }
  }

}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = {
  name: '${sampleAppName}-private-endpoint'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${sampleAppName}-private-link-service-connection'
        properties: {
          privateLinkServiceId: app.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }

  resource dnsGroup 'privateDnsZoneGroups@2022-11-01' = {
    name: '${sampleAppName}-private-endpoint-dns'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: '${sampleAppName}-private-endpoint-cfg'
          properties: {
            privateDnsZoneId: privateDnsZoneId
          }
        }
      ]
    }
  }
}

output appUrl string = 'https://${app.properties.defaultHostName}/'
