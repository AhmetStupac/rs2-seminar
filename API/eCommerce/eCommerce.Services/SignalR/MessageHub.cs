using eCommerce.Services.Extensions;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Claims;

namespace eCommerce.Services.SignalR
{
    [Authorize]
    public class MessageHub(IMessageRepository messageRepository) : Hub
    {
        public override async Task OnConnectedAsync()    //Mouce da kod puca jer getUserId ne radi dobro
        {
            var httpContext = Context.GetHttpContext();
            var otherUser = httpContext?.Request.Query["userId"].ToString()
                    ?? throw new HubException("Other user not found");
            var groupName = GetGroupName(Context.User?.GetUserId(), otherUser);

            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

            var messages = await messageRepository.GetMessageThread(GetUserId(), otherUser);
            
            await Clients.Group(groupName).SendAsync("ReceiveMessageThread", messages);
        }

        private string GetUserId() 
        {
            return Context.User?.GetUserId()
                ?? throw new HubException("Cannot get member id");
        }

        private static string GetGroupName(string? caller, string otherUser)
        {
           var stringCompare = string.CompareOrdinal(caller, otherUser) < 0;
            return stringCompare ? $"{caller}-{otherUser}" : $"{otherUser}-{caller}";
        }
    }
}
