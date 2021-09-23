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

var apiRecordName = split(proxyApi.frontendHostname, '.')[0]

module apiCName './modules/dnsCName.bicep' = {
  name: api.name
  scope: resourceGroup(dnsResourceGroupName)
  params: {
    dnsZoneName: dnsZoneName
    recordName: split(api.frontendHostname, '.')[0]
    hostname: frontDoorHostname
  }
}

module apiVerifyCName './modules/dnsCName.bicep' = {
  name: '${api.name}-verify'
  scope: resourceGroup(dnsResourceGroupName)
  params: {
    dnsZoneName: dnsZoneName
    recordName: 'afdverify.${apiRecordName}'
    hostname: afdVerifyHostname
  }
}

var spaRecordName = split(proxyApi.frontendHostname, '.')[0]

module spaCName './modules/dnsCName.bicep' = {
  name: spa.name
  params: {
    dnsZoneName: dnsZoneName
    recordName: split(spa.frontendHostname, '.')[0]
    hostname: frontDoorHostname
  }
}

module spaVerifyCName './modules/dnsCName.bicep' = {
  name: '${spa.name}-verify'
  scope: resourceGroup(dnsResourceGroupName)
  params: {
    dnsZoneName: dnsZoneName
    recordName: 'afdverify.${spaRecordName}'
    hostname: afdVerifyHostname
  }
}

module frontDoor './modules/frontDoor.bicep' = {
  name: 'frontDoor'
  params: {
    frontDoorName: frontDoorName
    proxyApi: proxyApi
    proxyWeb: proxyWeb
    api: api
    spa: spa
  }
}
