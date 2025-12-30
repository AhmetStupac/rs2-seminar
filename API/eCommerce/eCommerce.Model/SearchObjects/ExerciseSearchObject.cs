using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.SearchObjects
{
    public class ExerciseSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? MuscleGroupId { get; set; }
    }
}
