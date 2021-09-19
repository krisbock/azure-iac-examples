#!/bin/bash
set -e


rgName='ddos-proxy-rg'
adminUsername='localadmin'
adminPassword='620e38a2-8c35-4055-a10a-8e48dd5b3e73'
location='australiaeast'
deploymentName='ddos-proxy-deployment'
hostname='ddemo.fscale.nz'
sshPublicKey=$(cat ~/.ssh/id_rsa.pub)
vmssInstanceCount=3
appGwyHostName='ddemo.fscale.nz'
aRecordName='ddemo' 
dnsZoneName='fscale.nz'
forceUpdateTag=$(date +%N)
dnsResourceGroupName='ddos-proxy-rg'
certName='ddos-proxy-appgw-ssl-cert'

az group create --name $rgName --location $location

az deployment group create \
    --name storageDeployment \
    --resource-group $rgName \
    --template-file ./modules/storage.bicep \
    --parameters=sasTokenExpiry='2022-07-01T00:00:00Z'

CONTAINER_NAME=$(az deployment group show --name storageDeployment --resource-group $rgName --query 'properties.outputs.storageContainerName.value' -o tsv)
STORAGE_ACCOUNT_NAME=$(az deployment group show --name storageDeployment --resource-group $rgName --query 'properties.outputs.storageAccountName.value' -o tsv)
CONTAINER_URI=$(az deployment group show --name storageDeployment --resource-group $rgName --query 'properties.outputs.storageContainerUri.value' -o tsv)
SAS_TOKEN=$(az deployment group show --name storageDeployment --resource-group $rgName --query 'properties.outputs.storageAccountSasToken.value' -o tsv)

az storage azcopy blob upload --container $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --source "../app/main" --recursive
az storage azcopy blob upload --container $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --source "../scripts/install.sh" --recursive

# DNS ZONE
az deployment group create -n dnsZoneDeployment -g $rgName --template-file ./modules/dnsZone.bicep --parameters dnsZoneName=$dnsZoneName

echo "NAME SERVERS =============="
az network dns zone show -n $dnsZoneName -g $rgName --query 'nameServers'
echo "==========================="


# Get current User Id 😻
SIGNED_IN_USER_ID=$(az ad signed-in-user show --query 'objectId' -o tsv)

# KEY VAULT
az deployment group create -n keyVaultDeployment -g $rgName --template-file ./modules/keyVault.bicep --parameters adminUserObjectId=$SIGNED_IN_USER_ID

KEYVAULT_NAME=$(az deployment group show --name keyVaultDeployment --resource-group $rgName --query 'properties.outputs.keyVaultName.value' -o tsv)
USER_IDENTITY_ID=$(az deployment group show --name keyVaultDeployment --resource-group $rgName --query 'properties.outputs.userIdentityId.value' -o tsv)

# If Certificate does not exist in Key Vault
if [[ $( az keyvault certificate list --vault-name $KEYVAULT_NAME --include-pending $true --query "length([? name=='${certName}'])" ) == 0 ]]; then
    # Create certificate (Merge CSR manually later)
    export DNS_ZONE_NAME=$dnsZoneName
    export APPGW_HOST_NAME=$appGwyHostName
    envsubst < cert-policy-template.json > cert-policy.json

    echo "CSR ========================"
    az keyvault certificate create --vault-name $KEYVAULT_NAME -n $certName -p @cert-policy.json --query 'csr' -o tsv
    echo "============================"
fi

# Get certificate secret Id
SSL_CERT_KV_SECRET_ID=$( az keyvault certificate show -n $certName --vault-name $KEYVAULT_NAME --query 'sid' -o tsv )

if [[ $SSL_CERT_KV_SECRET_ID = '' ]]; then
    echo "========================================="
    echo "Please Merge signed CSR before continuing"
    echo "========================================="
    exit
fi

az deployment group create \
    --name $deploymentName \
    --resource-group $rgName \
    --template-file ./main.bicep \
    --parameters adminUsername=$adminUsername \
    --parameters adminPassword=$adminPassword \
    --parameters appGwyHostName=$hostName \
    --parameters vmssInstanceCount=$vmssInstanceCount \
    --parameters vmssCustomScriptUri=$CONTAINER_URI \
    --parameters appGwyHostName=$appGwyHostName \
    --parameters sshPublicKey="$sshPublicKey" \
    --parameters dnsResourceGroupName=$dnsResourceGroupName \
    --parameters dnsZoneName=$dnsZoneName \
    --parameters dnsARecordName=$aRecordName \
    --parameters forceUpdateTag=$forceUpdateTag \
    --parameters storageAccountName=$STORAGE_ACCOUNT_NAME \
    --parameters sslCertKeyVaultSecretId=$SSL_CERT_KV_SECRET_ID \
    --parameters userIdentityId=$USER_IDENTITY_ID

echo "READY! https://${appGwyHostName}"