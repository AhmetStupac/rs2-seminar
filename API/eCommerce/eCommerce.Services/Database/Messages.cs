using AutoMapper.Execution;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class Message
    {
        public int Id { get; set; } 
        public required string Content { get; set; }
        public DateTime? DateRead { get; set; }
        public DateTime MessageSent { get; set; } = DateTime.UtcNow;
        public bool SenderDeleted { get; set; }
        public bool RecipientDeleted { get; set; }

        // nav properties
        public int? SenderId { get; set; }
        public User? Sender { get; set; }
        
        public int? RecipientId { get; set; }
        public User? Recipient { get; set; }
    }
}
