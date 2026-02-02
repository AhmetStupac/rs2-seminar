using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class NutritionPlan
    {
        [Key]
        public int Id { get; set; }
        [ForeignKey(nameof(PersonalTrainer))]
        public int PersonalTrainerId { get; set; }
        public PersonalTrainer PersonalTrainer { get; set; }
        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public User? User { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string TotalCalories { get; set; }
        public string Protein { get; set; }
        public string Carbs { get; set; }
        public int Fats { get; set; }
        public float Price { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
