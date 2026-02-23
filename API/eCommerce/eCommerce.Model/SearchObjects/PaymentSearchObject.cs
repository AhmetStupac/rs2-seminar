using eCommerce.Model.Enums;

namespace eCommerce.Model.SearchObjects
{
    public class PaymentSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public PaymentItemType? ItemType { get; set; }
        public string? Status { get; set; }
    }
}
