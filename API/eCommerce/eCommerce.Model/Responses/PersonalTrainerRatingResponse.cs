using System;

namespace eCommerce.Model.Responses
{
    public class PersonalTrainerRatingResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public int PersonalTrainerId { get; set; }
        public string PersonalTrainerName { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
