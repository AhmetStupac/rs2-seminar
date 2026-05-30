using eCommerce.Model.Requests;
using FluentValidation;
using System.Threading;
using System.Threading.Tasks;

namespace eCommerce.Model.Validators
{
    public static class UserValidationContextKeys
    {
        public const string ExcludeUserId = "ExcludeUserId";
    }

    public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
    {
        public RegisterRequestValidator(IUserDuplicateChecker duplicateChecker)
        {
            RuleFor(x => x.FirstName)
                .NotEmpty().WithMessage("First name is required.")
                .MaximumLength(50).WithMessage("First name cannot exceed 50 characters.");

            RuleFor(x => x.LastName)
                .NotEmpty().WithMessage("Last name is required.")
                .MaximumLength(50).WithMessage("Last name cannot exceed 50 characters.");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required.")
                .MaximumLength(100).WithMessage("Email cannot exceed 100 characters.")
                .EmailAddress().WithMessage("Invalid email format.")
                .MustAsync((email, cancellation) => UserValidationRules.IsEmailUniqueAsync(duplicateChecker, email, null, cancellation))
                .WithMessage("A user with this email already exists.");

            RuleFor(x => x.Username)
                .NotEmpty().WithMessage("Username is required.")
                .MaximumLength(100).WithMessage("Username cannot exceed 100 characters.")
                .MustAsync((username, cancellation) => UserValidationRules.IsUsernameUniqueAsync(duplicateChecker, username, null, cancellation))
                .WithMessage("A user with this username already exists.");

            RuleFor(x => x.PhoneNumber)
                .MaximumLength(20).WithMessage("Phone number cannot exceed 20 characters.");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required.")
                .MinimumLength(6).WithMessage("Password must be at least 6 characters long.");
        }
    }

    public class UserCreateRequestValidator : AbstractValidator<UserCreateRequest>
    {
        public UserCreateRequestValidator(IUserDuplicateChecker duplicateChecker)
        {
            RuleFor(x => x.FirstName)
                .NotEmpty().WithMessage("First name is required.")
                .MaximumLength(50).WithMessage("First name cannot exceed 50 characters.");

            RuleFor(x => x.LastName)
                .NotEmpty().WithMessage("Last name is required.")
                .MaximumLength(50).WithMessage("Last name cannot exceed 50 characters.");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required.")
                .MaximumLength(100).WithMessage("Email cannot exceed 100 characters.")
                .EmailAddress().WithMessage("Invalid email format.")
                .MustAsync((email, cancellation) => UserValidationRules.IsEmailUniqueAsync(duplicateChecker, email, null, cancellation))
                .WithMessage("A user with this email already exists.");

            RuleFor(x => x.Username)
                .NotEmpty().WithMessage("Username is required.")
                .MaximumLength(100).WithMessage("Username cannot exceed 100 characters.")
                .MustAsync((username, cancellation) => UserValidationRules.IsUsernameUniqueAsync(duplicateChecker, username, null, cancellation))
                .WithMessage("A user with this username already exists.");

            RuleFor(x => x.PhoneNumber)
                .MaximumLength(20).WithMessage("Phone number cannot exceed 20 characters.");

            RuleFor(x => x.Password)
                .MinimumLength(6).When(x => !string.IsNullOrEmpty(x.Password))
                .WithMessage("Password must be at least 6 characters long.");

            RuleFor(x => x.RoleId)
                .GreaterThan(0).When(x => x.RoleId.HasValue)
                .WithMessage("RoleId must be greater than 0.");
        }
    }

    public class UserUpdateRequestValidator : AbstractValidator<UserUpdateRequest>
    {
        public UserUpdateRequestValidator(IUserDuplicateChecker duplicateChecker)
        {
            RuleFor(x => x.FirstName)
                .NotEmpty().WithMessage("First name is required.")
                .MaximumLength(50).WithMessage("First name cannot exceed 50 characters.");

            RuleFor(x => x.LastName)
                .NotEmpty().WithMessage("Last name is required.")
                .MaximumLength(50).WithMessage("Last name cannot exceed 50 characters.");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required.")
                .MaximumLength(100).WithMessage("Email cannot exceed 100 characters.")
                .EmailAddress().WithMessage("Invalid email format.")
                .MustAsync((_, email, context, cancellation) =>
                    UserValidationRules.IsEmailUniqueAsync(duplicateChecker, email, UserValidationRules.GetExcludeUserId(context), cancellation))
                .WithMessage("A user with this email already exists.");

            RuleFor(x => x.Username)
                .NotEmpty().WithMessage("Username is required.")
                .MaximumLength(100).WithMessage("Username cannot exceed 100 characters.")
                .MustAsync((_, username, context, cancellation) =>
                    UserValidationRules.IsUsernameUniqueAsync(duplicateChecker, username, UserValidationRules.GetExcludeUserId(context), cancellation))
                .WithMessage("A user with this username already exists.");

            RuleFor(x => x.PhoneNumber)
                .MaximumLength(20).WithMessage("Phone number cannot exceed 20 characters.");
        }
    }

    internal static class UserValidationRules
    {
        internal static int? GetExcludeUserId(IValidationContext context)
        {
            if (context.RootContextData.TryGetValue(UserValidationContextKeys.ExcludeUserId, out var value) && value is int userId)
                return userId;

            return null;
        }

        internal static async Task<bool> IsEmailUniqueAsync(
            IUserDuplicateChecker duplicateChecker,
            string email,
            int? excludeUserId,
            CancellationToken cancellationToken)
        {
            return !await duplicateChecker.EmailExistsAsync(email, excludeUserId, cancellationToken);
        }

        internal static async Task<bool> IsUsernameUniqueAsync(
            IUserDuplicateChecker duplicateChecker,
            string username,
            int? excludeUserId,
            CancellationToken cancellationToken)
        {
            return !await duplicateChecker.UsernameExistsAsync(username, excludeUserId, cancellationToken);
        }
    }
}
