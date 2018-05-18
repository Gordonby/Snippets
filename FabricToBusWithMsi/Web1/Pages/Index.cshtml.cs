using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;

namespace Web1.Pages
{
    public class IndexModel : PageModel
    {
        public string Message { get; set; }

        public void OnGet()
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
                queueClient.Send(new BrokeredMessage(Encoding.UTF8.GetBytes("SF WebApp been hit")));

                queueClient.Close();
                messagingFactory.Close();

                Message = "All good";
            }
            catch (Exception ex)
            {
                Message = ex.ToString();
            }
        }
    }
}
