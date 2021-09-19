param appGatewayIpAddress string
param dnsZoneName string 
param recordName string 

resource dns 'Microsoft.Network/dnszones@2015-05-04-preview' existing = {
  name: dnsZoneName
}
resource arecord 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  parent: dns
  name: recordName
  properties: {
    TTL: 1800
    ARecords: [
      {
        ipv4Address: appGatewayIpAddress
      }
    ]
  }
}
