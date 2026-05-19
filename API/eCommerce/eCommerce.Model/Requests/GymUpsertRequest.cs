namespace eCommerce.Model.Requests
{
    public class GymUpsertRequest
    {
        public string Name { get; set; }
        public string Address { get; set; }
        public int? CityId { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public string WorkTime { get; set; }
        public int? ImageId { get; set; }
    }
}
