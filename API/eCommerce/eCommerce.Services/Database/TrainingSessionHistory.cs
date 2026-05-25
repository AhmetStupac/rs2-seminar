using eCommerce.Model.Enums;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    /// <summary>
    /// Append-only audit log of training session status transitions.
    /// </summary>
    public class TrainingSessionHistory
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(TrainingSession))]
        public int TrainingSessionId { get; set; }
        public TrainingSession TrainingSession { get; set; } = null!;

        public TrainingSessionStatus? FromStatus { get; set; }
        public TrainingSessionStatus ToStatus { get; set; }

        public DateTime ChangedAt { get; set; }

        [ForeignKey(nameof(ChangedByUser))]
        public int ChangedByUserId { get; set; }
        public User? ChangedByUser { get; set; }

        public string? Note { get; set; }
    }
}
