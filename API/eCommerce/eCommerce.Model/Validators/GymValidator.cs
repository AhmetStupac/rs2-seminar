using eCommerce.Model.Requests;
using FluentValidation;

namespace eCommerce.Model.Validators
{
    public class GymValidator : AbstractValidator<GymUpsertRequest>
    {
        public GymValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Gym name is required.")
                .MaximumLength(200).WithMessage("Gym name cannot exceed 200 characters.");

            RuleFor(x => x.Address)
                .NotEmpty().WithMessage("Address is required.")
                .MaximumLength(500).WithMessage("Address cannot exceed 500 characters.");

            RuleFor(x => x.CityId)
                .NotNull().WithMessage("City is required.")
                .GreaterThan(0).WithMessage("A valid city must be selected.");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required.")
                .EmailAddress().WithMessage("Invalid email format.")
                .MaximumLength(255).WithMessage("Email cannot exceed 255 characters.");

            RuleFor(x => x.PhoneNumber)
                .NotEmpty().WithMessage("Phone number is required.")
                .MaximumLength(20).WithMessage("Phone number cannot exceed 20 characters.");

            RuleFor(x => x.WorkTime)
                .NotEmpty().WithMessage("Work time is required.")
                .MaximumLength(100).WithMessage("Work time cannot exceed 100 characters.");
        }
    }
}
