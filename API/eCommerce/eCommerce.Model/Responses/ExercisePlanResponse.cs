namespace eCommerce.Model.Responses
{
    public class ExercisePlanResponse
    {
        public int Id { get; set; }
        public int TrainingPlanId { get; set; }
        public string TrainingPlanName { get; set; }
        public int ExerciseId { get; set; }
        public string ExerciseName { get; set; }
        public int? Sets { get; set; }
        public int? Reps { get; set; }
        public int? Duration { get; set; }
        public float? CustomPrice { get; set; }
        public string Note { get; set; }
    }
}