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
    public class InitialTrainingSessionState : BaseTrainingSessionState
    {
        public InitialTrainingSessionState(
            IServiceProvider serviceProvider,
            IB210033DbContext context,
            IMapper mapper,
            IHttpContextAccessor httpContextAccessor,
            INotificationService notificationService,
            IValidator<TrainingSessionUpsertRequest> validator)
            : base(serviceProvider, context, mapper, httpContextAccessor, notificationService, validator)
        {
        }

        public override async Task<TrainingSession> CreateAsync(TrainingSessionUpsertRequest request)
        {
            await EnsureValidAsync(request);

            var available = await IsTrainerAvailableAsync(
                request.PersonalTrainerId,
                request.ScheduledDateTime,
                request.DurationMinutes);

            if (!available)
                throw new ArgumentException("Trainer is not available at the requested time");

            var entity = new TrainingSession();
            _mapper.Map(request, entity);

            entity.ClientId = GetCurrentUserId();
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
