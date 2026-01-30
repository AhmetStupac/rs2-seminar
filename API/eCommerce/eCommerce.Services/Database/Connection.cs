using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class Connection(string connectionId, string userId)
    {
        public string ConnectionId { get; set; } = connectionId;
        public string UserId { get; set; } = userId;

        // nav property
        public Group Group { get; set; } = null!;
    }
}
