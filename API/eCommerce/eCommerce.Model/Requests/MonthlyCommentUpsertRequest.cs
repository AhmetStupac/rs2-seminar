using System.ComponentModel.DataAnnotations;

namespace eCommerce.Model.Requests
{
    public class MonthlyCommentUpsertRequest
    {
        [Required]
        public int Year { get; set; }

        [Required]
        [Range(1, 12, ErrorMessage = "Month must be between 1 and 12")]
        public int Month { get; set; }

        [MaxLength(1000, ErrorMessage = "Comment cannot exceed 1000 characters")]
        public string? Comment { get; set; }
    }
}
