namespace eCommerce.Model.SearchObjects
{
    public class ExercisePlanSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? TrainingPlanId { get; set; }
        public int? ExerciseId { get; set; }
    }
}