namespace eCommerce.Model.Requests
{
    public class NotificationCreateRequest
    {
        public int UserId { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public string Type { get; set; }
    }
}
