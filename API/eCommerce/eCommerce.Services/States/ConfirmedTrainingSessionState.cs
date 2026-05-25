using eCommerce.Model.Constants;
using eCommerce.Model.Requests;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using TrainingSessionStatus = eCommerce.Model.Enums.TrainingSessionStatus;

namespace eCommerce.Services.States
{
    public class ConfirmedTrainingSessionState : BaseTrainingSessionState
    {
        public ConfirmedTrainingSessionState(
            IServiceProvider serviceProvider,
            IB210033DbContext context,
            IMapper mapper,
            ICurrentUserService currentUser,
            INotificationService notificationService,
            IValidator<TrainingSessionUpsertRequest> validator,
            IValidator<TrainingSessionCancelRequest> cancelValidator)
            : base(serviceProvider, context, mapper, currentUser, notificationService, validator, cancelValidator)
        {
        }

        public override async Task<TrainingSession> CompleteAsync(TrainingSession entity)
        {
            if (!IsCurrentUserTrainer(entity.PersonalTrainerId))
                throw new UnauthorizedAccessException("Only the trainer can complete the training session");

            var userId = GetCurrentUserId();
            var previousStatus = entity.Status;
            entity.Status = TrainingSessionStatus.Completed;
            entity.CompletedAt = DateTime.UtcNow;
            entity.CompletedByUserId = userId;
            entity.UpdatedAt = DateTime.UtcNow;

            RecordStatusChange(entity, previousStatus, entity.Status, userId);

            await _context.SaveChangesAsync();

            if (entity.ClientId.HasValue)
            {
                await _notificationService.CreateAsync(new NotificationCreateRequest
                {
                    UserId = entity.ClientId.Value,
                    Title = "Training session completed",
                    Message = $"Your training session on {entity.ScheduledDateTime:yyyy-MM-dd HH:mm} has been marked as completed.",
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

            var previousStatus = entity.Status;
            entity.Status = TrainingSessionStatus.Cancelled;
            entity.CancelledAt = DateTime.UtcNow;
            entity.CancelledByUserId = userId;
            entity.CancellationReason = request.CancellationReason;
            entity.UpdatedAt = DateTime.UtcNow;

            RecordStatusChange(entity, previousStatus, entity.Status, userId, request.CancellationReason);

            await _context.SaveChangesAsync();

            if (entity.ClientId.HasValue)
            {
                await _notificationService.CreateAsync(new NotificationCreateRequest
                {
                    UserId = entity.ClientId.Value,
                    Title = "Training session cancelled",
                    Message = $"Your confirmed training session on {entity.ScheduledDateTime:yyyy-MM-dd HH:mm} was cancelled.",
                    Type = "training-session"
                });
            }

            return entity;
        }

        public override async Task<TrainingSession> MarkNoShowAsync(TrainingSession entity)
        {
            if (!IsCurrentUserTrainer(entity.PersonalTrainerId))
                throw new UnauthorizedAccessException("Only the trainer can mark a session as no-show");

            var userId = GetCurrentUserId();
            var previousStatus = entity.Status;
            entity.Status = TrainingSessionStatus.NoShow;
            entity.NoShowAt = DateTime.UtcNow;
            entity.NoShowByUserId = userId;
            entity.UpdatedAt = DateTime.UtcNow;

            RecordStatusChange(entity, previousStatus, entity.Status, userId);

            await _context.SaveChangesAsync();
            return entity;
        }

        public override List<string> AllowedActions(TrainingSession entity)
            => new List<string>
            {
                TrainingSessionConstants.AllowedActions.Complete,
                TrainingSessionConstants.AllowedActions.Cancel,
                TrainingSessionConstants.AllowedActions.NoShow
            };
    }
}
