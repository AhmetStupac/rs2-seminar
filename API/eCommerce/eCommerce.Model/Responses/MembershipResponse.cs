using System;

namespace eCommerce.Model.Responses
{
    public class MembershipResponse
    {
        public int Id { get; set; }
        public int ClientUserId { get; set; }
        public string? ClientFullName { get; set; }
        public int PersonalTrainerId { get; set; }
        public string? TrainerFullName { get; set; }
        public int? PaymentId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime ExpiryDate { get; set; }
        public bool IsActive { get; set; }
        public bool IsRevoked { get; set; }
        public int DaysRemaining { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
