#!/bin/bash

set -e

read -rp 'Enter subscription name: ' subvar
read -rp 'Enter resource group name: ' rsgvar
read -rp 'Enter storage account name: ' stvar

# set storage account to private
printf "\nSetting storage account %s to private...\n" "$stvar"

az storage account update --subscription "$subvar" -g "$rsgvar" --name "$stvar" \
--allow-blob-public-access false \
--query '{storageAccountName:name, allowBlobPublicAccess:allowBlobPublicAccess}'

# turn on static website
printf "\nTurning on static website for storage account %s...\n" "$stvar"

az storage blob service-properties update --subscription "$subvar" \
--account-name "$stvar" --static-website true \
--query '{staticWebsiteEnabled:staticWebsite.enabled}' --only-show-errors

# get all containers for storage account
containers=($(az storage container list --auth-mode login --subscription "$subvar" \
--account-name "$stvar" -o tsv --query '[?name!=`$web`].name'))

printf "\nTotal containers in storage account %s: ${#containers[@]}\n" "$stvar"
printf '%s\n' "${containers[@]}"

# copy contents of all containers to $web container
for container in "${containers[@]}"; do
  printf "\nCopying contents of container %s into the \$web container...\n" "$container"

  az storage blob copy start-batch --account-name "$stvar" \
  --source-container "$container" --destination-container "\$web/$container" \
  --only-show-errors
done
