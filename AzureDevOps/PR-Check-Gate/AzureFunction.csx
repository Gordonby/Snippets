#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    string jobid;
    string pr;
    string projectId;
    string uri;
    string project;
    string reason;
    string prid;

    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);
    jobid= data?.jobid;
    pr = data?.PR;
    projectId = data?.ProjectId;
    uri = data?.URI;
    project = data?.Project;
    reason = data?.Reason;
    prid = data?.PRId;

    log.LogInformation($"jobid {jobid}");
    log.LogInformation($"pr {pr}");
    log.LogInformation($"prId {prid}");
    log.LogInformation($"projectid {projectId}");
    log.LogInformation($"project {project}");
    log.LogInformation($"reason {reason}");
    log.LogInformation($"uri {uri}");
    log.LogInformation($"project {project}");
    

    var myObj = new {pr = pr, prstatus = ""};
    var jsonToReturn = JsonConvert.SerializeObject(myObj);

    return new OkObjectResult(jsonToReturn);
}
