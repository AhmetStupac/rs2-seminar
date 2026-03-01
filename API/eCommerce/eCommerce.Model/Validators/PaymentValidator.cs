using eCommerce.Model.Enums;
using eCommerce.Model.Requests;
using FluentValidation;

namespace eCommerce.Model.Validators
{
    public class PaymentValidator : AbstractValidator<PaymentCreateRequest>
    {
        public PaymentValidator()
        {
            RuleFor(x => x.UserId)
                .GreaterThan(0)
                .WithMessage("UserId is required.");

            RuleFor(x => x.ItemType)
                .IsInEnum()
                .WithMessage("ItemType must be a valid PaymentItemType.");

            RuleFor(x => x.ItemId)
                .NotNull()
                .GreaterThan(0)
                .WithMessage("ItemId is required. For TrainingPlan/NutritionPlan it is the plan ID; for Membership it is the PersonalTrainer ID.");

            RuleFor(x => x.CustomAmountInCents)
                .NotNull()
                .GreaterThan(0)
                .When(x => x.ItemType == PaymentItemType.Membership)
                .WithMessage("CustomAmountInCents is required for Membership purchases and must be greater than 0.");
        }
    }
}
