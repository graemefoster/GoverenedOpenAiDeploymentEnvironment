param vnetName string
param location string = resourceGroup().location
param vnetCidr string
param tags object

resource apimNsg 'Microsoft.Network/networkSecurityGroups@2022-11-01' = {
  name: '${vnetName}-apim-nsg'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'ClientCommsToApim'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
          protocol: 'Tcp'
          description: 'Let Client traffic in'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'MgmtEndpoint'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 999
          protocol: '*'
          description: 'Let Mgmt traffic in'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ vnetCidr ]
    }
    subnets: [
      {
        name: 'AppServiceDelegated'
        properties: {
          addressPrefix: cidrSubnet(vnetCidr, 24, 1)
          delegations: [
            {
              name: 'AppServiceDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'PrivateEndpoints'
        properties: {
          addressPrefix: cidrSubnet(vnetCidr, 24, 2)
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'ApimSubnet'
        properties: {
          addressPrefix: cidrSubnet(vnetCidr, 24, 3)
          networkSecurityGroup: {
            id: apimNsg.id
          }
        }
      }
    ]
  }
}


// resource customHostPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: customHost
//   location: 'global'

//   resource vnetLink 'virtualNetworkLinks@2020-06-01' = {
//     name: '${customHost}-link'
//     location: 'global'
//     properties: {
//       registrationEnabled: false
//       virtualNetwork: {
//         id: vnet.id
//       }
//     }
//   }
// }

output privateEndpointSubnetId string = filter(vnet.properties.subnets, subnet => subnet.name == 'PrivateEndpoints')[0].id
output vnetIntegrationSubnetId string = filter(vnet.properties.subnets, subnet => subnet.name == 'AppServiceDelegated')[0].id
output apimSubnetId string = filter(vnet.properties.subnets, subnet => subnet.name == 'ApimSubnet')[0].id
