using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using eCommerce.Model.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Security.Claims;

namespace eCommerce.WebAPI.Controllers
{
    [Route("[controller]")]
    [ApiController]
    [Authorize]
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

            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
                return Forbid();

            var isAdmin = IsCurrentUserAdmin();

            var imageObj = JsonConvert.DeserializeObject<Image>(image);
            if (imageObj == null) 
                return BadRequest("Invalid image metadata payload");

            if (imageObj.UserId.HasValue && imageObj.UserId.Value > 0 && !isAdmin && imageObj.UserId.Value != currentUserId.Value)
                return Forbid();

            var effectiveUserId = isAdmin ? imageObj.UserId : currentUserId;

            // Check if UserId is provided
            var hasUser = effectiveUserId.HasValue && effectiveUserId.Value > 0;

            // Generate unique blob name with folder structure
            var safeOriginal = Path.GetFileName(file.FileName);
            var unique = $"{Guid.NewGuid():N}-{safeOriginal}";
            var blobName = hasUser
                ? $"users/{effectiveUserId}/{unique}"
                : $"general/{unique}";

            // Upload to Azure Blob Storage
            using var stream = file.OpenReadStream();
            var url = await _blobStorageService.UploadFileAsync(stream, blobName, file.ContentType);

            // Save metadata to database
            var imageToSql = new Image
            {
                UserId = effectiveUserId,
                Name = blobName,
                Url = url,
                Size = file.Length,
                IsHeader = imageObj.IsHeader
            };

            await _imageMetadataService.UploadImageMetadata(imageToSql);
            
            
            return Ok(new { FileUrl = url, BlobName = blobName , ImageId = imageToSql.Id});
        }

        [HttpDelete("delete")]
        public async Task<IActionResult> DeleteFile([FromQuery] string fileName, [FromQuery] int id)
        {
            if (string.IsNullOrEmpty(fileName))
                return BadRequest("File name is required");

            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
                return Forbid();

            var image = await _imageMetadataService.GetByIdAsync(id);
            if (image == null)
                return NotFound("Image metadata not found");

            if (!IsCurrentUserAdmin() && image.UserId != currentUserId.Value)
                return Forbid();

            if (!string.Equals(image.Name, fileName, StringComparison.Ordinal))
                return BadRequest("fileName does not match image metadata");

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

        [HttpGet("user")]
        public async Task<IActionResult> ListByUser()
        {
            var userId = GetCurrentUserId();
            if (!userId.HasValue)
                return Forbid();

            var images = await _imageMetadataService.GetByUserIdAsync(userId.Value);
            return Ok(images);
        }

        private int? GetCurrentUserId()
        {
            var claim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value
                        ?? User?.FindFirst("nameid")?.Value;

            return int.TryParse(claim, out var userId) ? userId : null;
        }

        private bool IsCurrentUserAdmin()
        {
            return User.IsInRole(Roles.SuperAdmin) || User.IsInRole(Roles.Administrator);
        }
    }
}
