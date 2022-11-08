# Azure Subscription Bootstrap

## Creating automation

The Automation Account runs 3 runbooks daily.
It will flag resource groups for deletion, and clear the contents of other resource groups all based on tags.

The tag that is evaluated is `Cleanup`. 

- When set to `Automatically` then the resource group will be cleared each night. The use case here is that you'll want to keep a Resource Group because of the RBAC that has been assigned to it.
- When set to `Never` the resource group will be ignored. This tag should be used for any resource group that contains a resource you want to persist in your subscription.
- When there is no tag, a cleanup tag will be added on Day1, then on Day2 the entire resource group will be removed. The use case here is for quick deployments that you've forgotten about.

```bash
az deployment sub create -u https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureSubscriptionBootstrap/main.json -n SubscriptionMaintenance -l WestEurope
```