param dnsZoneName string 
param recordName string 
param hostname string

resource dns 'Microsoft.Network/dnszones@2015-05-04-preview' existing = {
  name: dnsZoneName
}
resource cname 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dns
  name: recordName
  properties: {
    TTL: 1800
    CNAMERecord: {
        cname: hostname
      }
  }
}
