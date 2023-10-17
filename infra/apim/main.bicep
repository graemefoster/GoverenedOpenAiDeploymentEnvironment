param location string = resourceGroup().location
param publisherEmail string
param publisherName string
param subnetId string
param apiName string
param applicationInsightsName string
param openAiBaseUrl string 
param customerApiBaseUrl string
param accountsApiBaseUrl string
param tags object

resource apimPip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: '${apiName}-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Global'
  }
}

module apim '../core/gateway/apim.bicep' = {
  name: '${deployment().name}-apim'
  params: {
    tags: tags
    name: apiName
    subnetId: subnetId
    location: location
    publisherEmail: publisherEmail
    publisherName: publisherName
    sku: 'Developer'
    skuCount: 1
    applicationInsightsName: applicationInsightsName
    pipId: apimPip.id
  }
}

module apimConfig './apis.bicep' = {
  name: '${deployment().name}-apis'
  params: {
    apimName: apim.outputs.apimServiceName
    openAiBaseUrl: openAiBaseUrl
    customerApiBaseUrl: customerApiBaseUrl
    accountsApiBaseUrl: accountsApiBaseUrl
    loggerId: apim.outputs.loggerId
  }
}

