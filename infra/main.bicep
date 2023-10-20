targetScope = 'resourceGroup'

// The main bicep module to provision Azure resources.
// For a more complete walkthrough to understand how this file works with azd,
// see https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string = resourceGroup().name

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

@minLength(1)
@description('Location for OpenAI resource')
param openAiLocation string = resourceGroup().location

@description('Subnet the devbox can reach to expose the APIm private endpoint in')
param devBoxNetworkPrivateEndpointSubnetId string

@description('Private DNS Zone to use for the APIm resource')
param appServicePrivateDnsZoneId string

var abbrs = loadJsonContent('./abbreviations.json')

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': environmentName
}

// Generate a unique token to be used in naming resources.
// Remove linter suppression after using.
#disable-next-line no-unused-vars
var resourceToken = toLower(uniqueString(resourceGroup().id, environmentName, location))

// Name of the service defined in azure.yaml
// A tag named azd-service-name with this value should be applied to the service host resource, such as:
//   Microsoft.Web/sites for appservice, function
// Example usage:
//   tags: union(tags, { 'azd-service-name': apiServiceName })
#disable-next-line no-unused-vars
var apiServiceName = 'python-api'

// Add resources to be provisioned below.
// A full example that leverages azd bicep modules can be seen in the todo-python-mongo template:
// https://github.com/Azure-Samples/todo-python-mongo/tree/main/infra

var vnetName = '${abbrs.networkVirtualNetworks}${resourceToken}'
var openAiName = toLower('${abbrs.cognitiveServicesAccounts}${resourceToken}')
var aspName = '${abbrs.webSitesAppService}-${resourceToken}'
var appName = 'openai-centralcommand-${resourceToken}'

module vnet 'base/vnet.bicep' = {
  name: '${deployment().name}-vnet'
  params: {
    vnetCidr: '10.200.0.0/16'
    vnetName: vnetName
    location: location
    tags: tags
  }
}

module core 'base/core.bicep' = {
  name: '${deployment().name}-core'
  params: {
    location: location
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}-${environmentName}-logs'
    appinsightsName: '${abbrs.insightsComponents}-${environmentName}'
    tags: tags
  }
}

module asp 'base/asp.bicep' = {
  name: '${deployment().name}-apim'
  params: {
    location: location
    aspName: aspName
  }
}

module openai 'open-ai/main.bicep' = {
  name: '${deployment().name}-openai'
  params: {
    location: location
    openAiEmbeddingModelName: 'Ada002Embedding'
    openAiModelName: 'Gpt35Turbo0613'
    //openAiModelGpt4Name: 'Gpt4'
    openAiModelGpt4Name: ''
    openAiLocation: openAiLocation
    openAiResourceName: openAiName
    privateDnsZoneId: vnet.outputs.openAiPrivateDnsZoneId
    privateEndpointSubnetId: vnet.outputs.privateEndpointSubnetId
    tags: tags
  }
}

module openAiCentralCommand 'apps/main.bicep' = {
  name: '${deployment().name}-centralcommand'
  params: {
    aspId: asp.outputs.aspId
    azureMonitorWorkspaceId: core.outputs.logAnalyticsId
    azureMonitorWorkspaceName: core.outputs.logAnalyticsName
    openAiModelName: openai.outputs.modelName
    openAiUrl: openai.outputs.openAiEndpoint
    privateDnsZoneId: appServicePrivateDnsZoneId
    privateEndpointSubnetId: devBoxNetworkPrivateEndpointSubnetId
    sampleAppName: appName
    vnetIntegrationSubnetId: vnet.outputs.vnetIntegrationSubnetId
    location: location
  }
}

// Add outputs from the deployment here, if needed.
//
// This allows the outputs to be referenced by other bicep deployments in the deployment pipeline,
// or by the local machine as a way to reference created resources in Azure for local development.
// Secrets should not be added here.
//
// Outputs are automatically saved in the local azd environment .env file.
// To see these outputs, run `azd env get-values`,  or `azd env get-values --output json` for json output.
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
