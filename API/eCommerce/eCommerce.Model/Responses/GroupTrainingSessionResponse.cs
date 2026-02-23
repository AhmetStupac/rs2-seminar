using System;
using System.Collections.Generic;

namespace eCommerce.Model.Responses
{
    public class GroupTrainingSessionResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string TrainingType { get; set; } = string.Empty;
        public int KcalBurned { get; set; }
        public int DurationMinutes { get; set; }
        public string Place { get; set; } = string.Empty;
        public string? Notes { get; set; }
        public int CreatorId { get; set; }
        public string CreatorName { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public int ParticipantCount { get; set; }
        public List<GroupTrainingSessionParticipantResponse> Participants { get; set; } = new List<GroupTrainingSessionParticipantResponse>();
    }

    public class GroupTrainingSessionParticipantResponse
    {
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public DateTime JoinedAt { get; set; }
    }
}
