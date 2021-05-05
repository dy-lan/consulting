A client needed a solution to prep their Azure blob storage accounts for use with the Azure Storage static website feature. Due to their enterprise security policy, they also needed to make all storage accounts private.

* Run `prep_storage_account.sh` to target a single storage account
* Run `prep_storage_accounts.sh` to target all storage accounts in a specified resource group

The scripts will set the storage accounts private and copy all contents from each container into a new directory (with the same name as its source container) within the `$web` container.
