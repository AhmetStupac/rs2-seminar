using System.ComponentModel.DataAnnotations;

namespace eCommerce.Model.Requests
{
    public class CityUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; }

        [Required]
        public int CountryId { get; set; }
    }
}
