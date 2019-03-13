using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace VNetHttpPinger
{
    public static class Function1
    {
        public static HttpClient client = new HttpClient();

        [FunctionName("Function1")]
        public static async Task Run([TimerTrigger("0 */1 * * * *")]TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

            //string page = "http://gb02web01.westeurope.cloudapp.azure.com/api/random";
            string page = "http://172.18.1.11/api/random";

            HttpResponseMessage result = await client.GetAsync(page);
            log.LogInformation($"Status code received: {result.StatusCode.ToString()}");

            switch (result.StatusCode)
            {
                case System.Net.HttpStatusCode.OK:
                    //All good.

                    //Lets parse the content to make sure that it looks solid
                    dynamic body = await result.Content.ReadAsStringAsync();
                    string[] e = JsonConvert.DeserializeObject<string[]>(body as string);

                    if (e.Length == 2)
                    {
                        //Super cool.
                        if (e[0] == "London")
                        {
                            //As expected, lets get out of there.
                            break;
                        }
                        else
                        {
                            throw new ApplicationException("Valid content json received, Value does not match expected.");
                        }
                    }
                    else
                    {
                        throw new ApplicationException("Invalid content received in valid response.");
                    }

                case System.Net.HttpStatusCode.TooManyRequests:
                    //We'll also let this one slide
                    break;
               
                default:
                    //We want App Insights to treat this as an error
                    throw new ApplicationException($"Invalid response received. {result.StatusCode.ToString()}");
            }


        }
    }
}
