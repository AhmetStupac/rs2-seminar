using eCommerce.Model.Enums;
using System;

namespace eCommerce.Model.Responses
{
    public class TrainingSessionHistoryResponse
    {
        public int Id { get; set; }
        public int TrainingSessionId { get; set; }
        public TrainingSessionStatus? FromStatus { get; set; }
        public TrainingSessionStatus ToStatus { get; set; }
        public DateTime ChangedAt { get; set; }
        public int ChangedByUserId { get; set; }
        public string? ChangedByUserName { get; set; }
        public string? Note { get; set; }
    }
}
