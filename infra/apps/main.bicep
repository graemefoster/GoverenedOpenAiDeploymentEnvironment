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
    publicNetworkAccess: 'Enabled' //simulate locked-down network by blocking access to app site. But I need to deploy, so I open up SCM site.
    clientAffinityEnabled: false
    siteConfig: {
      minTlsVersion: '1.2'
      alwaysOn: true
      vnetRouteAllEnabled: true
      ipSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictionsDefaultAction: 'Allow'
      ipSecurityRestrictions: []
      scmIpSecurityRestrictions: []
      linuxFxVersion: 'DOCKER|graemefoster/aicentralcommand:0.1'
      appSettings: [
        {
          name: 'AICentralCommand__Pipelines__Name'
          value: 'SynchronousPipeline'
        }
        {
          name: 'AICentralCommand__Pipelines__Path'
          value: '/openai/deployments/Gpt35Turbo0613/chat/completions'
        }
        {
          name: 'AICentralCommand__Pipelines__Steps__0__StepType'
          value: 'AzureMonitorLogger'
        }
        {
          name: 'AICentralCommand__Pipelines__Steps__0__StepParameters__WorkspaceId'
          value: azureMonitorWorkspaceId
        }
        {
          name: 'AICentralCommand__Pipelines__Steps__0__StepParameters__Key'
          value: listKeys(lanalytics.id, '2020-08-01').primarySharedKey
        }
        {
          name: 'AICentralCommand__Pipelines__Steps__0__StepParameters__LogPrompt'
          value: 'true'
        }

        {
          name: 'AICentralCommand__Pipelines__Steps__1__StepType'
          value: 'OpenAiProxyPipelineStep'
        }
        {
          name: 'AICentralCommand__Pipelines__Steps__1__StepParameters__LanguageEndpoint'
          value: openAiUrl
        }
        {
          name: 'AICentralCommand__Pipelines__Steps__1__StepParameters__ModelName'
          value: openAiModelName
        }
        {
          name: 'AICentralCommand__Pipelines__Steps__1__StepParameters__AuthenticationType'
          value: 'EntraPassThrough'
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
