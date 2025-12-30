using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class MealFood // hrana unutar obroka npr. "Piletina"
    {
        [Key]
        public int Id { get; set; }
        [ForeignKey(nameof(Meal))]
        public int MealId { get; set; }
        public Meal Meal { get; set; }
        public string FoodName { get; set; }
        public string Quantity { get; set; }  // “150g”, “1 cup”
        // mozes dodati kalorije proteini itd.
    }
}
