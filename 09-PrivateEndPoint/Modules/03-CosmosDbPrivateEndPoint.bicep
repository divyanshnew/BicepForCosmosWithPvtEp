@description('Name of the Virtual Network')
param vnetName string

@description('Name of the cosmosd Db private link')
param CosmosDbPrivateLink_name string

@description('Name of the Private Endpoint')
param privateEndpointName string

@description('Name of the PrivateEndPointDnsLink')
param PrivateEndPointDnsLinkName string

@description('Location where the resources needs to be deployed')
param location string 

@description('name of the cosmos DB Account')
param dbAccountName string

@description('Name of The Owner of the resource')
param OwnerName string

@description('Name of the team who owns the resource')
param TeamName string
///////////////////////////////////////////////////////////////////////////////// Cosmos Db Private EndPoint ///////////////////////////////////////////////////////////////////////
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource CosmosPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.documents.azure.com'
  location: 'global'
  tags: {
    Owner: OwnerName
    team: TeamName
  }
}

resource CosmosDbPrivateLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: CosmosDbPrivateLink_name
  location: 'global'
  parent: CosmosPrivateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
  tags: {
    Owner: OwnerName
    team: TeamName
  }
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' existing = {
  name: dbAccountName
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-privateEndpoint'
        properties: {
          privateLinkServiceId: cosmosDbAccount.id
          groupIds: [
            'SQL'
          ]
        }
      }
    ]
    subnet: {
      id: virtualNetwork.properties.subnets[0].id
    }
  }
  tags: {
    Owner: OwnerName
    team: TeamName
  }
}

resource PrivateEndPointDnsLink 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  name: PrivateEndPointDnsLinkName
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.documents.azure.com'
        properties: {
          privateDnsZoneId: CosmosPrivateDnsZone.id
        }
      }
    ]
  }
}
