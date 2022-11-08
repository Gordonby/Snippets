# Azure Subscription Bootstrap

## Creating automation

This account runs 3 runbooks daily.
It will flag resource groups for deletion, and clear the contents of other resource groups all based on tags.

The tag that is evaluated is `Cleanup`. 

- When set to `Automatically` then the resource group will be cleared each night. 
- When set to `Never` the resource group will be ignored. 
- When there is no tag, a cleanup tag will be added on Day1, then on Day2 the entire resource group will be removed.

```bash
az deployment sub create -u https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureSubscriptionBootstrap/main.json -n SubscriptionMaintenance -l WestEurope
```