param location string = resourceGroup().location
param publisherEmail string
param publisherName string
param subnetId string
param apiName string
param applicationInsightsName string
param openAiBaseUrl string
param privateEndpointSubnetId string
param apimDnsPrivateZoneId string
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

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${apiName}-pe'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${apiName}-plsc'
        properties: {
          privateLinkServiceId: apim.outputs.apimServiceId
          groupIds: [
            'apimGateway'
          ]
        }
      }
    ]
  }

  resource dnsGroup 'privateDnsZoneGroups@2022-11-01' = {
    name: '${apiName}-private-endpoint-dns'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: '${apiName}-private-endpoint-cfg'
          properties: {
            privateDnsZoneId: apimDnsPrivateZoneId
          }
        }
      ]
    }
  }
}


module apimConfig './apis.bicep' = {
  name: '${deployment().name}-apis'
  params: {
    apimName: apim.outputs.apimServiceName
    openAiBaseUrl: openAiBaseUrl
    loggerId: apim.outputs.loggerId
  }
}
