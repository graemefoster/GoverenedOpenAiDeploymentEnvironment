param location string = resourceGroup().location
param logAnalyticsName string
param appinsightsName string
param tags object

resource lanalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appi 'Microsoft.Insights/components@2020-02-02' = {
  location: location
  kind: 'web'
  name: appinsightsName
  tags: tags
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    RetentionInDays: 30
    WorkspaceResourceId: lanalytics.id
  }
}

output logAnalyticsId string = lanalytics.id
output logAnalyticsCustomerId string = lanalytics.properties.customerId
output logAnalyticsName string = lanalytics.name
output appInsightsName string = appi.name
output appInsightsResourceId string = appi.id
output appInsightsInstrumentationKey string = appi.properties.InstrumentationKey
