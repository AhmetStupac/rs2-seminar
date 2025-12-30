using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace eCommerce.Model.Requests
{
    public class TrainingPlanUpsertRequest
    {
        public int PersonalTrainerId { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public float BasePrice { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
