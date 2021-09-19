param dnsZoneName string 

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: dnsZoneName
  location: 'global'
  properties: {
    zoneType: 'Public'
  }
}
