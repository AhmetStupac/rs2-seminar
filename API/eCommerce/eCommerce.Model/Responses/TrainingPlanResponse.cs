using System;
using System.Collections.Generic;

namespace eCommerce.Model.Responses
{
    public class TrainingPlanResponse
    {
        public int Id{ get; set; }
        public int PersonalTrainerId { get; set; } // kako da navedem ime personal trainer-a kroz entitet user
        public string PersonalTrainerUserFirstName { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public float BasePrice { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        // List of exercises in this training plan
        public List<ExercisePlanResponse> Exercises { get; set; } = new List<ExercisePlanResponse>();
    }
}
