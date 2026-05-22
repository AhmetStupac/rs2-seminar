using eCommerce.Model.Constants;
using eCommerce.Model.Requests;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TrainingSessionStatus = eCommerce.Model.Enums.TrainingSessionStatus;

namespace eCommerce.Services.States
{
    public class PendingTrainingSessionState : BaseTrainingSessionState
    {
        public PendingTrainingSessionState(
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

        public override async Task<TrainingSession> UpdateAsync(TrainingSession entity, TrainingSessionUpsertRequest request)
        {
            await EnsureValidAsync(request);

            var currentUserId = GetCurrentUserId();
            var isTrainer = IsCurrentUserTrainer(entity.PersonalTrainerId);

            if (entity.ClientId != currentUserId && !isTrainer)
                throw new UnauthorizedAccessException("You don't have permission to update this training session");

            if (request.ScheduledDateTime != entity.ScheduledDateTime ||
                request.DurationMinutes != entity.DurationMinutes)
            {
                var isAvailable = await IsTrainerAvailableAsync(
                    entity.PersonalTrainerId,
                    request.ScheduledDateTime,
                    request.DurationMinutes,
                    entity.Id);

                if (!isAvailable)
                    throw new ArgumentException("Trainer is not available at the requested time");
            }

            entity.GymId = request.GymId;
            entity.ScheduledDateTime = request.ScheduledDateTime;
            entity.DurationMinutes = request.DurationMinutes;
            entity.Notes = request.Notes;
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return entity;
        }

        public override async Task<TrainingSession> ConfirmAsync(TrainingSession entity)
        {
            if (!IsCurrentUserTrainer(entity.PersonalTrainerId))
                throw new UnauthorizedAccessException("Only the trainer can confirm the training session");

            var userId = GetCurrentUserId();
            entity.Status = TrainingSessionStatus.Confirmed;
            entity.ApprovedAt = DateTime.UtcNow;
            entity.ApprovedByUserId = userId;
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            if (entity.ClientId.HasValue)
            {
                await _notificationService.CreateAsync(new NotificationCreateRequest
                {
                    UserId = entity.ClientId.Value,
                    Title = "Training session confirmed",
                    Message = $"Your training session on {entity.ScheduledDateTime:yyyy-MM-dd HH:mm} was confirmed by your trainer.",
                    Type = "training-session"
                });
            }

            return entity;
        }

        public override async Task<TrainingSession> CancelAsync(TrainingSession entity, TrainingSessionCancelRequest request)
        {
            var userId = GetCurrentUserId();
            var isTrainer = IsCurrentUserTrainer(entity.PersonalTrainerId);

            if (entity.ClientId != userId && !isTrainer)
                throw new UnauthorizedAccessException("You don't have permission to cancel this training session");

            await EnsureCancelValidAsync(request);

            entity.Status = TrainingSessionStatus.Cancelled;
            entity.CancelledAt = DateTime.UtcNow;
            entity.CancelledByUserId = userId;
            entity.CancellationReason = request.CancellationReason;
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            if (entity.ClientId.HasValue)
            {
                await _notificationService.CreateAsync(new NotificationCreateRequest
                {
                    UserId = entity.ClientId.Value,
                    Title = "Training session cancelled",
                    Message = $"Your training session on {entity.ScheduledDateTime:yyyy-MM-dd HH:mm} was cancelled.",
                    Type = "training-session"
                });
            }

            return entity;
        }

        public override List<string> AllowedActions(TrainingSession entity)
            => new List<string> { TrainingSessionConstants.AllowedActions.Confirm, TrainingSessionConstants.AllowedActions.Cancel, TrainingSessionConstants.AllowedActions.Update };
    }
}
