using eCommerce.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Validators
{
    public class TrainingPlanValidator : AbstractValidator<TrainingPlanUpsertRequest>
    {
        public TrainingPlanValidator()
        {
            RuleFor(x => x.PersonalTrainerId).NotEmpty().WithMessage("Personal Trainer Id is required");
            RuleFor(x => x.UserId).NotEmpty().WithMessage("Client id is required");
            RuleFor(x => x.Title).NotEmpty().WithMessage("Title is required");
            RuleFor(x => x.BasePrice)
                .NotNull().WithMessage("Price is required.")
                .GreaterThan(0).WithMessage("Price must be greater than 0.");

        }
    }
}
