using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class Equipment
    {
        [Key]
        public int Id { get; set; }
        public string Name { get; set; }
    }
}
