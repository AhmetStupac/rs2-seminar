using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eCommerce.Services.Database
{
    public class GroupTrainingSessionParticipant
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(GroupTrainingSession))]
        public int GroupTrainingSessionId { get; set; }
        public GroupTrainingSession GroupTrainingSession { get; set; } = null!;

        [ForeignKey(nameof(User))]
        public int UserId { get; set; }
        public User User { get; set; } = null!;

        public DateTime JoinedAt { get; set; } = DateTime.UtcNow;
    }
}
