using eCommerce.Model.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Responses
{
    public class TrainingSessionResponse
    {
        public int Id { get; set; }
        public int? ClientId { get; set; }
        public string ClientName { get; set; }
        public int PersonalTrainerId { get; set; }
        public string TrainerName { get; set; }
        public int? GymId { get; set; }
        public string GymName { get; set; }
        public DateTime ScheduledDateTime { get; set; }
        public int DurationMinutes { get; set; }
        public TrainingSessionStatus Status { get; set; }
        public string StatusDisplay { get; set; }
        public string? Notes { get; set; }
        public string? TrainerNotes { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool CanEdit { get; set; } // Da li trenutni korisnik može da edituje
        public bool CanCancel { get; set; }
    }


}
