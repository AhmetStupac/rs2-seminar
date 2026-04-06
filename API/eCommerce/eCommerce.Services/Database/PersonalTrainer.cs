using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class PersonalTrainer
    {
        [Key]
        public int Id { get; set; }
        [ForeignKey(nameof(User))]
        public int? UserId { get; set; }
        public User? User { get; set; }
        public int YearsOfExperience { get; set; }
        public bool? IsActive { get; set; }
        public string? Gender { get; set; }
        public string? Certifications { get; set; }
        public string? Sport { get; set; }

        // Navigation property for ratings
        public ICollection<PersonalTrainerRating> Ratings { get; set; } = new List<PersonalTrainerRating>();
    }
}
