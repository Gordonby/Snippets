using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;

namespace Api1.Controllers
{
    [Route("api/[controller]")]
    public class MessageTestController : Controller
    {
        // GET api/values
        [HttpGet]
        public string Get()
        {
            try
            {
                // create a parameter object for the messaging factory that configures
                // the MSI token provider for Service Bus and use of the AMQP protocol:
                MessagingFactorySettings messagingFactorySettings = new MessagingFactorySettings
                {
                    TokenProvider = TokenProvider.CreateManagedServiceIdentityTokenProvider(ServiceAudience.ServiceBusAudience),
                    TransportType = TransportType.Amqp
                };

                // create the messaging factory using the namespace endpoint name supplied by the user
                MessagingFactory messagingFactory = MessagingFactory.Create($"sb://gordsbus.servicebus.windows.net/",
                    messagingFactorySettings);

                // create a queue client using the queue name supplied by the user
                QueueClient queueClient = messagingFactory.CreateQueueClient("fabrictraffic");
                queueClient.Send(new BrokeredMessage(Encoding.UTF8.GetBytes("Api hit")));

                queueClient.Close();
                messagingFactory.Close();

                return "All good";
            }
            catch (Exception ex)
            {
                return ex.ToString();
            }
            
        }

    }
}
