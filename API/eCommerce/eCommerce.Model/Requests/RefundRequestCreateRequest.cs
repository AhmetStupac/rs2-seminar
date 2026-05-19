using System.ComponentModel.DataAnnotations;

namespace eCommerce.Model.Requests
{
    public class RefundRequestCreateRequest
    {
        [Required]
        public string StripePaymentIntentId { get; set; } = string.Empty;
    }
}
