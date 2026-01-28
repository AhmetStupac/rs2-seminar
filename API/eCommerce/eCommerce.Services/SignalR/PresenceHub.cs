using Microsoft.AspNetCore.SignalR;

namespace eCommerce.Services.SignalR
{
    public class PresenceHub : Hub
    {
        public override async Task OnConnectedAsync()
        {
            await base.OnConnectedAsync();
        }   
    }
}
