using System.ComponentModel.DataAnnotations;

namespace eCommerce.Model.Requests
{
    public class RefundDecisionRequest
    {
        [Required]
        public string StripePaymentIntentId { get; set; } = string.Empty;

        public bool Approve { get; set; }
    }
}
