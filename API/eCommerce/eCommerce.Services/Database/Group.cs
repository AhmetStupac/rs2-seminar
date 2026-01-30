using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

namespace eCommerce.Services.Database
{
    public class Group(string name)
    {
        [Key]
        public string Name { get; set; } = name;

        // nav properties
        public ICollection<Connection> Connections { get; set; } = [];
    }
}
