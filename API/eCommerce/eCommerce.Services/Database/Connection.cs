using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class Connection
    {
        [Key]
        public string ConnectionId { get; set; } = string.Empty; // SignalR connection ID
        
        public int UserId { get; set; } 
        
        public string GroupName { get; set; } = string.Empty;

        // nav property
        public Group Group { get; set; } = null!;
    }
}
