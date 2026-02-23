using eCommerce.Model.Enums;
using System;

namespace eCommerce.Model.Responses
{
    public class PaymentResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public PaymentItemType ItemType { get; set; }
        public int? ItemId { get; set; }
        public int AmountInCents { get; set; }
        public string StripePaymentIntentId { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
