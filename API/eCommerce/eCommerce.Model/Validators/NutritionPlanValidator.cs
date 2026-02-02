using eCommerce.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Validators
{
    public class NutritionPlanValidator : AbstractValidator<NutritionPlanUpsertRequest>
    {
        public NutritionPlanValidator()
        {
            RuleFor(x=> x.PersonalTrainerId).NotEmpty().WithMessage("TrainerId is required.");
            RuleFor(x=> x.UserId).NotEmpty().WithMessage("UserId is required.");

            RuleFor(x => x.Title).NotEmpty().WithMessage("Title is required.")
                .MaximumLength(50).WithMessage("Title cannot exceed 50 characters.");

            RuleFor(x => x.Description).NotEmpty().WithMessage("Description is required.")
                .MaximumLength(500).WithMessage("Description cannot exceed 500 characters.");

            RuleFor(x => x.TotalCalories)
                .NotEmpty().WithMessage("TotalCalories is required.");

                RuleFor(x => x.Fats)
                     .NotEmpty().WithMessage("Fats is required.");

                RuleFor(x => x.TotalCalories)
                    .NotEmpty().WithMessage("TotalCalories is required.");

            RuleFor(x => x.Price)
                .GreaterThan(0).WithMessage("Price must be greater than 0.");

            RuleFor(x => x.Carbs)
                .NotEmpty().WithMessage("Carbs is required.");

            RuleFor(x => x.Protein)
                .NotEmpty().WithMessage("Protein is required.");
        }
    }
}
