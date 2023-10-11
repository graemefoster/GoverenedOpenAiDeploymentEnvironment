param apimName string

resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

resource oidcApi 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apim
  name: 'cx'
  properties: {
    path: 'cx'
    type: 'graphql'
    displayName: 'CX GQL Api'
    protocols: [ 'https' ]
    isCurrent: true
    subscriptionRequired: false
  }
}
