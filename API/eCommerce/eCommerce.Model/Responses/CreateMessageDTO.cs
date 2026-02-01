using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Responses
{
    public class CreateMessageDTO
    {
        public int RecipientId { get; set; }
        public string Content { get; set; }
    }
}
