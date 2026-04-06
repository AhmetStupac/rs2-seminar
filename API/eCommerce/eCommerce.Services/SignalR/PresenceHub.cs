using eCommerce.Services.Interface;
using eCommerce.Services.Repository;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Collections.Concurrent;
using System.Linq;
using System.Security.Claims;

namespace eCommerce.Services.SignalR
{
    [Authorize]
    public class PresenceHub : Hub
    {
        private static readonly ConcurrentDictionary<string, string> _userConnections = new();
        private readonly IUserRepository _userRepository;

        public PresenceHub(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public override async Task OnConnectedAsync()
        {
            var userEmail = Context.User?.FindFirst(ClaimTypes.Email)?.Value;
            var userIdString = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (!string.IsNullOrEmpty(userEmail) && !string.IsNullOrEmpty(userIdString)
                && int.TryParse(userIdString, out var userId))
            {
                _userConnections.TryAdd(userIdString, Context.ConnectionId);

                // Fetch user details from database
                var user = await _userRepository.GetUserByIdAsync(userId);

                // Notify others that this user is online
                await Clients.Others.SendAsync("UserOnline", new
                {
                    UserId = userIdString,
                    Email = userEmail,
                    FirstName = user?.FirstName,
                    LastName = user?.LastName,
                    ConnectionId = Context.ConnectionId
                });

                // Send list of currently online users to the new connection
                var onlineUsers = new List<object>();
                var onlineUserIdMap = _userConnections.Keys
                    .Select(id => new { IdString = id, Parsed = int.TryParse(id, out var parsedId) ? parsedId : (int?)null })
                    .Where(x => x.Parsed.HasValue)
                    .ToList();

                var usersById = (await _userRepository.GetUsersByIdsAsync(onlineUserIdMap.Select(x => x.Parsed!.Value)))
                    .ToDictionary(u => u.Id);

                foreach (var onlineUserId in onlineUserIdMap)
                {
                    usersById.TryGetValue(onlineUserId.Parsed!.Value, out var onlineUser);
                    onlineUsers.Add(new
                    {
                        UserId = onlineUserId.IdString,
                        Email = onlineUser?.Email,
                        FirstName = onlineUser?.FirstName,
                        LastName = onlineUser?.LastName
                    });
                }
                await Clients.Caller.SendAsync("OnlineUsers", onlineUsers);
            }

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userEmail = Context.User?.FindFirst(ClaimTypes.Email)?.Value;
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (!string.IsNullOrEmpty(userId) && _userConnections.TryRemove(userId, out _))
            {
                await Clients.Others.SendAsync("UserOffline", new
                {
                    UserId = userId,
                    Email = userEmail,
                    ConnectionId = Context.ConnectionId
                });
            }

            await base.OnDisconnectedAsync(exception);
        }

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

            if (_userConnections.TryGetValue(toUserId, out var connectionId))
            {
                await Clients.Client(connectionId).SendAsync("ReceivePrivateMessage", new
                {
                    FromUserId = fromUserId,
                    From = fromUserName,
                    Email = fromUserEmail,
                    Message = message,
                    Timestamp = DateTime.UtcNow
                });

                await Clients.Caller.SendAsync("MessageSent", new
                {
                    ToUserId = toUserId,
                    Message = message,
                    Timestamp = DateTime.UtcNow
                });
            }
            else
            {
                await Clients.Caller.SendAsync("MessageError", $"User {toUserId} is not online");
            }
        }

        public async Task<List<object>> GetOnlineUsers()
        {
            var onlineUsers = new List<object>();
            foreach (var userId in _userConnections.Keys)
            {
                if (int.TryParse(userId, out var id))
                {
                    var user = await _userRepository.GetUserByIdAsync(id);
                    onlineUsers.Add(new
                    {
                        UserId = userId,
                        Email = user?.Email,
                        FirstName = user?.FirstName,
                        LastName = user?.LastName
                    });
                }
            }
            return onlineUsers;
        }

        public static ConcurrentDictionary<string, string> GetUserConnections()
        {
            return _userConnections;
        }
    }
}