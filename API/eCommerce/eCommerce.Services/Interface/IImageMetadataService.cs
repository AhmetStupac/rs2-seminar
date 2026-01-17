using eCommerce.Model.Responses;
using eCommerce.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface IImageMetadataService
    {
        Task<bool> UploadImageMetadata(Image image);
        Task<bool> DeleteImageMetadata(int id);
        Task<IEnumerable<ImageResponse>> GetByUserIdAsync(int userId);
    }
}
