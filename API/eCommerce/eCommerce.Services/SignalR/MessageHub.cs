using eCommerce.Model.Constants;
using eCommerce.Model.Responses;
using eCommerce.Services.Database;
using eCommerce.Services.Extensions;
using eCommerce.Services.Interface;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Linq;

namespace eCommerce.Services.SignalR
{
    [Authorize]
    public class MessageHub(
        IMessageRepository messageRepository,
        IUserRepository userRepository,
        INotificationService notificationService,
        IValidator<CreateMessageDTO> messageValidator) : Hub
    {
        public override async Task OnConnectedAsync()
        {
            var httpContext = Context.GetHttpContext();
            var otherUserStringValues = httpContext?.Request.Query["userId"]
                    ?? throw new HubException("Other user not found");

            // Convert StringValues to int
            if (!int.TryParse(otherUserStringValues.ToString(), out var otherUser))
                throw new HubException("Invalid userId");

            var groupName = GetGroupName(Context.User?.GetUserId(), otherUser);

            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

            var messages = await messageRepository.GetMessageThread(GetUserId(), otherUser);
            
            await Clients.Group(groupName).SendAsync("ReceiveMessageThread", messages);
        }

        private int GetUserId() 
        {
            return Context.User?.GetUserId()
                ?? throw new HubException("Cannot get member id");
        }

        private static string GetGroupName(int? caller, int otherUser)
        {
           var stringCompare = string.CompareOrdinal(caller.ToString(), otherUser.ToString()) < 0;
            return stringCompare ? $"{caller}-{otherUser}" : $"{otherUser}-{caller}";
        }


        public async Task SendMessage(CreateMessageDTO createMessageDto)
        {
            var validation = await messageValidator.ValidateAsync(createMessageDto);
            if (!validation.IsValid)
            {
                var errorText = string.Join(" ", validation.Errors.Select(e => e.ErrorMessage));
                throw new HubException(errorText);
            }

            var normalizedContent = MessageContentRules.Normalize(createMessageDto.Content)!;

            var sender = await userRepository.GetUserByIdAsync(GetUserId());
            var recipient = await userRepository.GetUserByIdAsync(createMessageDto.RecipientId);

            if (recipient == null || sender == null || sender.Id == createMessageDto.RecipientId)
                throw new HubException("Cannot send message.");

            var message = new Message
            {
                SenderId = sender.Id,
                RecipientId = recipient.Id,
                Content = normalizedContent
            };

            messageRepository.AddMessage(message);

            if (await userRepository.Complete())
            {
                var group = GetGroupName(sender.Id, recipient.Id);
                await Clients.Group(group).SendAsync("New message", message.ToDto());

                await notificationService.CreateAsync(new eCommerce.Model.Requests.NotificationCreateRequest
                {
                    UserId = recipient.Id,
                    Title = "New message",
                    Message = $"You received a new message from {sender.FirstName} {sender.LastName}.",
                    Type = "message"
                });

            }
        }
    }
}
