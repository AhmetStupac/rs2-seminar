namespace eCommerce.Model.Requests
{
    public class ExercisePlanUpsertRequest
    {
        public int TrainingPlanId { get; set; }
        public int ExerciseId { get; set; }
        public int? Sets { get; set; }
        public int? Reps { get; set; }
        public int? Duration { get; set; }
        public float? CustomPrice { get; set; }
        public string Note { get; set; }
    }
}