param frontDoorName string
param proxyApi object = {
  name: 'proxyApi'
  frontendHostname: null
  backendHostname: null
}
param proxyWeb object = {
  name: 'proxyWeb'
  frontendHostname: null
  backendHostname: null
}
param api object = {
  name: 'api'
  frontendHostname: null
  backendHostname: null
}
param spa object = {
  name: 'spa'
  frontendHostname: null
  backendHostname: null
}

var loadBalancingSettingsName = 'loadBalancingSettings'
var healthProbeSettingsName = 'healthProbeSettings'

resource frontDoor 'Microsoft.Network/frontDoors@2020-01-01' = {
  name: frontDoorName
  location: 'global'
  properties: {
    enabledState: 'Enabled'
    frontendEndpoints: [
      {
        name: proxyApi.name
        properties: {
          hostName: proxyApi.frontendHostname
          sessionAffinityEnabledState: 'Disabled'
        }
      }
      {
        name: proxyWeb.name
        properties: {
          hostName: proxyWeb.frontendHostname
          sessionAffinityEnabledState: 'Disabled'
        }
      }
      {
        name: api.name
        properties: {
          hostName: api.frontendHostname
          sessionAffinityEnabledState: 'Disabled'
        }
      }
      {
        name: spa.name
        properties: {
          hostName: spa.frontendHostname
          sessionAffinityEnabledState: 'Disabled'
        }
      }
    ]
    loadBalancingSettings: [
      {
        name: loadBalancingSettingsName
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
        }
      }
    ]
    healthProbeSettings: [
      {
        name: healthProbeSettingsName
        properties: {
          path: '/'
          protocol: 'Https'
          intervalInSeconds: 120
        }
      }
    ]
    backendPools: [
      {
        name: 'proxyApiBackend'
        properties: {
          backends: [
            {
              address: proxyApi.backendHostname
              backendHostHeader: proxyApi.backendHostname
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }
          ]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoorName, loadBalancingSettingsName)
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, healthProbeSettingsName)
          }
        }
      }
      {
        name: 'proxyWebBackend'
        properties: {
          backends: [
            {
              address: proxyWeb.backendHostname
              backendHostHeader: proxyWeb.backendHostname
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }
          ]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoorName, loadBalancingSettingsName)
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, healthProbeSettingsName)
          }
        }
      }
      {
        name: 'apiBackend'
        properties: {
          backends: [
            {
              address: api.backendHostname
              backendHostHeader: api.backendHostname
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }
          ]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoorName, loadBalancingSettingsName)
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, healthProbeSettingsName)
          }
        }
      }
      {
        name: 'spaBackend'
        properties: {
          backends: [
            {
              address: spa.backendHostname
              backendHostHeader: spa.backendHostname
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }
          ]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', frontDoorName, loadBalancingSettingsName)
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', frontDoorName, healthProbeSettingsName)
          }
        }
      }
    ]
    routingRules: [
      {
        name: proxyApi.name
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, proxyApi.name)
            }
          ]
          acceptedProtocols: [
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoorName, proxyApi.name)
            }
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: '${proxyApi.name}-httpRedirect'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, proxyApi.name)
            }
          ]
          acceptedProtocols: [
            'Http'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorRedirectConfiguration'
            redirectProtocol: 'HttpsOnly'
            redirectType: 'PermanentRedirect'
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: proxyWeb.name
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, proxyWeb.name)
            }
          ]
          acceptedProtocols: [
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoorName, proxyWeb.name)
            }
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: '${proxyWeb.name}-httpRedirect'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, proxyWeb.name)
            }
          ]
          acceptedProtocols: [
            'Http'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorRedirectConfiguration'
            redirectProtocol: 'HttpsOnly'
            redirectType: 'PermanentRedirect'
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: api.name
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, api.name)
            }
          ]
          acceptedProtocols: [
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoorName, api.name)
            }
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: '${api.name}-httpRedirect'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, api.name)
            }
          ]
          acceptedProtocols: [
            'Http'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorRedirectConfiguration'
            redirectProtocol: 'HttpsOnly'
            redirectType: 'PermanentRedirect'
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: spa.name
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, spa.name)
            }
          ]
          acceptedProtocols: [
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'HttpsOnly'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoorName, spa.name)
            }
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: '${spa.name}-httpRedirect'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, spa.name)
            }
          ]
          acceptedProtocols: [
            'Http'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorRedirectConfiguration'
            redirectProtocol: 'HttpsOnly'
            redirectType: 'PermanentRedirect'
          }
          enabledState: 'Enabled'
        }
      }
    ]
  }
}

output frontDoorId string = frontDoor.properties.frontdoorId
