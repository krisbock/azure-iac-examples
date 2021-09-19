#TODO
# prompt for passwords
# use KV + digicert



rgName='ddos-proxy-rg'
adminUsername='localadmin'
adminPassword='620e38a2-8c35-4055-a10a-8e48dd5b3e73'
location='australiaeast'
deploymentName='ddos-proxy-deployment'
hostname='akl1.fscale.nz'
sshPublicKey=$(cat ~/.ssh/id_rsa.pub)
vmssInstanceCount=3
appGwyHostName='akl1.fscale.nz'
aRecordName='akl1' 
dnsZoneName='fscale.nz'
forceUpdateTag=$(date +%N)
dnsResourceGroupName='ddos-proxy-rg'


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

az deployment group create \
    --name $deploymentName \
    --resource-group $rgName \
    --template-file ./main.bicep \
    --parameters adminUsername=$adminUsername \
    --parameters adminPassword=$adminPassword \
#    --parameters pfxCert="$cert" \
#    --parameters pfxCertPassword=$certPassword \
    --parameters appGwyHostName=$hostName \
    --parameters vmssInstanceCount=$vmssInstanceCount \
    --parameters vmssCustomScriptUri=$CONTAINER_URI \
    --parameters appGwyHostName=$appGwyHostName \
    --parameters sshPublicKey="$sshPublicKey" \
    --parameters dnsResourceGroupName=$dnsResourceGroupName \
    --parameters dnsZoneName=$dnsZoneName \
    --parameters dnsARecordName=$aRecordName \
    --parameters forceUpdateTag=$forceUpdateTag \
    --parameters storageAccountName=$STORAGE_ACCOUNT_NAME
