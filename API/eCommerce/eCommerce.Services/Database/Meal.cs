using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class Meal // cijeli obrok npr. rucak
    {
        [Key]
        public int Id { get; set; }
        [ForeignKey(nameof(NutritionPlan))]
        public int NutritionPlanId { get; set; }
        public NutritionPlan NutritionPlan { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string Calories { get; set; }
    }
}
