#!/bin/bash

set -e

read -p 'Enter subscription name: ' subvar
read -p 'Enter resource group name: ' rsgvar
read -p 'Enter storage account name: ' stvar

# set storage account to private
printf "\nSetting storage account $stvar to private...\n"

az storage account update --subscription $subvar -g $rsgvar --name $stvar \
--allow-blob-public-access false \
--query '{storageAccountName:name, allowBlobPublicAccess:allowBlobPublicAccess}'

# turn on static website
printf "\nTurning on static website for storage account $stvar...\n"

az storage blob service-properties update --subscription $subvar \
--account-name $stvar --static-website true \
--query '{staticWebsiteEnabled:staticWebsite.enabled}' --only-show-errors

# get all containers for storage account
containers=($(az storage container list --auth-mode login --subscription $subvar \
--account-name $stvar -o tsv --query '[?name!=`$web`].name'))

printf "\nTotal containers in storage account $stvar: ${#containers[@]}\n"
printf '%s\n' "${containers[@]}"

# copy contents of all containers to $web container
for container in ${containers[@]}; do
  printf "\nCopying contents of container $container into the \$web container...\n"

  az storage blob copy start-batch --account-name $stvar \
  --source-container $container --destination-container "\$web/$container" \
  --only-show-errors
done
