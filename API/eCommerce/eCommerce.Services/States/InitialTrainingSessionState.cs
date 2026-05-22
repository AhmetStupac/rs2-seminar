using eCommerce.Model.Requests;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TrainingSessionStatus = eCommerce.Model.Enums.TrainingSessionStatus;

namespace eCommerce.Services.States
{
    public class InitialTrainingSessionState : BaseTrainingSessionState
    {
        public InitialTrainingSessionState(
            IServiceProvider serviceProvider,
            IB210033DbContext context,
            IMapper mapper,
            IHttpContextAccessor httpContextAccessor,
            INotificationService notificationService,
            IValidator<TrainingSessionUpsertRequest> validator,
            IValidator<TrainingSessionCancelRequest> cancelValidator)
            : base(serviceProvider, context, mapper, httpContextAccessor, notificationService, validator, cancelValidator)
        {
        }

        public override async Task<TrainingSession> CreateAsync(TrainingSessionUpsertRequest request)
        {
            await EnsureValidAsync(request);

            var currentUserId = GetCurrentUserId();
            var hasActiveMembership = await _context.Set<Membership>()
                .AnyAsync(m => m.ClientUserId == currentUserId
                    && m.PersonalTrainerId == request.PersonalTrainerId
                    && !m.IsRevoked
                    && m.ExpiryDate > DateTime.UtcNow);

            if (!hasActiveMembership)
                throw new UnauthorizedAccessException("Active membership is required to book a training session.");

            var available = await IsTrainerAvailableAsync(
                request.PersonalTrainerId,
                request.ScheduledDateTime,
                request.DurationMinutes);

            if (!available)
                throw new ArgumentException("Trainer is not available at the requested time");

            var entity = new TrainingSession();
            _mapper.Map(request, entity);

            entity.ClientId = currentUserId;
            entity.Status = TrainingSessionStatus.Pending;
            entity.CreatedAt = DateTime.UtcNow;

            _context.Set<TrainingSession>().Add(entity);
            await _context.SaveChangesAsync();

            if (entity.ClientId.HasValue)
            {
                await _notificationService.CreateAsync(new NotificationCreateRequest
                {
                    UserId = entity.ClientId.Value,
                    Title = "Training session reserved",
                    Message = $"You reserved a training session on {entity.ScheduledDateTime:yyyy-MM-dd HH:mm}.",
                    Type = "training-session"
                });
            }

            return entity;
        }

        public override List<string> AllowedActions(TrainingSession entity)
            => new List<string> { nameof(CreateAsync) };
    }
}
