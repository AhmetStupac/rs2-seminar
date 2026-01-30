using eCommerce.Services.SignalR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class PresenceController : ControllerBase
    {
        [HttpGet("OnlineUsers")]
        public IActionResult GetOnlineUsers()
        {
            var onlineUsers = PresenceHub.GetUserConnections().Keys.ToList();
            return Ok(onlineUsers);
        }
    }
}
