#!/bin/bash

set -e

read -rp 'Enter subscription name: ' subvar
read -rp 'Enter resource group name: ' rsgvar

# get list of storage accounts
printf "\nGetting list of storage accounts...\n"

storage_accounts=($(az storage account list --subscription "$subvar" -g "$rsgvar" -o tsv \
--query '[].name'))

# if there are storage accounts
if [ ${#storage_accounts} -ne 0 ]; then
  printf "Total storage accounts: %s\n" "${#storage_accounts[@]}"
  printf '%s\n' "${storage_accounts[@]}"

  for storage_account in "${storage_accounts[@]}"; do
    # set storage accounts to private
    printf "\nSetting storage account %s to private...\n" "$storage_account"

    az storage account update --subscription "$subvar" -g "$rsgvar" --name "$storage_account" \
    --allow-blob-public-access false \
    --query '{storageAccountName:name, allowBlobPublicAccess:allowBlobPublicAccess}'

    # turn on static website
    printf "\nTurning on static website for storage account %s...\n" "$storage_account"

    az storage blob service-properties update --subscription "$subvar" \
    --account-name "$storage_account" --static-website true \
    --query '{staticWebsiteEnabled:staticWebsite.enabled}' --only-show-errors

    # get all containers for current storage account
    containers=($(az storage container list --auth-mode login --subscription "$subvar" \
    --account-name "$storage_account" -o tsv --query '[?name!=`$web`].name'))

    printf "\nTotal containers in storage account %s: ${#containers[@]}\n" "$storage_account"
    printf '%s\n' "${containers[@]}"

    # copy contents of all containers to $web container
    for container in "${containers[@]}"; do
      printf "\nCopying contents of container %s into the \$web container...\n" "$container"

      az storage blob copy start-batch --account-name "$storage_account" \
      --source-container "$container" --destination-container "\$web/$container" \
      --only-show-errors
    done

    printf '\n'
  done

else
  printf '\nNo storage accounts detected, exiting...\n'
  exit 0
fi
