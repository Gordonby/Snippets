#r "Newtonsoft.Json"

using static System.Environment;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net;

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
string OriginUrl = req.Headers.GetValues("DISGUISED-HOST").FirstOrDefault();
log.Info("RequestURI org: " + OriginUrl);

//create response
var response = req.CreateResponse(HttpStatusCode.MovedPermanently);
if(OriginUrl.Contains("tom.azdemo.co.uk"))
{
response.Headers.Location = new Uri("https://rdweb.wvd.microsoft.com/webclient");
}
else
{
      log.Info("error RequestURI org: " + OriginUrl);
//      response.Headers.Location = new Uri("http://www.google.com");
return req.CreateResponse(HttpStatusCode.InternalServerError);
}
return response;
}
