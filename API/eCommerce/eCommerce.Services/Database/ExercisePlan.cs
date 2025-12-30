using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class ExercisePlan
    {
        [Key]
        public int Id { get; set; }
        [ForeignKey(nameof(TrainingPlan))]
        public int TrainingPlanId { get; set; }
        public TrainingPlan TrainingPlan { get; set; }
        [ForeignKey(nameof(Exercise))]
        public int ExerciseId { get; set; }
        public Exercise Exercise { get; set; }
        public int? Sets { get; set; }
        public int? Reps { get; set; }
        public int? Duration { get; set; } // in minutes
        public float? CustomPrice { get; set; }
        public string Note { get; set; }
    }
}
