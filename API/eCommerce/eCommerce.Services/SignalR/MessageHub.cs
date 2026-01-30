using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.SignalR
{
    [Authorize]
    public class MessageHub(IMessageRepository messageRepository) : Hub
    {
        public override async Task OnConnectedAsync()
        {
            var httpContext = Context.GetHttpContext();
            var otherUser = httpContext?.Request.Query["userId"].ToString()
                    ?? throw new HubException("Other user not found");
            var groupName = GetGroupName(Context.User?.GetUserId(), otherUser);

            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

            var messages = await messageRepositorysitory.GetMessageThread(GetUserId(), otherUser);
            
            await Clients.Group(groupName).SendAsync("ReceiveMessageThread", messages);
        }

        private object GetUserId()
        {
            throw new NotImplementedException();
        }

        private static string GetGroupName(string? caller, string otherUser)
        {
           var stringCompare = string.CompareOrdinal(caller, otherUser) < 0;
            return stringCompare ? $"{caller}-{otherUser}" : $"{otherUser}-{caller}";
        }
    }
}
