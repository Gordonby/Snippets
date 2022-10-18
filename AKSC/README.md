# AKSC

AKS Construction is a bicep based infrastructure as code project to accelerate AKS deployments. It uses a web app (Helper) to configure the clusters.

## Sample Configs

These links configure the helper options to illustrate AKS Environment configurations for different scenarios

Scenario | Helper link | Post Deploy Config
-------- | ----------- | ------------------
Simple Ingress, Restricted Egress | [helper](https://azure.github.io/AKS-Construction/?net.afw=true&addons.registry=none&addons.ingress=none&addons.csisecret=none&cluster.SystemPoolType=none&cluster.agentCount=1&cluster.maxCount=3&cluster.upgradeChannel=none&cluster.apisecurity=none&deploy.clusterName=simInFwOut&deploy.rg=gordon) | kubectl apply -f https://raw.githubusercontent.com/Gordonby/Snippets/master/AKS/Azure-Vote-Labelled.yml
