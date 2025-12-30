using System.Collections.Generic;

namespace eCommerce.Model.Requests
{
    public class ExerciseUpsertRequest
    {
        public string Name { get; set; }
        public int MuscleGroupId { get; set; }
        public int? EquipmentId { get; set; }
    }
}
