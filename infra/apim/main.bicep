param location string = resourceGroup().location
param publisherEmail string
param publisherName string
param subnetId string
param apiName string
param applicationInsightsName string
param openAiBaseUrl string 
param tags object

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
  }
}

module apimConfig './apis.bicep' = {
  name: '${deployment().name}-apis'
  params: {
    apimName: apim.outputs.apimServiceName
    openAiBaseUrl: openAiBaseUrl
  }
}

