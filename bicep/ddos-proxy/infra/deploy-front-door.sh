#!/bin/bash
set -e

rgName='ddos-proxy-rg'
dnsResourceGroupName=$rgName
dnsZoneName='fscale.nz'

proxyApi='{"name":"proxyApi","frontendHostname":"apip.fscale.nz","backendHostname":"ddemo.fscale.nz"}'
proxyWeb='{"name":"proxyWeb","frontendHostname":"wwwp.fscale.nz","backendHostname":"ddemo.fscale.nz"}'
api='{"name":"api","frontendHostname":"api.fscale.nz","backendHostname":"ddemo.fscale.nz"}'
spa='{"name":"spa","frontendHostname":"www.fscale.nz","backendHostname":"ddemo.fscale.nz"}'

az deployment group create --name frontDoorDeployment --resource-group $rgName --template-file ./main-front-door.bicep \
    --parameters dnsResourceGroupName=$dnsResourceGroupName \
    --parameters dnsZoneName=$dnsZoneName \
    --parameters proxyApi=$proxyApi \
    --parameters proxyWeb=$proxyWeb \
    --parameters api=$api \
    --parameters spa=$spa
