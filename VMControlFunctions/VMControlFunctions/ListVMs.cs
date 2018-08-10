using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.Management.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Authentication;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;

namespace VMControlFunctions
{
    public static class ListVMs
    {
        [FunctionName("ListVMs")]
        public static async Task<HttpResponseMessage> Run([HttpTrigger(AuthorizationLevel.Function,"post", Route = null)]HttpRequestMessage req, TraceWriter log)
        {
            log.Info("Getting request body params");
            dynamic data = await req.Content.ReadAsAsync<object>();
            string subscriptionId = data?.subscriptionId;
           
            if (subscriptionId == null)
            {
                return req.CreateResponse(HttpStatusCode.BadRequest, "Please pass subscriptionId in the request body");
            }


            log.Info("Setting credentials from MSI");
            AzureCredentialsFactory f = new AzureCredentialsFactory();
            var msi = new MSILoginInformation(MSIResourceType.AppService);

            var msiCred = f.FromMSI(msi, AzureEnvironment.AzureGlobalCloud);

            var azureAuth = Azure.Configure()
                             .WithLogLevel(HttpLoggingDelegatingHandler.Level.BodyAndHeaders)
                             .Authenticate(msiCred);

            log.Info("Authenticating with Azure using MSI");
            var azure = azureAuth.WithSubscription(subscriptionId);

            log.Info("Getting list of VMs");
            var vms = azure.VirtualMachines.List();

            log.Info("Creating stringlist");
            var vmstringlist = string.Join(", ", (from vm in vms
                                                 select vm.Name).ToList());
            log.Info("Debug: " + vmstringlist);

            var vmDto = (from vm in vms
                         select new { name = vm.Name, powerstate = vm.PowerState.ToString(), resourcegroupname = vm.ResourceGroupName }).ToList();


            return req.CreateResponse(HttpStatusCode.OK, vmDto);
        }
    }
}
