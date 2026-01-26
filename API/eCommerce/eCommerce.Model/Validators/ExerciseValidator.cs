using eCommerce.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;

namespace eCommerce.Model.Validators
{
    public class ExerciseValidator : AbstractValidator<ExerciseUpsertRequest>
    {
        public ExerciseValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Name is required")
                .MinimumLength(2).WithMessage("Name must be at least 2 characters long")
                .MaximumLength(100).WithMessage("Name must not exceed 100 characters");

            RuleFor(x => x.MuscleGroupId)
                .GreaterThan(0).WithMessage("MuscleGroupId must be greater than 0");


        }

    }
}
