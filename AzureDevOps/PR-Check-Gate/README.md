# Azure DevOps Pull Request Policy Checking

When you run pipelines in Azure DevOps as part of a build policy, the selected pipeline will start immediately with the Pull Request.
Often this is the desired behavior, you want to compile your code and run your unit tests, ready for the PR approvers to see.
However, sometimes you won't want to burn pipeline minutes or compute time running your build until the PR has met some of the other Pull Request Policies (such as Work item association, or specific approvers).

## The Process

You'll need to use an Environment as part of your pipeline.  On the Environment, we'll add an Approval that will run some code to verify the other Pull Request policies have been approved/met.

![overview.png](overview.png)

*Components*
1. A [Sample pipeline file is provided](azure-pipelines.yml), it'll create the Environment stubs for you in Azure DevOps. If you're using your own existing pipeline file, make sure to declare an `Environment`
1. A deployed `Azure Function` (of type PowerShell), which uses [this PowerShell script](Posh-AzFunction-ValidatePRPolicyFromBuildId.ps1). You won't need to change this code, as the variable components will be defined in your Environment Approval Gate.
1. An `Environment approval gate`, defined to call the Azure Function.  A [sample configuration image](EnvApprovalFunctionConfig.png) is provided in this folder.

## The Azure Function

Environment Approval Gates can be super helpful in providing the right governance for your pipelines, however most of the available gate options are quite limited in their capability. The nature of what we're trying to achieve is a series of checks which can only take place inside an Azure Function or API call. 

`We're limited in the available Azure DevOps variables from the Approval Gates, namely the absence of the PullRequest. We therefore need to begin with the most relevant variable, the BuildId`

*Function steps*
1. Take a number of parameters from the Azure DevOps request (namely the BuildId, ProjectId and OrganisationName)
1. Call the Azure DevOps API to obtain the Build details from the provided BuildId, to obtain the PullRequestId
1. Call the Azure DevOps API to obtain the Pull Request Policy details
1. Loop through all the PR Policies to evaluate blocking policies that are not yet approved
1. Respond to the Azure DevOps request with an indicator to proceed, and a list of the Blocking Policies

## Security

The Azure Function will either use an ADO security access token which is passed to it by the ADO Approval gate, or from the Azure Function Application Settings, depending on your preferences.
