@description('Name of the Virtual Network')
param vnetName string

@description('Location where the resources needs to be deployed')
param location string 

@description('Addreess space for the virtual Network 10.0.0.0/16')
param vnetAddressPrefixes string

@description('Name of the NSG')
param nsgName string

@description('Name of The Owner of the resource')
param OwnerName string

@description('Name of the team who owns the resource')
param TeamName string

var ListOfsubnets = subnetList
@description('List of the subnets to be created with its properties')
param subnetList array = [
  {
    name: 'subnet1'
    subnetPrefix: '12.0.1.0/24'
  }
  {
    name: 'subnet2'
    subnetPrefix: '12.0.2.0/24'
  }
]

var nsgRules =  [ 
  {
  name: 'allowAllNetwork'
  properties: {
    description: 'description'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 101
    direction: 'Inbound'
  }
}
{
  name: 'allowSql'
  properties: {
    description: 'description'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3306'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
  }
}
]
///////////////////////////////////////////////////////////////////////////////// Vnet ///////////////////////////////////////////////////////////////////////
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixes
      ]
    }
  }
  tags: {
    Owner: OwnerName
    team: TeamName
  }
}
///////////////////////////////////////////////////////////////////////////////// Subnets///////////////////////////////////////////////////////////////////////
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = [for subnets in ListOfsubnets: {
  parent: virtualNetwork
  name: subnets.name
  properties: { 
    addressPrefix: subnets.subnetPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}]
///////////////////////////////////////////////////////////////////////////////// Network Security Group ///////////////////////////////////////////////////////////////////////
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: nsgRules
  }
  tags: {
    Owner: OwnerName
    team: TeamName
  }
}
