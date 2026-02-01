//using eCommerce.Services.SignalR;
//using Microsoft.AspNetCore.Authorization;
//using Microsoft.AspNetCore.Http;
//using Microsoft.AspNetCore.Mvc;
//using Microsoft.AspNetCore.SignalR;
//using System.Security.Claims;

//namespace eCommerce.WebAPI.Controllers
//{
//    [Authorize]
//    [ApiController]
//    [Route("hubs/presence")]
//    public class MessageController : ControllerBase
//    {
//        private readonly IHubContext<PresenceHub> _hubContext;

//        public MessageController(IHubContext<PresenceHub> hubContext)
//        {
//            _hubContext = hubContext;
//        }

//        [HttpPost("SendPrivateMessage")]
//        public async Task<IActionResult> SendPrivateMessage([FromBody] SendMessageRequest request)
//        {
//            var fromUserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
//            var fromUserEmail = User.FindFirst(ClaimTypes.Email)?.Value;
//            var fromUserName = User.FindFirst(ClaimTypes.Name)?.Value;

//            var userConnections = PresenceHub.GetUserConnections();

//            if (userConnections.TryGetValue(request.ToUserId, out var connectionId))
//            {
//                await _hubContext.Clients.Client(connectionId).SendAsync("ReceivePrivateMessage", new
//                {
//                    FromUserId = fromUserId,
//                    From = fromUserName,
//                    Email = fromUserEmail,
//                    Message = request.Message,
//                    Timestamp = DateTime.UtcNow
//                });

//                return Ok(new { success = true });
//            }

//            return BadRequest(new { success = false, message = $"User {request.ToUserId} is not online" });
//        }


//        [HttpGet("OnlineUsers")]
//        public IActionResult GetOnlineUsers()
//        {
//            var onlineUsers = PresenceHub.GetUserConnections().Keys.ToList();
//            return Ok(onlineUsers);
//        }

//    }

//    public class SendMessageRequest
//    {
//        public string ToUserId { get; set; }
//        public string Message { get; set; }
//    }
//}

