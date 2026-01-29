using eCommerce.Services.SignalR;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace eCommerce.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MessageTestController(IHubContext<PresenceHub> hubContext) : ControllerBase
    {
        private readonly IHubContext<PresenceHub> _hubContext = hubContext;

        [HttpPost("broadcast")]
        public async Task<IActionResult> BroadcastMessage([FromBody] string message)
        {
            await _hubContext.Clients.All.SendAsync("ReceiveMessage", new
            {
                User = "System",
                Message = message,
                Timestamp = DateTime.UtcNow
            });

            return Ok();
        }
    }
}
