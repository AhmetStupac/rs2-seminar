namespace eCommerce.Model.Responses
{
    public class GymResponse
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public int? CityId { get; set; }
        public string? CityName { get; set; }
        public string? CountryName { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public string WorkTime { get; set; }
        public int? ImageId { get; set; }
        public string? ImageUrl { get; set; }
    }
}
