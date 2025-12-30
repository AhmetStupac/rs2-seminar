using System;

namespace eCommerce.Model.Requests
{
    public class PersonalTrainerUpsertRequest
    {
        public int? Id { get; set; }
        public int UserId { get; set; }
        public int YearsOfExperience { get; set; }
        public bool? IsActive { get; set; }
        public string? Certifications { get; set; }
    }
}
