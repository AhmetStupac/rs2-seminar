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
       // private readonly IB210033DbContext _context;

        public TrainingSessionValidator(/*IB210033DbContext context*/)
        {
            //_context = context;

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

        //    RuleFor(x => x.PersonalTrainerId)
        //        .NotEmpty()
        //        .MustAsync(PersonalTrainerExists)
        //        .WithMessage("Trener ne postoji");

        //    RuleFor(x => x)
        //        .MustAsync(TrainerIsAvailable)
        //        .WithMessage("Trener nije dostupan u traženom terminu");
        }

        private bool BeWithinWorkingHours(DateTime scheduledDateTime)
        {
            var hour = scheduledDateTime.Hour;
            return hour >= 6 && hour < 21;
        }

        //private async Task<bool> PersonalTrainerExists(int trainerId, CancellationToken cancellationToken)
        //{
        //    return await _context.PersonalTrainers.AnyAsync(pt => pt.Id == trainerId, cancellationToken);
        //}

        //private async Task<bool> TrainerIsAvailable(TrainingSessionUpsertRequest request, CancellationToken cancellationToken)
        //{
        //    var endTime = request.ScheduledDateTime.AddMinutes(request.DurationMinutes);

        //    var hasConflict = await _context.TrainingSessions
        //        .Where(ts => ts.PersonalTrainerId == request.PersonalTrainerId)
        //        .Where(ts => ts.Status != TrainingSessionStatus.Cancelled)
        //        .Where(ts =>
        //            (ts.ScheduledDateTime < endTime &&
        //             ts.ScheduledDateTime.AddMinutes(ts.DurationMinutes) > request.ScheduledDateTime))
        //        .AnyAsync(cancellationToken);

        //    return !hasConflict;
        //}

        //public enum TrainingSessionStatus
        //{
        //    Pending = 0,      // Klijent kreirao, čeka potvrdu
        //    Confirmed = 1,    // Trener potvrdio
        //    Completed = 2,    // Trening obavljen
        //    Cancelled = 3,    // Otkazan
        //    NoShow = 4        // Klijent se nije pojavio
        //}
        
    }
}
