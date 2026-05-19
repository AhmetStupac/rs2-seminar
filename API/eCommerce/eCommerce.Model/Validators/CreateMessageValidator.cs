using eCommerce.Model.Constants;
using eCommerce.Model.Responses;
using FluentValidation;

namespace eCommerce.Model.Validators
{
    public class CreateMessageValidator : AbstractValidator<CreateMessageDTO>
    {
        public CreateMessageValidator()
        {
            RuleFor(x => x.RecipientId)
                .GreaterThan(0)
                .WithMessage("A valid recipient is required.");

            RuleFor(x => x.Content)
                .NotEmpty()
                .WithMessage("Message content is required.")
                .Must(content => MessageContentRules.Normalize(content) != null)
                .WithMessage("Message content cannot be empty or whitespace only.")
                .Must(content =>
                {
                    var normalized = MessageContentRules.Normalize(content);
                    return normalized != null && normalized.Length <= MessageContentRules.MaxLength;
                })
                .WithMessage($"Message cannot exceed {MessageContentRules.MaxLength} characters.");
        }
    }
}
