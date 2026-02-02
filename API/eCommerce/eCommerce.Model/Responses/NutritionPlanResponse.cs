using System;

namespace eCommerce.Model.Responses
{
    public class NutritionPlanResponse
    {
        public int Id { get; set; }
        public int TrainerId { get; set; }
        public string? TrainerName { get; set; }
        public int UserId { get; set; }
        public string? UserName { get; set; }
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
