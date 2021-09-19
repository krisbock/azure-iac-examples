param adminUserObjectId string

var prefix = uniqueString(resourceGroup().id)
var keyVaultName = '${prefix}-kv'

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${prefix}-kv-user'
  location: resourceGroup().location
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  location: resourceGroup().location
  name: keyVaultName
  properties: {
    enableSoftDelete: true
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        objectId: userIdentity.properties.principalId
        tenantId: subscription().tenantId
        permissions: {
          certificates: [
            'list'
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
      {
        objectId: adminUserObjectId
        tenantId: subscription().tenantId
        permissions: {
          certificates: [
            'all'
          ]
        }
      }      
    ]
  }
}

output keyVaultName string = keyVault.name
output userIdentityId string = userIdentity.id
