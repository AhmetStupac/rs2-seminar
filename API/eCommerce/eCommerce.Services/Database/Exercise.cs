using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services.Database
{
    public class Exercise
    {
        [Key]
        public int Id { get; set; }
        public string Name { get; set; }
        public ICollection<ExerciseMuscleGroup> ExerciseMuscleGroups { get; set; } 
        [ForeignKey(nameof(Equipment))]
        public int EquipmentId { get; set; }
        public Equipment Equipment { get; set; }
    }
}
