using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class Gym
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string Address { get; set; } = string.Empty;

        [ForeignKey(nameof(City))]
        public int? CityId { get; set; }
        public City? City { get; set; }

        [Required]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required]
        public string WorkTime { get; set; } = string.Empty;

        [ForeignKey(nameof(Image))]
        public int? ImageId { get; set; }
        public Image? Image { get; set; }
    }
}
