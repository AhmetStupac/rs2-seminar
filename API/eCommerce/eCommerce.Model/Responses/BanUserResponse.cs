using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Responses
{
    public class BanUserResponse
    {
        public int UserId { get; set; }
        public string Reason { get; set; }
        public DateTime? ExpiresAt { get; set; } // null = permanentno banovanje
    }
}
