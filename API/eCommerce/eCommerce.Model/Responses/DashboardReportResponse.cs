using System.Collections.Generic;

namespace eCommerce.Model.Responses
{
    public class DashboardReportResponse
    {
        public int TotalPersonalTrainers { get; set; }
        public int TotalUsers { get; set; }
        public int TotalGyms { get; set; }
        public List<TopTrainerReportItem> TopTrainers { get; set; } = new List<TopTrainerReportItem>();
    }

    public class TopTrainerReportItem
    {
        public int TrainerId { get; set; }
        public string TrainerFullName { get; set; }
        public double AverageRating { get; set; }
        public int RatingCount { get; set; }
    }
}
