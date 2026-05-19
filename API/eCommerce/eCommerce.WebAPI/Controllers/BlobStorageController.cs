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
    [Authorize]
    public class BlobStorageController : ControllerBase
    {
        private const long MaxFileSizeBytes = 5 * 1024 * 1024;
        private static readonly HashSet<string> AllowedImageMimeTypes = new(StringComparer.OrdinalIgnoreCase)
        {
            "image/jpeg",
            "image/png",
            "image/gif",
            "image/webp",
            "image/bmp"
        };

        private readonly IBlobStorageService _blobStorageService;
        private readonly IImageMetadataService _imageMetadataService;
        private readonly ICurrentUserService _currentUser;

        public BlobStorageController(IBlobStorageService blobStorageService, IImageMetadataService imageMetadataService, ICurrentUserService currentUser)
        {
            _blobStorageService = blobStorageService;
            _imageMetadataService = imageMetadataService;
            _currentUser = currentUser;
        }


        [HttpPost("upload")]
        public async Task<IActionResult> UploadFile([FromForm] IFormFile file, [FromForm] string image)
        {
            if (file == null || file.Length == 0) 
                return BadRequest("File is empty");

            if (file.Length > MaxFileSizeBytes)
                return BadRequest($"File exceeds maximum allowed size of {MaxFileSizeBytes / (1024 * 1024)}MB");

            var currentUserId = _currentUser.UserId;
            if (!currentUserId.HasValue)
                return Forbid();

            var isAdmin = _currentUser.IsAdmin;

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
            var headerBuffer = new byte[12];
            var bytesRead = await stream.ReadAsync(headerBuffer, 0, headerBuffer.Length);
            if (!TryGetImageMimeType(headerBuffer.AsSpan(0, bytesRead), out var detectedMimeType))
                return BadRequest("Unsupported or invalid image format");

            if (!AllowedImageMimeTypes.Contains(detectedMimeType))
                return BadRequest("Unsupported image MIME type");

            if (!AllowedImageMimeTypes.Contains(file.ContentType ?? string.Empty))
                return BadRequest("Unsupported content type");

            if (stream.CanSeek)
            {
                stream.Position = 0;
            }
            else
            {
                using var bufferedStream = new MemoryStream();
                bufferedStream.Write(headerBuffer, 0, bytesRead);
                await stream.CopyToAsync(bufferedStream);
                bufferedStream.Position = 0;
                var bufferedUrl = await _blobStorageService.UploadFileAsync(bufferedStream, blobName, detectedMimeType);
                return await SaveMetadataAndRespond(bufferedUrl, blobName, file.Length, effectiveUserId, imageObj.IsHeader);
            }

            var url = await _blobStorageService.UploadFileAsync(stream, blobName, detectedMimeType);

            // Save metadata to database
            return await SaveMetadataAndRespond(url, blobName, file.Length, effectiveUserId, imageObj.IsHeader);
        }

        [HttpDelete("delete")]
        public async Task<IActionResult> DeleteFile([FromQuery] string fileName, [FromQuery] int id)
        {
            if (string.IsNullOrEmpty(fileName))
                return BadRequest("File name is required");

            var currentUserId = _currentUser.UserId;
            if (!currentUserId.HasValue)
                return Forbid();

            var image = await _imageMetadataService.GetByIdAsync(id);
            if (image == null)
                return NotFound("Image metadata not found");

            if (!_currentUser.IsAdmin && image.UserId != currentUserId.Value)
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

            if (!TryValidateBlobAccess(fileName, out var accessError))
                return accessError;

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

            if (!TryValidateBlobAccess(fileName, out var accessError))
                return accessError;

            var (fileStream, contentType) = await _blobStorageService.GetFileAsync(fileName);

            if (fileStream == null)
                return NotFound("File not found");

            return File(fileStream, contentType ?? "application/octet-stream", Path.GetFileName(fileName));
        }

        [HttpGet("user")]
        public async Task<IActionResult> ListByUser()
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            var images = await _imageMetadataService.GetByUserIdAsync(_currentUser.UserId.Value);
            return Ok(images);
        }

        private async Task<IActionResult> SaveMetadataAndRespond(string url, string blobName, long size, int? userId, bool isHeader)
        {
            var imageToSql = new Image
            {
                UserId = userId,
                Name = blobName,
                Url = url,
                Size = size,
                IsHeader = isHeader
            };

            await _imageMetadataService.UploadImageMetadata(imageToSql);

            return Ok(new { FileUrl = url, BlobName = blobName, ImageId = imageToSql.Id });
        }

        private bool TryValidateBlobAccess(string fileName, out IActionResult accessError)
        {
            accessError = null!;

            var normalized = fileName.Replace('\\', '/');
            if (!normalized.StartsWith("users/", StringComparison.OrdinalIgnoreCase))
                return true;

            var segments = normalized.Split('/', StringSplitOptions.RemoveEmptyEntries);
            if (segments.Length < 2 || !int.TryParse(segments[1], out var ownerUserId))
            {
                accessError = BadRequest("Invalid user file path");
                return false;
            }

            if (_currentUser.IsAdmin)
                return true;

            var currentUserId = _currentUser.UserId;
            if (!currentUserId.HasValue || currentUserId.Value != ownerUserId)
            {
                accessError = Forbid();
                return false;
            }

            return true;
        }

        private static bool TryGetImageMimeType(ReadOnlySpan<byte> header, out string mimeType)
        {
            mimeType = string.Empty;

            if (header.Length >= 3 && header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF)
            {
                mimeType = "image/jpeg";
                return true;
            }

            if (header.Length >= 8
                && header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47
                && header[4] == 0x0D && header[5] == 0x0A && header[6] == 0x1A && header[7] == 0x0A)
            {
                mimeType = "image/png";
                return true;
            }

            if (header.Length >= 6
                && header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46
                && header[3] == 0x38 && (header[4] == 0x37 || header[4] == 0x39)
                && header[5] == 0x61)
            {
                mimeType = "image/gif";
                return true;
            }

            if (header.Length >= 2 && header[0] == 0x42 && header[1] == 0x4D)
            {
                mimeType = "image/bmp";
                return true;
            }

            if (header.Length >= 12
                && header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46
                && header[8] == 0x57 && header[9] == 0x45 && header[10] == 0x42 && header[11] == 0x50)
            {
                mimeType = "image/webp";
                return true;
            }

            return false;
        }
    }
}
