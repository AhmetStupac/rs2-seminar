using eCommerce.Model.Enums;

namespace eCommerce.Model.Requests
{
    public class PaymentCreateRequest
    {
        public int UserId { get; set; }
        public PaymentItemType ItemType { get; set; }

        /// <summary>
        /// ID of the TrainingPlan or NutritionPlan being purchased.
        /// Not required for Membership payments (use CustomAmountInCents instead).
        /// </summary>
        public int? ItemId { get; set; }

        /// <summary>
        /// Required only for Membership payments where no item record holds the price.
        /// </summary>
        public int? CustomAmountInCents { get; set; }
    }
}
