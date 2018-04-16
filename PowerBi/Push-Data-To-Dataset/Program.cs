using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Push_data
{
    using System;
    using Microsoft.IdentityModel.Clients.ActiveDirectory;
    using System.Net;
    using System.IO;
    using Newtonsoft.Json;
    using System.Configuration;
    using Newtonsoft.Json.Linq;

    namespace walkthrough_push_data
    {
        class Program
        {
            private static string token = string.Empty;

            enum DatasetMode
            {
                Push,
                Streaming,
                PushStreaming,
                AzureAS,
                AsOnPrem
            }

            enum SampleDataset
            {
                SalesMarketing,
                Temperature
            }


            static void Main(string[] args)
            {

                //Get an authentication access token
                token = GetToken();
                //Look at it in https://jwt.io/

                //Create a regular dataset in Power BI
                Console.WriteLine("Standard push dataset");
                string dsName = "SalesMarketing";
                var sampleDatasetId = GetDataset(dsName);
                if (sampleDatasetId == null)
                {
                    CreateSampleDataset(DatasetMode.Push, SampleDataset.SalesMarketing, dsName);

                    sampleDatasetId = GetDataset(dsName);
                }
                AddRows(sampleDatasetId, "Product");

                //Create a Streaming dataset in Power BI
                Console.WriteLine("Streaming dataset");
                dsName = "Temperature";
                sampleDatasetId = GetDataset(dsName);
                if (sampleDatasetId == null)
                {
                    CreateSampleDataset(DatasetMode.Streaming, SampleDataset.Temperature, dsName);

                    sampleDatasetId = GetDataset(dsName);
                }
                AddStreamingRow(sampleDatasetId, "Temp");

                //Create a Streaming dataset in Power BI
                Console.WriteLine("Hybrid (PushStream) dataset");
                dsName = "TempHybrid";
                sampleDatasetId = GetDataset(dsName);
                if (sampleDatasetId == null)
                {
                    CreateSampleDataset(DatasetMode.PushStreaming, SampleDataset.Temperature, dsName);

                    sampleDatasetId = GetDataset(dsName);
                }
                AddStreamingRow(sampleDatasetId, "Temp");

                Console.ReadLine();

            }

            #region Get an authentication access token
            private static string GetToken()
            {
                //The client id that Azure AD created when you registered your NATIVE client app.
                string clientID = ConfigurationManager.AppSettings["ClientId"];

                //RedirectUri you used when you register your app.
                string redirectUri = ConfigurationManager.AppSettings["RedirectUrl"];

                //Resource Uri for Power BI API
                string resourceUri = "https://analysis.windows.net/powerbi/api";

                //OAuth2 authority Uri
                string authorityUri = "https://login.windows.net/common/oauth2/authorize";

                // AcquireToken will acquire an Azure access token
                AuthenticationContext authContext = new AuthenticationContext(authorityUri);
                var platformParams = new PlatformParameters(PromptBehavior.Auto);

                var tokenResult = authContext.AcquireTokenAsync(resourceUri, clientID, new Uri(redirectUri), platformParams);
                string token = tokenResult.Result.AccessToken;


                Console.WriteLine(token);

                return token;
            }

            #endregion

            #region Create a dataset in Power BI
            private static void CreateSampleDataset(DatasetMode mode, SampleDataset dsType, string dsName)
            {
                string powerBIDatasetsApiUrl = "https://api.powerbi.com/v1.0/myorg/datasets";
                //POST web request to create a dataset.
                //To create a Dataset in a group, use the Groups uri: https://api.PowerBI.com/v1.0/myorg/groups/{group_id}/datasets
                HttpWebRequest request = System.Net.WebRequest.Create(powerBIDatasetsApiUrl) as System.Net.HttpWebRequest;
                request.KeepAlive = true;
                request.Method = "POST";
                request.ContentLength = 0;
                request.ContentType = "application/json";

                //Add token to the request header
                request.Headers.Add("Authorization", String.Format("Bearer {0}", token));

                //Choose dataset
                string dsCols = string.Empty;
                switch (dsType)
                {
                    case SampleDataset.SalesMarketing:
                        dsCols = "[{\"name\": \"Product\", \"columns\": " +
                    "[{ \"name\": \"ProductID\", \"dataType\": \"Int64\"}, " +
                    "{ \"name\": \"Name\", \"dataType\": \"string\"}, " +
                    "{ \"name\": \"Category\", \"dataType\": \"string\"}," +
                    "{ \"name\": \"IsCompete\", \"dataType\": \"bool\"}," +
                    "{ \"name\": \"ManufacturedOn\", \"dataType\": \"DateTime\"}]" +
                    "}]";
                        break;
                    case SampleDataset.Temperature:
                        dsCols = "[{\"name\": \"Temp\", \"columns\": " +
                    "[{ \"name\": \"ambient_temperature\", \"dataType\": \"Int64\"}, " +
                    "{ \"name\": \"sensor_uuid\", \"dataType\": \"string\"}, " +
                    "{ \"name\": \"humidity\", \"dataType\": \"Int64\"}," +
                    "{ \"name\": \"photosensor\", \"dataType\": \"Int64\"}," +
                    "{ \"name\": \"radiation_level\", \"dataType\": \"Int64\"}," +
                    "{ \"name\": \"timestamp\", \"dataType\": \"DateTime\"}]" +
                    "}]";
                        break;
                }

                //Create dataset JSON for POST request
                string dsMode = Enum.GetName(typeof(DatasetMode), mode);
                //string dsName = Enum.GetName(typeof(SampleDataset), dsType);

                string datasetJson = string.Format("{{\"name\": \"{0}\", \"defaultMode\": \"{1}\", \"tables\": {2}}}",  dsName, dsMode, dsCols);

                //POST web request
                byte[] byteArray = System.Text.Encoding.UTF8.GetBytes(datasetJson);
                request.ContentLength = byteArray.Length;

                //Write JSON byte[] into a Stream
                using (Stream writer = request.GetRequestStream())
                {
                    writer.Write(byteArray, 0, byteArray.Length);

                    var response = (HttpWebResponse)request.GetResponse();

                    Console.WriteLine(string.Format("Dataset {0}", response.StatusCode.ToString()));
                }
            }
            #endregion

            #region Get a dataset to add rows into a Power BI table
            private static string GetDataset(string datasetName)
            {
                string powerBIDatasetsApiUrl = "https://api.powerbi.com/v1.0/myorg/datasets";
                //POST web request to create a dataset.
                //To create a Dataset in a group, use the Groups uri: https://api.PowerBI.com/v1.0/myorg/groups/{group_id}/datasets
                HttpWebRequest request = System.Net.WebRequest.Create(powerBIDatasetsApiUrl) as System.Net.HttpWebRequest;
                request.KeepAlive = true;
                request.Method = "GET";
                request.ContentLength = 0;
                request.ContentType = "application/json";

                //Add token to the request header
                request.Headers.Add("Authorization", String.Format("Bearer {0}", token));

                string datasetId = string.Empty;
                //Get HttpWebResponse from GET request
                using (HttpWebResponse httpResponse = request.GetResponse() as System.Net.HttpWebResponse)
                {
                    //Get StreamReader that holds the response stream
                    using (StreamReader reader = new System.IO.StreamReader(httpResponse.GetResponseStream()))
                    {
                        string responseContent = reader.ReadToEnd();

                        JObject results = JsonConvert.DeserializeObject<dynamic>(responseContent);

                        //var dsMatch = results.
                        var dsMatch = results.ToObject<Datasets>().value.Where(d => d.Name.Equals(datasetName)).FirstOrDefault();

                        if (dsMatch == null)
                        {
                            return null;
                        }
                        else
                        {
                            datasetId = dsMatch.Id;

                            Console.WriteLine(String.Format("Dataset ID: {0}", datasetId));

                            return datasetId;
                        }
                    }
                }
            }
            #endregion

            #region Add rows to a Power BI table
            private static void AddRows(string datasetId, string tableName)
            {
                string powerBIApiAddRowsUrl = String.Format("https://api.powerbi.com/v1.0/myorg/datasets/{0}/tables/{1}/rows", datasetId, tableName);

                //POST web request to add rows.
                //To add rows to a dataset in a group, use the Groups uri: https://api.powerbi.com/v1.0/myorg/groups/{group_id}/datasets/{dataset_id}/tables/{table_name}/rows
                //Change request method to "POST"
                HttpWebRequest request = System.Net.WebRequest.Create(powerBIApiAddRowsUrl) as System.Net.HttpWebRequest;
                request.KeepAlive = true;
                request.Method = "POST";
                request.ContentLength = 0;
                request.ContentType = "application/json";

                //Add token to the request header
                request.Headers.Add("Authorization", String.Format("Bearer {0}", token));

                //JSON content for product row
                string rowsJson = "{\"rows\":" +
                    "[{\"ProductID\":1,\"Name\":\"Adjustable Race\",\"Category\":\"Components\",\"IsCompete\":true,\"ManufacturedOn\":\"07/30/2014\"}," +
                    "{\"ProductID\":2,\"Name\":\"LL Crankarm\",\"Category\":\"Components\",\"IsCompete\":true,\"ManufacturedOn\":\"07/30/2014\"}," +
                    "{\"ProductID\":3,\"Name\":\"HL Mountain Frame - Silver\",\"Category\":\"Bikes\",\"IsCompete\":true,\"ManufacturedOn\":\"07/30/2014\"}]}";



                //POST web request
                byte[] byteArray = System.Text.Encoding.UTF8.GetBytes(rowsJson);
                request.ContentLength = byteArray.Length;

                //Write JSON byte[] into a Stream
                using (Stream writer = request.GetRequestStream())
                {
                    writer.Write(byteArray, 0, byteArray.Length);

                    HttpWebResponse response = (HttpWebResponse)request.GetResponse();

                    string requestId = response.Headers.GetValues("RequestId").ToString();

                    Console.WriteLine("Rows Added");

                }
            }

            private static void AddStreamingRow(string datasetId, string tableName)
            {
                // string powerBIApiAddRowsUrl = String.Format("https://api.powerbi.com/v1.0/myorg/datasets/{0}/rows", datasetId);
                string powerBIApiAddRowsUrl = String.Format("https://api.powerbi.com/v1.0/myorg/datasets/{0}/tables/{1}/rows", datasetId, tableName);

                HttpWebRequest request = System.Net.WebRequest.Create(powerBIApiAddRowsUrl) as System.Net.HttpWebRequest;
                request.KeepAlive = true;
                request.Method = "POST";
                request.ContentLength = 0;
                request.ContentType = "application/json";

                //Add token to the request header
                request.Headers.Add("Authorization", String.Format("Bearer {0}", token));

                string dtNow = DateTime.UtcNow.ToString("o");
                string rowJson = "{\"rows\":[{\"ambient_temperature\" :98.6,\"sensor_uuid\" :\"AAAAA555555\",\"timestamp\" :\"" + dtNow + "\",\"humidity\" :98.6,\"photosensor\" :98.6,\"radiation_level\" :98.6}]}";


                //POST web request
                byte[] byteArray = System.Text.Encoding.UTF8.GetBytes(rowJson);
                request.ContentLength = byteArray.Length;

                //Write JSON byte[] into a Stream
                using (Stream writer = request.GetRequestStream())
                {
                    writer.Write(byteArray, 0, byteArray.Length);

                    var response = (HttpWebResponse)request.GetResponse();

                    Console.WriteLine("Rows Added");
                }
            }

            #endregion
        }
    }


    public class Datasets
    {
        public dataset[] value { get; set; }
    }
    public class dataset
    {
        public string Id { get; set; }
        public string Name { get; set; }
    }
}
