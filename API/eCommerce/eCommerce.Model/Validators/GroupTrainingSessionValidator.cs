using eCommerce.Model.Requests;
using FluentValidation;

namespace eCommerce.Model.Validators
{
    public class GroupTrainingSessionValidator : AbstractValidator<GroupTrainingSessionUpsertRequest>
    {
        public GroupTrainingSessionValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Name is required.")
                .MaximumLength(100).WithMessage("Name must not exceed 100 characters.");

            RuleFor(x => x.TrainingType)
                .NotEmpty().WithMessage("Training type is required.")
                .MaximumLength(100).WithMessage("Training type must not exceed 100 characters.");

            RuleFor(x => x.KcalBurned)
                .GreaterThan(0).WithMessage("Kcal burned must be greater than 0.");

            RuleFor(x => x.DurationMinutes)
                .GreaterThan(0).WithMessage("Duration must be greater than 0 minutes.");

            RuleFor(x => x.Place)
                .NotEmpty().WithMessage("Place is required.")
                .MaximumLength(200).WithMessage("Place must not exceed 200 characters.");

            RuleFor(x => x.Notes)
                .MaximumLength(1000).When(x => x.Notes != null)
                .WithMessage("Notes must not exceed 1000 characters.");
        }
    }
}
