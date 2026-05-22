using eCommerce.Model.Requests;
using FluentValidation;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace eCommerce.Model.Validators
{
    public class TrainingSessionValidator : AbstractValidator<TrainingSessionUpsertRequest>
    {


        public TrainingSessionValidator()
        {

            RuleFor(x => x.ScheduledDateTime)
                .NotEmpty().WithMessage("Date and time are required")
                .GreaterThan(DateTime.Now.AddHours(2))
                .WithMessage("Training must be scheduled at least 2 hours in advance")
                .Must(BeWithinWorkingHours)
                .WithMessage("Training can only be scheduled between 6:00 AM and 9:00 PM");

            RuleFor(x => x.DurationMinutes)
                .NotEmpty()
                .InclusiveBetween(30, 180)
                .WithMessage("Duration must be between 30 and 180 minutes");

   
        }

    public class TrainingSessionCancelValidator : AbstractValidator<TrainingSessionCancelRequest>
    {
        public TrainingSessionCancelValidator()
        {
            RuleFor(x => x.CancellationReason)
                .NotEmpty()
                .WithMessage("Cancellation reason is required");
        }
    }

        private bool BeWithinWorkingHours(DateTime scheduledDateTime)
        {
            var hour = scheduledDateTime.Hour;
            return hour >= 6 && hour < 21;
        }

      
        
    }
}
