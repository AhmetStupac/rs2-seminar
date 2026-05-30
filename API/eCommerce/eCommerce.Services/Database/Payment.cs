using eCommerce.Model.Enums;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class Payment
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public User User { get; set; }

        public PaymentItemType ItemType { get; set; }

        public int? ItemId { get; set; }

        public int AmountInCents { get; set; }

        public string StripePaymentIntentId { get; set; }

        public string Status { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}

/*
 * UserPurchasedTrainingPlans:
 * - UserId - kupac koji je kupio plan
 * - paymentId - ID paymenta koji se odnosi na kupovinu - foreign key na Payment tablicu
 * - training plan id - ID kupljenog plana - foreign key na TrainingPlan tablicu
 * - boughtAt - datum kupovine
 */

/*
 * UserPurchasedNutritionPlans:
 * - UserId - kupac koji je kupio plan
 * - paymentId - ID paymenta koji se odnosi na kupovinu - foreign key na Payment tablicu
 * - nutrition plan id - ID kupljenog plana - foreign key na TrainingPlan tablicu
 * - boughtAt - datum kupovine
 */
