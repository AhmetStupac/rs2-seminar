namespace eCommerce.Model.SearchObjects
{
    public class GymSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? CityId { get; set; }
        public int? CountryId { get; set; }
    }
}
