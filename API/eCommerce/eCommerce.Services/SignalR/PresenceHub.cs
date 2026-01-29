using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Collections.Concurrent;
using System.Security.Claims;

namespace eCommerce.Services.SignalR
{
    //[Authorize]
    public class PresenceHub : Hub
    {
        private static readonly ConcurrentDictionary<string, string> _userConnections = new();

        public override async Task OnConnectedAsync()
        {
            var userEmail = Context.User?.FindFirst(ClaimTypes.Email)?.Value;
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (!string.IsNullOrEmpty(userEmail) && !string.IsNullOrEmpty(userId))
            {
                _userConnections.TryAdd(userId, Context.ConnectionId);
                
                // Notify others that this user is online
                await Clients.Others.SendAsync("UserOnline", new 
                { 
                    UserId = userId,
                    Email = userEmail,
                    ConnectionId = Context.ConnectionId
                });

                // Send list of currently online users to the new connection
                await Clients.Caller.SendAsync("OnlineUsers", _userConnections.Keys.ToList());
            }

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userEmail = Context.User?.FindFirst(ClaimTypes.Email)?.Value;
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (!string.IsNullOrEmpty(userId) && _userConnections.TryRemove(userId, out _))
            {
                // Notify others that this user is offline
                await Clients.Others.SendAsync("UserOffline", new 
                { 
                    UserId = userId,
                    Email = userEmail,
                    ConnectionId = Context.ConnectionId
                });
            }

            await base.OnDisconnectedAsync(exception);
        }

        // Custom methods that clients can invoke
        public async Task SendMessage(string message)
        {
            var userEmail = Context.User?.FindFirst(ClaimTypes.Email)?.Value;
            var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            await Clients.All.SendAsync("ReceiveMessage", new
            {
                UserId = userId,
                User = userName,
                Email = userEmail,
                Message = message,
                Timestamp = DateTime.UtcNow
            });
        }

        public async Task SendPrivateMessage(string toUserId, string message)
        {
            var fromUserId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var fromUserEmail = Context.User?.FindFirst(ClaimTypes.Email)?.Value;
            var fromUserName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

            // Find the connection ID for the target user
            if (_userConnections.TryGetValue(toUserId, out var connectionId))
            {
                // Send to recipient
                await Clients.Client(connectionId).SendAsync("ReceivePrivateMessage", new
                {
                    FromUserId = fromUserId,
                    From = fromUserName,
                    Email = fromUserEmail,
                    Message = message,
                    Timestamp = DateTime.UtcNow
                });

                // Send confirmation to sender
                await Clients.Caller.SendAsync("MessageSent", new
                {
                    ToUserId = toUserId,
                    Message = message,
                    Timestamp = DateTime.UtcNow
                });
            }
            else
            {
                // Send error to caller if user is not online
                await Clients.Caller.SendAsync("MessageError", $"User {toUserId} is not online");
            }
        }
        // moguce staviti string[]
        public async Task<List<string>> GetOnlineUsers()
        {
            return _userConnections.Keys.ToList();
        }
    }
}
