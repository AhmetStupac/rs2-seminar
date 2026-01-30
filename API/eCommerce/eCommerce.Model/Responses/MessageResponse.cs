using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Responses
{
    public class MessageResponse
    {
        public  string Id { get; set; }
        public  string SenderId { get; set; }
        public  string SenderDisplayName { get; set; }
        public string? SenderImageUrl { get; set; }
        public  string RecipientId { get; set; }
        public string RecipientDisplayName { get; set; }
        public string? RecipientImageUrl { get; set; }
        public string Content { get; set; }
        public DateTime? DateRead { get; set; }
        public DateTime MessageSent { get; set; }
    }
}
