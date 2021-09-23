param frontDoorName string = '${uniqueString(resourceGroup().id)}-fd'
param dnsResourceGroupName string
param dnsZoneName string
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

var frontDoorHostname = '${frontDoorName}.azurefd.net'
var afdVerifyHostname = 'afdverify.${frontDoorHostname}'

var proxyApiRecordName = split(proxyApi.frontendHostname, '.')[0]

module proxyApiCName './modules/dnsCName.bicep' = {
  name: proxyApi.name
  scope: resourceGroup(dnsResourceGroupName)
  params: {
    dnsZoneName: dnsZoneName
    recordName: proxyApiRecordName
    hostname: frontDoorHostname
  }
}

module proxyApiVerifyCName './modules/dnsCName.bicep' = {
  name: '${proxyApi.name}-verify'
  scope: resourceGroup(dnsResourceGroupName)
  params: {
    dnsZoneName: dnsZoneName
    recordName: 'afdverify.${proxyApiRecordName}'
    hostname: afdVerifyHostname
  }
}

var proxyWebRecordName = split(proxyApi.frontendHostname, '.')[0]

module proxyWebCName './modules/dnsCName.bicep' = {
  name: proxyWeb.name
  scope: resourceGroup(dnsResourceGroupName)
  params: {
    dnsZoneName: dnsZoneName
    recordName: split(proxyWeb.frontendHostname, '.')[0]
    hostname: frontDoorHostname
  }
}

module proxyWebVerifyCName './modules/dnsCName.bicep' = {
  name: '${proxyWeb.name}-verify'
  scope: resourceGroup(dnsResourceGroupName)
  params: {
    dnsZoneName: dnsZoneName
    recordName: 'afdverify.${proxyWebRecordName}'
    hostname: afdVerifyHostname
  }
}

module frontDoor './modules/frontDoor.bicep' = {
  name: 'frontDoor'
  params: {
    frontDoorName: frontDoorName
    customEndpoint1: proxyApi
    customEndpoint2: proxyWeb
  }
}
