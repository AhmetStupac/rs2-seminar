namespace eCommerce.Model.Requests
{
    public class GroupTrainingSessionUpsertRequest
    {
        public string Name { get; set; } = string.Empty;
        public string TrainingType { get; set; } = string.Empty;
        public int KcalBurned { get; set; }
        public int DurationMinutes { get; set; }
        public string Place { get; set; } = string.Empty;
        public string? Notes { get; set; }
    }
}
