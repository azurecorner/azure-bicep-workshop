@description('Le nom de la private dns zone')
param privateDnsZoneName  string
@description('La localisation de la private dns zone')
param location  string


@description('Creation d une ressource private dns zone')
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: location
  properties: {}
 }

 output id string = privateDnsZone.id
