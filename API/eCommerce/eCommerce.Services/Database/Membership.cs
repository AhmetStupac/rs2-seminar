using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class Membership
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Client))]
        public int ClientUserId { get; set; }
        public User Client { get; set; }

        [ForeignKey(nameof(PersonalTrainer))]
        public int PersonalTrainerId { get; set; }
        public PersonalTrainer PersonalTrainer { get; set; }

        [ForeignKey(nameof(Payment))]
        public int? PaymentId { get; set; }
        public Payment? Payment { get; set; }

        public DateTime StartDate { get; set; }

        public DateTime ExpiryDate { get; set; }

        public bool IsActive => !IsRevoked && DateTime.UtcNow <= ExpiryDate;

        public bool IsRevoked { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
