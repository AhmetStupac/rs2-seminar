namespace eCommerce.Model.SearchObjects
{
    public class PersonalTrainerRatingSearchObject : BaseSearchObject
    {
        public int? PersonalTrainerId { get; set; }
        public int? UserId { get; set; }
        public int? MinRating { get; set; }
        public int? MaxRating { get; set; }
    }
}
