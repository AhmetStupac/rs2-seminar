namespace eCommerce.Model.Messages
{
    public class LoginNotificationMessage
    {
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string LoginTime { get; set; }
    }
}
