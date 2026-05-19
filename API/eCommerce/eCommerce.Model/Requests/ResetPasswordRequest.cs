using System.ComponentModel.DataAnnotations;

namespace eCommerce.Model.Requests
{
    public class ResetPasswordRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }

        [Required]
        [StringLength(6, MinimumLength = 6, ErrorMessage = "Verification code must be exactly 6 digits")]
        public string Code { get; set; }

        [Required]
        [MinLength(6, ErrorMessage = "Password must be at least 6 characters")]
        public string NewPassword { get; set; }

        //[Required]
        //[Compare("NewPassword", ErrorMessage = "Passwords do not match")]
        //public string ConfirmPassword { get; set; }
    }
}
