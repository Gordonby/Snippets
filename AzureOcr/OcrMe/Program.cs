using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace OcrMe
{
    static class Program
    {
        // Find your cog services accounts with: https://portal.azure.com/#blade/HubsExtension/BrowseResourceBlade/resourceType/Microsoft.CognitiveServices%2Faccounts

        // Replace <Subscription Key> with your valid Computer Vision subscription key.
        const string subscriptionKey = "";

        const string uriBase = "https://westeurope.api.cognitive.microsoft.com/vision/v2.0/ocr";

        private static async Task Main()
        {
            // Get the path and filename to process from the user.
            Console.WriteLine(DateTime.Now.ToShortTimeString());
            Console.WriteLine("OCR an image:");
            Console.Write("Enter the path to the directory you wish to ocr: ");

            List<string> validExtensions = new List<string>() { ".JPG" };

            string dirPath = Console.ReadLine();

            if (Directory.Exists(dirPath))
            {
                foreach (string filePath in Directory.GetFiles(dirPath))
                {
                    string extension = Path.GetExtension(filePath);


                    if (validExtensions.Contains(extension.ToUpper()))
                    {
                        Console.Write(DateTime.Now.ToShortTimeString());
                        Console.WriteLine(" Processing {0}:", filePath);

                        ResizeImageIfNeeded(filePath, 4199, 4199);

                        JToken ocrContent = await MakeOCRRequest(filePath);

                        string jumbledSentance = "";
                        foreach (JToken wordBlock in ocrContent.SelectTokens("$..text"))
                        {
                            jumbledSentance += wordBlock.ToString() + " ";
                        }

                        string fileName = System.IO.Path.GetFileName(filePath);

                        string textFilePath = filePath.Replace(fileName, fileName.Replace(extension, ".txt"));

                        System.IO.File.WriteAllText(textFilePath, jumbledSentance);
                    }
                }
            }
            else
            {
                Console.WriteLine("\nInvalid path");
            }

            Console.WriteLine("\nPress Enter to exit...");
            Console.ReadLine();
        }

        static void ResizeImageIfNeeded(string pathToImage, int maxWidth, int maxHeight)
        {
            Image image = Image.FromFile(pathToImage);

            if (image.Height < maxHeight & image.Width < maxWidth)
            {
                //All good.
            }
            else
            {
                Bitmap destImage = GetBaseImage(image.Width, image.Height, maxHeight, maxWidth);
                var destRect = new Rectangle(0, 0, destImage.Width, destImage.Height);

                destImage.SetResolution(image.HorizontalResolution, image.VerticalResolution);

                using (var graphics = Graphics.FromImage(destImage))
                {
                    graphics.CompositingMode = CompositingMode.SourceCopy;
                    graphics.CompositingQuality = CompositingQuality.HighQuality;
                    graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    graphics.SmoothingMode = SmoothingMode.HighQuality;
                    graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;

                    using (var wrapMode = new ImageAttributes())
                    {
                        wrapMode.SetWrapMode(WrapMode.TileFlipXY);
                        graphics.DrawImage(image, destRect, 0, 0, image.Width, image.Height, GraphicsUnit.Pixel, wrapMode);
                    }
                }

                //rename original image
                image.Dispose();

                System.IO.File.Move(pathToImage, pathToImage + "_OLD");
                destImage.Save(pathToImage);

                destImage.Dispose();
            }
        }

        private static Bitmap GetBaseImage(int imageWidth, int imageHeight, int maxHeight, int maxWidth)
        {

            decimal aspectRatio = Decimal.Divide((decimal)imageWidth, (decimal)imageHeight);

            decimal boxRatio = maxWidth / maxHeight;
            decimal scaleFactor = 0;

            if (boxRatio > aspectRatio) //Use height, since that is the most restrictive dimension of box. 
                scaleFactor = Decimal.Divide(maxHeight, imageHeight);
            else
                scaleFactor = Decimal.Divide(maxWidth, imageWidth);

            decimal newWidth = Decimal.Multiply(imageWidth, scaleFactor);
            decimal newHeight = Decimal.Multiply(imageHeight, scaleFactor);

            return new Bitmap((int)newWidth, (int)newHeight);
        }

        /// <summary>
        /// Gets the text visible in the specified image file by using
        /// the Computer Vision REST API.
        /// </summary>
        /// <param name="imageFilePath">The image file with printed text.</param>
        static async Task<JToken> MakeOCRRequest(string imageFilePath)
        {
            try
            {
                HttpClient client = new HttpClient();

                // Request headers.
                client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", subscriptionKey);

                // Request parameters. 
                // The language parameter doesn't specify a language, so the 
                // method detects it automatically.
                // The detectOrientation parameter is set to true, so the method detects and
                // and corrects text orientation before detecting text.
                string requestParameters = "language=en&detectOrientation=true";

                // Assemble the URI for the REST API method.
                string uri = uriBase + "?" + requestParameters;

                HttpResponseMessage response;

                // Read the contents of the specified local image
                // into a byte array.
                byte[] byteData = GetImageAsByteArray(imageFilePath);

                // Add the byte array as an octet stream to the request body.
                using (ByteArrayContent content = new ByteArrayContent(byteData))
                {
                    // This example uses the "application/octet-stream" content type.
                    // The other content types you can use are "application/json"
                    // and "multipart/form-data".
                    content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");

                    // Asynchronously call the REST API method.
                    response = await client.PostAsync(uri, content);
                }

                // Asynchronously get the JSON response.
                string contentString = await response.Content.ReadAsStringAsync();

                // Display the JSON response.
                return JToken.Parse(contentString);
            }
            catch (Exception e)
            {
                Console.WriteLine("\n" + e.Message);
                throw;
            }
        }

        /// <summary>
        /// Returns the contents of the specified file as a byte array.
        /// </summary>
        /// <param name="imageFilePath">The image file to read.</param>
        /// <returns>The byte array of the image data.</returns>
        static byte[] GetImageAsByteArray(string imageFilePath)
        {
            // Open a read-only file stream for the specified file.
            using (FileStream fileStream =
                new FileStream(imageFilePath, FileMode.Open, FileAccess.Read))
            {
                // Read the file's contents into a byte array.
                BinaryReader binaryReader = new BinaryReader(fileStream);
                return binaryReader.ReadBytes((int)fileStream.Length);
            }
        }
    }
}
