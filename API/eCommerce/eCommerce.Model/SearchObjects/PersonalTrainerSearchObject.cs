using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.SearchObjects
{
    public class PersonalTrainerSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? Sport { get; set; }
        public double? MinRating { get; set; }
        public string? Gender { get; set; }
        public float? MinPrice { get; set; }
        public float? MaxPrice { get; set; }
    }
}
