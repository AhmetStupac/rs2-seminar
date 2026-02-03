namespace eCommerce.Model.Responses
{
    public class GymResponse
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string Country { get; set; }
        public string Email { get; set; }
        public string PhoneNumber { get; set; }
        public string WorkTime { get; set; }
        public int? ImageId { get; set; }
        public string ImageUrl { get; set; }
    }
}
