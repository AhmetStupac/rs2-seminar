using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using eCommerce.Services.Interface;
using Microsoft.Extensions.Configuration;

namespace eCommerce.Services
{
    public class BlobStorageService : IBlobStorageService
    {
        private readonly BlobServiceClient _blobServiceClient;
        private readonly string _containerName;

        public BlobStorageService(IConfiguration configuration)
        {
            var connectionString = configuration["AzureBlobStorage:ConnectionString"];
            _containerName = configuration["AzureBlobStorage:ContainerName"] ?? "images";
            
            _blobServiceClient = new BlobServiceClient(connectionString);
           
        }

        public async Task<string> UploadFileAsync(Stream fileStream, string blobName, string contentType)
        {
            try
            {
                // Get container client (create if not exists)
                var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob);

                // Get blob client
                var blobClient = containerClient.GetBlobClient(blobName);

                // Set upload options
                var uploadOptions = new BlobUploadOptions
                {
                    HttpHeaders = new BlobHttpHeaders
                    {
                        ContentType = contentType
                    }
                };

                // Upload file
                await blobClient.UploadAsync(fileStream, uploadOptions);

                // Return the URL
                return blobClient.Uri.ToString();
            }
            catch (Exception ex)
            {
                throw new Exception($"Error uploading file to Azure Blob Storage: {ex.Message}", ex);
            }
        }

        public async Task<bool> DeleteFileAsync(string blobName)
        {
            try
            {
                var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                var blobClient = containerClient.GetBlobClient(blobName);

                // Delete the blob
                var response = await blobClient.DeleteIfExistsAsync();
                return response.Value;
            }
            catch (Exception ex)
            {
                throw new Exception($"Error deleting file from Azure Blob Storage: {ex.Message}", ex);
            }
        }

        public async Task<(Stream fileStream, string contentType)> DownloadFileAsync(string blobName)
        {
            try
            {
                var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                var blobClient = containerClient.GetBlobClient(blobName);

                // Check if blob exists
                if (!await blobClient.ExistsAsync())
                    return (null, null);

                // Download blob
                var response = await blobClient.DownloadAsync();
                var contentType = response.Value.ContentType;

                // Copy to memory stream (so we can close the response)
                var memoryStream = new MemoryStream();
                await response.Value.Content.CopyToAsync(memoryStream);
                memoryStream.Position = 0;

                return (memoryStream, contentType);
            }
            catch (Exception ex)
            {
                throw new Exception($"Error downloading file from Azure Blob Storage: {ex.Message}", ex);
            }
        }

        public async Task<(Stream fileStream, string contentType)> GetFileAsync(string blobName)
        {
            // GetFile is same as Download in this implementation
            return await DownloadFileAsync(blobName);
        }
    }
}
