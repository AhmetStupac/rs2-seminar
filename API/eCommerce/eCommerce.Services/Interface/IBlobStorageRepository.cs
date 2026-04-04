using eCommerce.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IBlobStorageRepository
    {
        Task UploadFileMetaDataAsync(Image image);
        Task<bool> DeleteFileMetaData(int id);
        Task<List<Image>> GetImagesByUserIdAsync(int userId);
        Task<Image?> GetImageByIdAsync(int id);
    }
}
