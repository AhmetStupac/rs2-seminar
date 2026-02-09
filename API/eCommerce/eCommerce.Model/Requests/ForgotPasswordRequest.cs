using System.ComponentModel.DataAnnotations;

namespace eCommerce.Model.Requests
{
    public class ForgotPasswordRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }
    }
}
