using eCommerce.Model.Constants;
using eCommerce.Model.Responses;
using eCommerce.Services;
using eCommerce.Services.Database;
using eCommerce.Services.Extensions;
using eCommerce.Services.Interface;
using eCommerce.Services.SignalR;
using FluentValidation;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace eCommerce.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MessageController : ControllerBase
    {
        private readonly IMessageRepository _messageRepository;
        private readonly IUserRepository _userRepository;
        private readonly IHubContext<MessageHub> _hubContext;
        private readonly IValidator<CreateMessageDTO> _validator;

        public MessageController(
            IMessageRepository messageRepository,
            IUserRepository userRepository,
            IHubContext<MessageHub> hubContext,
            IValidator<CreateMessageDTO> validator)
        {
            _messageRepository = messageRepository;
            _userRepository = userRepository;
            _hubContext = hubContext;
            _validator = validator;
        }

        [HttpPost("send")]
        public async Task<IActionResult> SendMessage([FromBody] CreateMessageDTO dto)
        {
            var validation = await _validator.ValidateAsync(dto);
            if (!validation.IsValid)
                return BadRequest(new { message = string.Join(" ", validation.Errors.Select(e => e.ErrorMessage)) });

            var normalizedContent = MessageContentRules.Normalize(dto.Content)!;

            var senderId = User.GetUserId();
            var sender = await _userRepository.GetUserByIdAsync(senderId);
            var recipient = await _userRepository.GetUserByIdAsync(dto.RecipientId);

            if (recipient == null || sender == null || sender.Id == dto.RecipientId)
                return BadRequest(new { message = "Cannot send message." });

            var message = new Message
            {
                SenderId = sender.Id, 
                RecipientId = recipient.Id,
                Content = normalizedContent
            };

            _messageRepository.AddMessage(message);

            if (await _userRepository.Complete())
            {
                var group = GetGroupName(sender.Id.ToString(), recipient.Id.ToString());
                await _hubContext.Clients.Group(group).SendAsync("New message", message.ToDto());
                return Ok();
            }

            return BadRequest(new { message = "Failed to send message." });
        }

        private static string GetGroupName(string caller, string otherUser)
        {
            var stringCompare = string.CompareOrdinal(caller, otherUser) < 0;
            return stringCompare ? $"{caller}-{otherUser}" : $"{otherUser}-{caller}";
        }
    }
}
