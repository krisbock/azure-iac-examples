/*
  Creates three endpoints (one default and two custom) with the following profile:
  * HTTP permanently redirected to HTTPS
  * Custom Frontend HTTPS requests forwarded to Custom Backend hostname
  * Default Frontend HTTPS requests forwarded to customEndpoint1.backendHostname
  * Front Door managed certificate enabled on both custom frontends

  ** Note that Default Frontend will be created automatically, you don't need to specify it. 
*/
param frontDoorName string

/*
// custom endpoint object Type defined as:
{
  name: 'customEndpoint1'       // a symbolic name that is used for naming resources in Front Door
  frontendHostname: null  // Fully qualified Frontend Hostname, e.g. 'api.contoso.com'
  backendHostname: null   // Fully qualified Backend Hostname, e.g. 'apim.contoso.net'
}
*/
param customEndpoint1 object 
param customEndpoint2 object 

var loadBalancingSettingsName = 'loadBalancingSettings'
var healthProbeSettingsName = 'healthProbeSettings'
var defaultFrontend = 'defaultFrontend'

resource frontDoor 'Microsoft.Network/frontDoors@2020-01-01' = {
  name: frontDoorName
  location: 'global'
  properties: {
    enabledState: 'Enabled'
    frontendEndpoints: [
      {
        name: defaultFrontend
        properties: {
          hostName: '${frontDoorName}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
        }
      }
      {
        name: customEndpoint1.name
        properties: {
          hostName: customEndpoint1.frontendHostname
          sessionAffinityEnabledState: 'Disabled'
        }
      }
      {
        name: customEndpoint2.name
        properties: {
          hostName: customEndpoint2.frontendHostname
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
        name: customEndpoint1.name
        properties: {
          backends: [
            {
              address: customEndpoint1.backendHostname
              backendHostHeader: customEndpoint1.backendHostname
              httpsPort: 443
              httpPort: 80
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
        name: customEndpoint2.name
        properties: {
          backends: [
            {
              address: customEndpoint2.backendHostname
              backendHostHeader: customEndpoint2.backendHostname
              httpsPort: 443
              httpPort: 80
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
        name: 'defaultRoutingRule'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, defaultFrontend)
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
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoorName, customEndpoint1.name)
            }
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: 'defaultRoutingRule-httpRedirect'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, defaultFrontend)
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
        name: customEndpoint1.name
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, customEndpoint1.name)
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
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoorName, customEndpoint1.name)
            }
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: '${customEndpoint1.name}-httpRedirect'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, customEndpoint1.name)
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
        name: customEndpoint2.name
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, customEndpoint2.name)
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
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', frontDoorName, customEndpoint2.name)
            }
          }
          enabledState: 'Enabled'
        }
      }
      {
        name: '${customEndpoint2.name}-httpRedirect'
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', frontDoorName, customEndpoint2.name)
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

  resource customEndpoint1Frontend 'frontendEndpoints' existing = {
    name: customEndpoint1.name
  }

  resource customEndpoint2Frontend 'frontendEndpoints' existing = {
    name: customEndpoint2.name
  }
}

// This resource enables a Front Door-managed TLS certificate on the frontend.
resource endpoint1HttpsConfig 'Microsoft.Network/frontdoors/frontendEndpoints/customHttpsConfiguration@2020-07-01' = {
  parent: frontDoor::customEndpoint1Frontend
  name: 'default'
  properties: {
    protocolType: 'ServerNameIndication'
    certificateSource: 'FrontDoor'
    frontDoorCertificateSourceParameters: {
      certificateType: 'Dedicated'
    }
    minimumTlsVersion: '1.2'
  }
}

resource endpoint2HttpsConfig 'Microsoft.Network/frontdoors/frontendEndpoints/customHttpsConfiguration@2020-07-01' = {
  parent: frontDoor::customEndpoint2Frontend
  name: 'default'
  properties: {
    protocolType: 'ServerNameIndication'
    certificateSource: 'FrontDoor'
    frontDoorCertificateSourceParameters: {
      certificateType: 'Dedicated'
    }
    minimumTlsVersion: '1.2'
  }
}

output frontDoorId string = frontDoor.properties.frontdoorId
