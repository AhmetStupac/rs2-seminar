using System;

namespace eCommerce.Model.Requests
{
    public class TrainingSessionUpsertRequest
    {
      
            public int PersonalTrainerId { get; set; }
            public int? GymId { get; set; }
            public DateTime ScheduledDateTime { get; set; }
            public int DurationMinutes { get; set; }
            public string? Notes { get; set; }
            public string? TrainerNotes { get; set; }
    }

    public class TrainingSessionCancelRequest
    {
        public string CancellationReason { get; set; }
    }
}
