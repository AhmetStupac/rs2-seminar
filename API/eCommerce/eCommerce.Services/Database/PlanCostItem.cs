using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class PlanCostItem // da bi izbjegli fiksne cijene u TrainingPlan-u, pravimo ovu klasu
    {
        [Key]
        public int Id { get; set; }
        [ForeignKey(nameof(TrainingPlan))]
        public int TrainingPlanId { get; set; }            // Foreign Key to TrainingPlan
        public TrainingPlan TrainingPlan { get; set; }
        public string Name { get; set; } = string.Empty;  // e.g. "Nutrition Plan"
        public float Amount { get; set; }         // cijena
        // dodati fk na nutrition plan 
    }
}
