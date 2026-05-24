using eCommerce.Model.Enums;

namespace eCommerce.Model.Requests
{
    public class PaymentCreateRequest
    {
        public int UserId { get; set; }
        public PaymentItemType ItemType { get; set; }

        /// <summary>
        /// ID of the purchased item: TrainingPlan ID, NutritionPlan ID, or PersonalTrainer ID for Membership.
        /// </summary>
        public int? ItemId { get; set; }
    }
}
