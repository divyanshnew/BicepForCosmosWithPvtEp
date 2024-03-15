@description('Location where the resources needs to be deployed')
param location string 

@description('name of the cosmos DB Account')
param dbAccountName string

@description('Cosmos DB Account kind')
param dbAccountkind string

@description('Name of the cosmosdb database')
param sq_db_name string

@description('SQL container name')
param sqlContainerName string

@description('Name of The Owner of the resource')
param OwnerName string

@description('Name of the team who owns the resource')
param TeamName string
///////////////////////////////////////////////////////////////////////////////// Cosmos Db ///////////////////////////////////////////////////////////////////////
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: dbAccountName
  location: location
  kind: dbAccountkind
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
  tags: {
    Owner: OwnerName
    team: TeamName
  }
}
output cosmosDbAccountName string = cosmosDbAccount.name

resource sqlDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  name: sq_db_name
  parent: cosmosDbAccount
  properties: {
    resource: {
      id: sq_db_name
    }
    options: {}
  }
  tags: {
    Owner: OwnerName
    team: TeamName
  }
}

resource sqlContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
  parent: sqlDb 
  name: sqlContainerName
  properties: {
    resource: {
      id: sqlContainerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
    }
    options: {}
  }
  tags: {
    Owner: OwnerName
    team: TeamName
  }
}
