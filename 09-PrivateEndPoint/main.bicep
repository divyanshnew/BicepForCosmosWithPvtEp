@description('Name prefix of all the resources')
param NamePrefix string

@description('Location where you want to deploy all the resources')
param location string

@description('Name of the Owner of the resource')
param OwnerName string

@description('Name of the team who is the owner of the resources')
param TeamName string

@description('Vnet address prefix')
param vnetAddressPrefixes string

@description('SQL DB Account kind GlobalDocumentDB')
param dbAccountkind string

@description('name of the DB Account')
param dbAccountName string


module Vnet 'Modules/01-Vnet.bicep' = {
  name: '${NamePrefix}-Vnet'
  params: {
    location: location
    nsgName: '${NamePrefix}-Nsg'
    OwnerName: OwnerName
    TeamName: TeamName
    vnetAddressPrefixes: vnetAddressPrefixes
    vnetName: '${NamePrefix}-Vnet'
  }
}

module CosmosDb 'Modules/02-CosmosDB.bicep' = {
  name: '${NamePrefix}-CosmosDb'
  params: {
    dbAccountkind: dbAccountkind
    dbAccountName: dbAccountName
    location: location
    OwnerName: OwnerName
    sq_db_name: '${NamePrefix}-sqldb'
    sqlContainerName: '${NamePrefix}-sqlContainer'
    TeamName: TeamName
  }
}

module privateEndPoint 'Modules/03-CosmosDbPrivateEndPoint.bicep' = {
  name: '${NamePrefix}-cosmosPrivateLink'
  params: {
    CosmosDbPrivateLink_name: '${NamePrefix}-cosmosPrivateLink'
    dbAccountName: CosmosDb.outputs.cosmosDbAccountName
    location: location
    OwnerName: OwnerName
    PrivateEndPointDnsLinkName: '${NamePrefix}-cosmosPrivateDnsLink'
    privateEndpointName: '${NamePrefix}-cosmosPrivateEp'
    TeamName: TeamName
    vnetName: Vnet.name
  }
}
