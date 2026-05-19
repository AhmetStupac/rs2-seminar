using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class City
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [ForeignKey(nameof(Country))]
        public int CountryId { get; set; }
        public Country Country { get; set; } = null!;

        public ICollection<Gym> Gyms { get; set; } = new List<Gym>();
    }
}
