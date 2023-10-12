param apimName string
param openAiBaseUrl string 

resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

resource gqlApi 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apim
  name: 'gql'
  properties: {
    path: 'gql'
    type: 'graphql'
    displayName: 'CX GQL Api'
    protocols: [ 'https' ]
    isCurrent: true
    subscriptionRequired: false
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
