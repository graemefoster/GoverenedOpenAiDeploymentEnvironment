param kvName string
param location string = resourceGroup().location
param logAnalyticsName string
param appinsightsName string

resource lanalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

//used to store LetsEncrypt certificate we generate on post-hook
resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  location: location
  name: kvName
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource kvDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyvault
  name: 'diagnostics'
  properties: {
    workspaceId: lanalytics.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

resource appi 'Microsoft.Insights/components@2020-02-02' = {
  location: location
  kind: 'web'
  name: appinsightsName
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    RetentionInDays: 30
    WorkspaceResourceId: lanalytics.id
  }
}

output kvName string = kvName
output kvId string = keyvault.id
output kvUri string = keyvault.properties.vaultUri
output logAnalyticsId string = lanalytics.id
output appInsightsName string = appi.name
output appInsightsResourceId string = appi.id
output appInsightsInstrumentationKey string = appi.properties.InstrumentationKey
