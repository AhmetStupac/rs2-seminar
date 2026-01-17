using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Net.Mime.MediaTypeNames;

namespace eCommerce.Services.Interface
{
    public interface IBlobStorageService
    {
        Task<string> UploadFileAsync(Stream fileStream, string blobName, string contentType);
        Task<bool> DeleteFileAsync(string blobName);
        Task<(Stream fileStream, string contentType)> DownloadFileAsync(string blobName);
        Task<(Stream fileStream, string contentType)> GetFileAsync(string blobName);
    }
}
