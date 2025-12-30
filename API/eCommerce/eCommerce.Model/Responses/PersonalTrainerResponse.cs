using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace eCommerce.Model.Responses
{
    public class PersonalTrainerResponse
    {
        public int UserId { get; set; }
        public string UserFirstName { get; set; }
        public int YearsOfExperience { get; set; }
        public bool? IsActive { get; set; }
        public string? Certifications { get; set; }
    }
}
