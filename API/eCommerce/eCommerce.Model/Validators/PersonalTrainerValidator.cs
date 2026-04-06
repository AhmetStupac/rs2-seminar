using eCommerce.Model.Requests;
using FluentValidation;

namespace eCommerce.Model.Validators
{
    public class PersonalTrainerValidator : AbstractValidator<PersonalTrainerUpsertRequest>
    {
        public PersonalTrainerValidator()
        {
            RuleFor(x => x.UserId)
                .NotEmpty().WithMessage("UserId is required.");

            RuleFor(x => x.YearsOfExperience)
                .GreaterThanOrEqualTo(0).WithMessage("Years of experience cannot be negative.")
                .LessThan(100).WithMessage("Years of experience must be less than 100.");

            RuleFor(x => x.Sport)
                .Matches(@"[a-zA-Z]").When(x => !string.IsNullOrEmpty(x.Sport))
                .WithMessage("Sport must contain at least one letter.");

            RuleFor(x => x.Gender)
                .Must(g => string.IsNullOrWhiteSpace(g) ||
                           string.Equals(g, "Male", System.StringComparison.OrdinalIgnoreCase) ||
                           string.Equals(g, "Female", System.StringComparison.OrdinalIgnoreCase) ||
                           string.Equals(g, "Other", System.StringComparison.OrdinalIgnoreCase))
                .WithMessage("Gender must be Male, Female or Other.");
        }
    }
}
