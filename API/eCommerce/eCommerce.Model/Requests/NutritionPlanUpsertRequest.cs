using System;

namespace eCommerce.Model.Requests
{
    public class NutritionPlanUpsertRequest
    {
        public int TrainerId { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string TotalCalories { get; set; }
        public string Protein { get; set; }
        public string Carbs { get; set; }
        public int Fats { get; set; }
        public float Price { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
