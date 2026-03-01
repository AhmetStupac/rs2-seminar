using eCommerce.Model.Requests;
using FluentValidation;

namespace eCommerce.Model.Validators
{
    public class EquipmentValidator : AbstractValidator<EquipmentUpsertRequest>
    {
        public EquipmentValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Equipment name is required.");
        }
    }
}
