using eCommerce.Model.Requests;
using FluentValidation;

namespace eCommerce.Model.Validators
{
    public class MuscleGroupValidator : AbstractValidator<MuscleGroupUpsertRequest>
    {
        public MuscleGroupValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Muscle group name is required.");
        }
    }
}
