param location string
var virtualNetworkName = 'vnet-workshop'
var subnetName ='demoSubnet'
var subnetAddressPrefix           ='10.1.0.0/24'
var vnetAddressPrefix = '10.1.0.0/16'
var rgDemo = 'rg-workshop'
var rgSharedDemo ='rg-workshop-shared'
var keyVaultName ='kv-workshop-demo'
var privateEndpoint_KvName = 'pe-kv-demo'
var privateLinkConnexionService_kvName = 'plcs-kv-workshop-demo'
var privateDnsZonevirtualNetworkLinks_kvName = 'vli-apps-kv-workshop-demo'

targetScope = 'subscription'

// Création des groupes de ressources

module rg_apps_security 'modules/resource_group.bicep' = {
  name: rgDemo
  params: {
    location: location
    name: rgDemo
  }
}

module keyvault 'modules/key_vault.bicep' = {
  scope: resourceGroup(rgDemo)
  name: keyVaultName
  params: {
    location: location
    keyvaultName: keyVaultName
    
  }

  dependsOn :   [
    rg_apps_security
  ]
}

//VNET

module vnet 'modules/vnet.bicep' = { 
  scope: resourceGroup(rgDemo)
  name: virtualNetworkName
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    vnetAddressPrefix: vnetAddressPrefix

  }
  dependsOn :   [
    rg_apps_security
  ]
}
module subnets 'modules/subnets.bicep' = { 
  scope: resourceGroup(rgDemo)
  name: subnetName
  params: {
    
    virtualNetworkName: virtualNetworkName
    subnetName : subnetName
    addressPrefix: subnetAddressPrefix

  }

  dependsOn :   [
    vnet
  ]
}

var keyVaultprivateDnsZoneName = 'privatelink.vaultcore.azure.net'
var keyVaultprivateDnsZoneGroupName = 'rgSharedDns'

module rg_sharedDns 'modules/resource_group.bicep' = {
  name: rgSharedDemo
  params: {
    location: location
    name: keyVaultprivateDnsZoneGroupName
  }
}


module keyvaultPrivateDnsZone 'modules/private_dns_zone.bicep' = {
  name: keyVaultprivateDnsZoneName 
  scope: resourceGroup(keyVaultprivateDnsZoneGroupName)

  params: {
    privateDnsZoneName : keyVaultprivateDnsZoneName
    location: 'global'
    
  }
}

var privateDnsZoneName = 'privatelink.vaultcore.azure.net'
var pvtEndpointDnsGroupName  = '${privateEndpoint_KvName}/mydnsgroupname'

module keyvaultPrivateEndpoint 'modules/private_endpoint.bicep' = { 
  scope: resourceGroup(rgDemo)
  name: privateEndpoint_KvName
  params: {
    location: location
    privateEndpointName: privateEndpoint_KvName
    privateDnsZoneName : privateDnsZoneName
    pvtEndpointDnsGroupName: pvtEndpointDnsGroupName
    virtualNetworkId: vnet.outputs.id
    privateLinkConnexionService_kvName: privateLinkConnexionService_kvName
    privateDnsZonevirtualNetworkLinks_kvName: privateDnsZonevirtualNetworkLinks_kvName
    subnetId: '${vnet.outputs.id}/subnets/${subnetName}'
    privateLinkServiceId: keyvault.outputs.id
  }

  dependsOn :   [
    vnet, keyvault
  ]
}
