param location string = resourceGroup().location
param name string
param vnetAddressPrefix string
param gatewaySubnetPrefix string
param integrationSubnetAddressPrefix string
param privateLinkSubnetAddressPrefix string
param dbSubnetAddressPrefix string

var affix = substring(uniqueString(resourceGroup().id), 0, 6)
var vnetName = '${name}-${affix}'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
      {
        name: 'vnet-integration-subnet'
        properties: {
          addressPrefix: integrationSubnetAddressPrefix
          delegations: [
            {
              name: 'app-server-delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'private-link-subnet'
        properties: {
          addressPrefix: privateLinkSubnetAddressPrefix
          privateLinkServiceNetworkPolicies: 'Disabled'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'db-subnet'
        properties: {
          addressPrefix: dbSubnetAddressPrefix
          delegations: [
            {
              name: 'flex-server-delegation'
              properties: {
                serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
              }
            }
          ]
        }
      }
    ]
  }
}

output vnet object = vnet
output vnetId string = vnet.id
output vnetName string = vnet.name
output gatewaySubnetId string = vnet.properties.subnets[0].id
output integrationSubnetId string = vnet.properties.subnets[1].id
output privateLinkSubnetId string = vnet.properties.subnets[2].id
output dbSubnetId string = vnet.properties.subnets[3].id
