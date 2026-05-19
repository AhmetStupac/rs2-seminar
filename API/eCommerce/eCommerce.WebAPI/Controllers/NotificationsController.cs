using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _notificationService;
        private readonly ICurrentUserService _currentUser;

        public NotificationsController(INotificationService notificationService, ICurrentUserService currentUser)
        {
            _notificationService = notificationService;
            _currentUser = currentUser;
        }

        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] NotificationSearchObject? search = null)
        {
            search ??= new NotificationSearchObject();
            search.UserId = _currentUser.UserId;
            var result = await _notificationService.GetAsync(search);
            return Ok(result);
        }

        [HttpPost("{id:int}/read")]
        public async Task<IActionResult> MarkRead(int id)
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            await _notificationService.MarkAsReadAsync(_currentUser.UserId.Value, id);
            return NoContent();
        }

        [HttpPost("read-all")]
        public async Task<IActionResult> MarkAllRead()
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            await _notificationService.MarkAllAsReadAsync(_currentUser.UserId.Value);
            return NoContent();
        }
    }
}
