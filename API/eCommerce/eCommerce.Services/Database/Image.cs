using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class Image
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Url { get; set; }
        public long Size { get; set; }
        public bool IsHeader { get; set; }  // Used for Profile picture for User and Header image for Competition
        public int? UserId { get; set; }
        public User? User { get; set; }

    }
}
