 using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Responses
{
    public class ExerciseResponse
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public int MuscleGroupId { get; set; }
        public string MuscleGroupName { get; set; }
        public ImageResponse Image { get; set; }
    }
}
