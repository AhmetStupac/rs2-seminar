using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class UserPurchasedNutritionPlan
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public User User { get; set; } = null!;

        [ForeignKey(nameof(Payment))]
        public int PaymentId { get; set; }
        public Payment Payment { get; set; } = null!;

        [ForeignKey(nameof(NutritionPlan))]
        public int NutritionPlanId { get; set; }
        public NutritionPlan NutritionPlan { get; set; } = null!;

        public DateTime BoughtAt { get; set; } = DateTime.UtcNow;
    }
}
