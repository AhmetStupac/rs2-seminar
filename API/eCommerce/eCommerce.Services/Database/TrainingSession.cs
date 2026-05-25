using eCommerce.Model.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class TrainingSession
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Client))]
        public int? ClientId { get; set; }
        public User? Client { get; set; }

        [ForeignKey(nameof(PersonalTrainer))]
        public int PersonalTrainerId { get; set; }
        public PersonalTrainer PersonalTrainer { get; set; }

        [ForeignKey(nameof(Gym))]
        public int? GymId { get; set; }
        public Gym? Gym { get; set; }

        public DateTime ScheduledDateTime { get; set; }
        public int DurationMinutes { get; set; } // 30, 60, 90, 120
        public TrainingSessionStatus Status { get; set; }
        public float? Price { get; set; }

        public string? Notes { get; set; } // Napomene klijenta
        public string? TrainerNotes { get; set; } // Napomene trenera

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public int? ApprovedByUserId { get; set; }
        public DateTime? CancelledAt { get; set; }
        public int? CancelledByUserId { get; set; }
        public string? CancellationReason { get; set; }
        public DateTime? CompletedAt { get; set; }
        public int? CompletedByUserId { get; set; }
        public DateTime? NoShowAt { get; set; }
        public int? NoShowByUserId { get; set; }

        public ICollection<TrainingSessionHistory> History { get; set; } = new List<TrainingSessionHistory>();
    }
}
