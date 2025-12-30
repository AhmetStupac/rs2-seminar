using System;

namespace eCommerce.Model.Responses
{
    public class TrainingPlanResponse
    {
        public int PersonalTrainerId { get; set; } // kako da navedem ime personal trainer-a kroz entitet user
        public string PersonalTrainerUserFirstName { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public float BasePrice { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
