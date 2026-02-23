using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class GroupTrainingSession
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string TrainingType { get; set; } = string.Empty; // e.g. "running", "bodyweight training"

        public int KcalBurned { get; set; }

        public int DurationMinutes { get; set; }

        [Required]
        [MaxLength(200)]
        public string Place { get; set; } = string.Empty;

        public string? Notes { get; set; }

        [ForeignKey(nameof(Creator))]
        public int CreatorId { get; set; }
        public User Creator { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<GroupTrainingSessionParticipant> Participants { get; set; } = new List<GroupTrainingSessionParticipant>();
    }
}
