using eCommerce.Model.Responses;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class BlobStorageRepository : IBlobStorageRepository
    {
        private readonly IB210033DbContext _dbContext;

        public BlobStorageRepository(IB210033DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<bool> DeleteFileMetaData(int id)
        {
            var result = await _dbContext.Images.FirstOrDefaultAsync(x => x.Id == id);
            if (result is null)
            {
                return false;
            }
            _dbContext.Images.Remove(result);
            _dbContext.SaveChangesAsync();
            return true;
        }

        public async Task<List<Image>> GetImagesByUserIdAsync(int userId)
        {
            return await _dbContext.Images
                .Where(i => i.UserId == userId)
                .OrderByDescending(i => i.Id)
                .ToListAsync();
        }

        public async Task UploadFileMetaDataAsync(Image image)
        {

            await _dbContext.Images.AddAsync(image);
            await _dbContext.SaveChangesAsync();
        }
    }
}
