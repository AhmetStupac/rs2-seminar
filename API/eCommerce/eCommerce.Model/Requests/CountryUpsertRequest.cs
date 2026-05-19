using System.ComponentModel.DataAnnotations;

namespace eCommerce.Model.Requests
{
    public class CountryUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; }
    }
}
