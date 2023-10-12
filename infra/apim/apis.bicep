param apimName string
param openAiBaseUrl string
param loggerId string
param customerApiBaseUrl string
param accountsApiBaseUrl string

resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

resource gqlApi 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apim
  name: 'gql'
  properties: {
    path: 'gql'
    type: 'graphql'
    apiType: 'graphql'
    displayName: 'CX GQL Api'
    protocols: [ 'https', 'wss' ]
    isCurrent: true
    subscriptionRequired: false
  }

  resource policy 'policies' = {
    name: 'policy'
    properties: {
      format: 'rawxml'
      value: '''
      <policies>
        <inbound>
            <base/>
        </inbound>
        <backend>
            <base/>
        </backend>
        <outbound>
            <base/>
        </outbound>
    </policies>
      '''
    }
  }

  resource schema 'schemas' = {
    name: 'schema'
    properties: {
      contentType: 'application/graphql'
      document: {
        value: '''
        schema {
          query: Query
        }
        
        type Query {
            customer(id: Int!): Customer
        }
        
        type Customer { 
            id: Int!
            name: String!
            account: Account
        }
        
        type Account {
            id: Int!
            balance: Int!
            availableBalance: Int!
        }
              '''
      }
    }
  }

  resource customerResolver 'resolvers@2023-03-01-preview' = {

    name: 'customerResolver'

    properties: {
      displayName: 'Customer Resolver'
      path: 'Customer'
      description: 'Links the Customer type in the schema with a backend customer api'
    }

    resource resolverPolicy 'policies' = {
      name: 'policy'
      properties: {
        format: 'rawxml'
        value: replace('''
        <http-data-source>
          <set-method>GET</set-method>
          <set-url>|apiBaseUrl|/customer/</set-url>
        </http-data-source>
        ''', '|apiBaseUrl|', customerApiBaseUrl)
      }
    }
  }

  resource acountsResolver 'resolvers@2023-03-01-preview' = {

    name: 'accountsResolver'

    properties: {
      displayName: 'Accounts Resolver'
      path: 'Accounts'
      description: 'Links the Accounts type in the schema with a backend accounts api'
    }

    resource resolverPolicy 'policies' = {
      name: 'policy'
      properties: {
        format: 'rawxml'
        value: replace('''
        <http-data-source>
          <set-method>GET</set-method>
          <set-url>|apiBaseUrl|/customer/</set-url>
        </http-data-source>
        ''', '|apiBaseUrl|', accountsApiBaseUrl)
      }
    }
  }

  resource diagnostics 'diagnostics' = {
    name: 'applicationinsights'
    properties: {
      loggerId: loggerId
    }
  }
}

resource openAi 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apim
  name: 'cx'
  properties: {
    path: '/'
    type: 'http'
    displayName: 'Azure Open AI proxy'
    protocols: [ 'https' ]
    isCurrent: true
    subscriptionRequired: false
    serviceUrl: openAiBaseUrl
  }

  resource diagnostics 'diagnostics' = {
    name: 'applicationinsights'
    properties: {
      loggerId: loggerId
    }
  }
  resource openAIEmbeddings 'operations' = {
    name: 'open-ai-embeddings'
    properties: {
      displayName: 'Embeddings'
      method: 'POST'
      urlTemplate: '/openai/deployments/{deploymentName}/embeddings'
      templateParameters: [
        {
          name: 'deploymentName'
          type: 'string'

          required: true
        }
      ]
      request: {
        queryParameters: [
          {
            name: 'api-version'
            type: 'string'
            required: true
          }
        ]
      }
    }
  }

  resource openAIChatCompletions 'operations' = {
    name: 'open-ai-chat-completions'
    properties: {
      displayName: 'Chat Completions'
      method: 'POST'
      urlTemplate: '/openai/deployments/{deploymentName}/chat/completions'
      templateParameters: [
        {
          name: 'deploymentName'
          type: 'string'

          required: true
        }
      ]
      request: {
        queryParameters: [
          {
            name: 'api-version'
            type: 'string'
            required: true
          }
        ]
      }
    }
  }
}

output a string = customerApiBaseUrl
output b string = accountsApiBaseUrl
