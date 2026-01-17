using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;

namespace eCommerce.WebAPI.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class BlobStorageController : ControllerBase
    {
        private readonly IBlobStorageService _blobStorageService;
        private readonly IImageMetadataService _imageMetadataService;

        public BlobStorageController(IBlobStorageService blobStorageService, IImageMetadataService imageMetadataService)
        {
            _blobStorageService = blobStorageService;
            _imageMetadataService = imageMetadataService;
        }


        [HttpPost("upload")]
        public async Task<IActionResult> UploadFile([FromForm] IFormFile file, [FromForm] string image)
        {
            if (file == null || file.Length == 0) 
                return BadRequest("File is empty");

            var imageObj = JsonConvert.DeserializeObject<Image>(image);
            if (imageObj == null) 
                return BadRequest("Invalid image metadata payload");

            // Check if UserId is provided
            var hasUser = imageObj.UserId.HasValue && imageObj.UserId.Value > 0;

            // Generate unique blob name with folder structure
            var safeOriginal = Path.GetFileName(file.FileName);
            var unique = $"{Guid.NewGuid():N}-{safeOriginal}";
            var blobName = hasUser
                ? $"users/{imageObj.UserId}/{unique}"
                : $"general/{unique}";

            // Upload to Azure Blob Storage
            using var stream = file.OpenReadStream();
            var url = await _blobStorageService.UploadFileAsync(stream, blobName, file.ContentType);

            // Save metadata to database
            var imageToSql = new Image
            {
                UserId = imageObj.UserId,
                Name = blobName,
                Url = url,
                Size = file.Length,
                IsHeader = imageObj.IsHeader
            };

            await _imageMetadataService.UploadImageMetadata(imageToSql);
            
            return Ok(new { FileUrl = url, BlobName = blobName });
        }

        [HttpDelete("delete")]
        public async Task<IActionResult> DeleteFile([FromQuery] string fileName, [FromQuery] int id)
        {
            if (string.IsNullOrEmpty(fileName))
                return BadRequest("File name is required");

            // Delete from Azure Blob Storage
            var deleted = await _blobStorageService.DeleteFileAsync(fileName);
            
            if (!deleted)
                return NotFound("File not found in blob storage");

            // Delete metadata from database
            await _imageMetadataService.DeleteImageMetadata(id);
            
            return Ok(new { Message = "File deleted successfully", FileName = fileName });
        }

        [HttpGet("download/{*fileName}")]
        public async Task<IActionResult> DownloadFile(string fileName)
        {
            if (string.IsNullOrEmpty(fileName))
                return BadRequest("File name is required");

            var (fileStream, contentType) = await _blobStorageService.DownloadFileAsync(fileName);
            
            if (fileStream == null)
                return NotFound("File not found");

            var actualFileName = Path.GetFileName(fileName);
            return File(fileStream, contentType ?? "application/octet-stream", actualFileName);
        }

        [HttpGet("get/{*fileName}")]
        public async Task<IActionResult> GetFile(string fileName)
        {
            if (string.IsNullOrEmpty(fileName))
                return BadRequest("File name is required");

            var (fileStream, contentType) = await _blobStorageService.GetFileAsync(fileName);

            if (fileStream == null)
                return NotFound("File not found");

            return File(fileStream, contentType ?? "application/octet-stream", Path.GetFileName(fileName));
        }

        [HttpGet("user/{userId:int}")]
        public async Task<IActionResult> ListByUser(int userId)
        {
            var images = await _imageMetadataService.GetByUserIdAsync(userId);
            return Ok(images);
        }
    }
}
