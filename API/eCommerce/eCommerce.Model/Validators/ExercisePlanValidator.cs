using eCommerce.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Validators
{
    public class ExercisePlanValidator : AbstractValidator<ExercisePlanUpsertRequest>
    {

        public ExercisePlanValidator()
        {
            RuleFor(x => x.ExerciseId).NotEmpty().WithMessage("ExerciseId is required.");

            RuleFor(x => x.TrainingPlanId).NotEmpty().WithMessage("TrainingPlanId is required.");

            RuleFor(x => x.Sets)
                .GreaterThan(0).When(x => x.Sets.HasValue)
                .WithMessage("Sets must be greater than 0.");

            RuleFor(x => x.Reps).GreaterThan(0).When(x=> x.Reps.HasValue).WithMessage("Reps must be greater than 0.");

            RuleFor(x => x.Duration)
                .Must(val => !val.HasValue || val is int)
                .WithMessage("Duration must be a number");

            RuleFor(x => x.CustomPrice).Must(val => !val.HasValue || val is float)
                .WithMessage("Custom price must be a type of number");
        } 
    }
}
