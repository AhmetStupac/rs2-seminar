namespace eCommerce.Model.Responses
{
    public class TrainerDashboardResponse
    {
        public int TrainerId { get; set; }
        public string TrainerFullName { get; set; }

        // Plans the trainer has created
        public int TotalTrainingPlansCreated { get; set; }
        public int TotalNutritionPlansCreated { get; set; }

        // Number of distinct clients (users who purchased something)
        public int TotalClients { get; set; }

        // Sold items (payments with status "succeeded")
        public int SoldTrainingPlans { get; set; }
        public int SoldNutritionPlans { get; set; }
        public int SoldMemberships { get; set; }

        // Total revenue in EUR
        public decimal TotalEarnedEur { get; set; }

        // Rating aggregates
        public double AverageRating { get; set; }
        public int RatingCount { get; set; }
    }
}
