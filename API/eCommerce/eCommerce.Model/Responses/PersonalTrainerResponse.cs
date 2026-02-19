using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace eCommerce.Model.Responses
{
    public class PersonalTrainerResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserFirstName { get; set; }
        public int YearsOfExperience { get; set; }
        public bool? IsActive { get; set; }
        public string? Certifications { get; set; }
        public string? Sport { get; set; }
        
        // Rating information
        public double AverageRating { get; set; }
        public int TotalRatings { get; set; }
    }
}
