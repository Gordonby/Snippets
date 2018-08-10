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
    public static class StartVM
    {
        [FunctionName("StartVM")]
        public static async Task<HttpResponseMessage> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)]HttpRequestMessage req, TraceWriter log)
        {

            log.Info("Getting request body params");
            dynamic data = await req.Content.ReadAsAsync<object>();
            string subscriptionId = data?.subscriptionId;
            string resourceGroupName = data?.resourceGroupName;
            string vmName = data?.vmName;

            if (subscriptionId == null || resourceGroupName == null || vmName == null)
            {
                return req.CreateResponse(HttpStatusCode.BadRequest, "Please pass all 3 required parameters in the request body");
            }

            log.Info("Setting authentication to use MSI");
            AzureCredentialsFactory f = new AzureCredentialsFactory();
            var msi = new MSILoginInformation(MSIResourceType.AppService);

            var msiCred = f.FromMSI(msi, AzureEnvironment.AzureGlobalCloud);

            var azureAuth = Azure.Configure()
                             .WithLogLevel(HttpLoggingDelegatingHandler.Level.BodyAndHeaders)
                             .Authenticate(msiCred);

            log.Info("Authenticating with Azure using MSI");
            var azure = azureAuth.WithSubscription(subscriptionId);

            log.Info("Acquiring VM from Azure");
            var vm = azure.VirtualMachines.GetByResourceGroup(resourceGroupName, vmName);

            log.Info("Checking VM Id");
            log.Info(vm.Id.ToString());

            log.Info("Checking VM Powerstate");
            log.Info("VM Powerstate : " + vm.PowerState.ToString());

            bool vmStarting = false;
            if (vm.PowerState.ToString() == "PowerState/running")
            {
                log.Info("VM is already running");
            }
            else
            {
                log.Info("Starting vm " + vmName);
                await vm.StartAsync();
                vmStarting = true;
            }

            return vmStarting == false
            ? req.CreateResponse(HttpStatusCode.OK, "VM was already started")
            : req.CreateResponse(HttpStatusCode.OK, "VM started");
        }
    }
}
