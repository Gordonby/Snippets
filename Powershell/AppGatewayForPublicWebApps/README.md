# Application Gateway for Public Web Apps

### CreateAppGW-ForWebApp
Ref: https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-web-app-powershell

Uses much of the Powershell Script fromm this example, with the notable exception of the fact that an *Existing* Web App will be used - rather than using a random one from Github.

### CreateAppGW-ForWebApp-v2
Ref: https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-web-app-powershell

Uses much of the Powershell Script fromm this example
1. Existing web app will be used
1. Where custom domains have been configured on web apps this is accounted for
1. Object naming is derived from parameters
1. A multi-site listener will be used where necessary


### Applying a IP restriction to your Web App
See : https://docs.microsoft.com/en-gb/azure/app-service/app-service-ip-restrictions

Note that an Application Gatway IP address is Dynamic, not Static.  This will undoubtably change at some point.