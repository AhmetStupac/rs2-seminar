using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Responses
{
    public class MessageResponse
    {
        public  int Id { get; set; }
        public  int SenderId { get; set; }
        public  string SenderDisplayName { get; set; }
       // public string? SenderImageUrl { get; set; }
        public  int RecipientId { get; set; }
        public string RecipientDisplayName { get; set; }
       // public string? RecipientImageUrl { get; set; }
        public string Content { get; set; }
        public DateTime? DateRead { get; set; }
        public DateTime MessageSent { get; set; }
    }
}
