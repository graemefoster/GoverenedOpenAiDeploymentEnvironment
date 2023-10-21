param location string = resourceGroup().location
param aspName string

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: aspName
  location: location
  sku: {
    name: 'B1'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    zoneRedundant: false
    reserved: true
  }
}

output aspId string = asp.id
