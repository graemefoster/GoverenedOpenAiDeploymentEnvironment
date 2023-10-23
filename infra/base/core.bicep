param location string = resourceGroup().location
param logAnalyticsName string
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

output logAnalyticsId string = lanalytics.id
output logAnalyticsCustomerId string = lanalytics.properties.customerId
output logAnalyticsName string = lanalytics.name
