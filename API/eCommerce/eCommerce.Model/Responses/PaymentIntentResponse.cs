namespace eCommerce.Model.Responses
{
    public class PaymentIntentResponse
    {
        public string ClientSecret { get; set; }
        public int PaymentRecordId { get; set; }
        public int AmountInCents { get; set; }
    }
}
