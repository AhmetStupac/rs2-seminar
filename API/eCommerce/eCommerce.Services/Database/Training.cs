using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class Training
    {
        [Key]
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public int Duration { get; set; } // Duration in minutes
        [ForeignKey(nameof(User))]
        public int ClientId { get; set; }
        public User Client { get; set; }
        [ForeignKey(nameof(PersonalTrainer))]
        public int PersonalTrainerId { get; set; }
        public PersonalTrainer PersonalTrainer { get; set; }
    }
}