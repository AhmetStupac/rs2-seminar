using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class UserPurchasedTrainingPlan
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public User User { get; set; } = null!;

        [ForeignKey(nameof(Payment))]
        public int PaymentId { get; set; }
        public Payment Payment { get; set; } = null!;

        [ForeignKey(nameof(TrainingPlan))]
        public int TrainingPlanId { get; set; }
        public TrainingPlan TrainingPlan { get; set; } = null!;

        public DateTime BoughtAt { get; set; } = DateTime.UtcNow;
    }
}
