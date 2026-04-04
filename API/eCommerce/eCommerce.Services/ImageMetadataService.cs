using eCommerce.Model.Responses;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class ImageMetadataService : IImageMetadataService
    {
        private readonly IBlobStorageRepository _blobStorageRepository;
        public ImageMetadataService(IBlobStorageRepository blobStorageRepository)
        {
            _blobStorageRepository = blobStorageRepository;
        }

        public async Task<bool> DeleteImageMetadata(int id)
        {
            try
            {
                await _blobStorageRepository.DeleteFileMetaData(id);
                return true;
            }
            catch (Exception)
            {

                return false;
            }
        }

        public async Task<bool> UploadImageMetadata(Image image)
        {

            try
            {
                await _blobStorageRepository.UploadFileMetaDataAsync(image);

                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }



        public async Task<IEnumerable<ImageResponse>> GetByUserIdAsync(int userId)
        {
            var images = await _blobStorageRepository.GetImagesByUserIdAsync(userId);
            return images.Select(x => new ImageResponse
            {
                Id = x.Id,
                Url = x.Url,
                Name = x.Name,
                IsHeader = x.IsHeader,
                Size = x.Size,
                UserId = x.UserId
            });
        }

        public async Task<ImageResponse?> GetByIdAsync(int id)
        {
            var image = await _blobStorageRepository.GetImageByIdAsync(id);
            if (image == null)
                return null;

            return new ImageResponse
            {
                Id = image.Id,
                Url = image.Url,
                Name = image.Name,
                IsHeader = image.IsHeader,
                Size = image.Size,
                UserId = image.UserId
            };
        }
    }
}
