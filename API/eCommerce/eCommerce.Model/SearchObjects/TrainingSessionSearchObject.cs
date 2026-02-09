using eCommerce.Model.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.SearchObjects
{
    public class TrainingSessionSearchObject : BaseSearchObject
    {
        public int? ClientId { get; set; }
        public int? PersonalTrainerId { get; set; }
        public int? GymId { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
        public TrainingSessionStatus? Status { get; set; }
        public bool? IncludeCancelled { get; set; }
    }
}
