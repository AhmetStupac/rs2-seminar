using eCommerce.Model.Requests;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using TrainingSessionStatus = eCommerce.Model.Enums.TrainingSessionStatus;

namespace eCommerce.Services.States
{
    public abstract class BaseTrainingSessionState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly IB210033DbContext _context;
        protected readonly IMapper _mapper;
        protected readonly IHttpContextAccessor _httpContextAccessor;
        protected readonly INotificationService _notificationService;
        protected readonly IValidator<TrainingSessionUpsertRequest> _validator;
        protected readonly IValidator<TrainingSessionCancelRequest> _cancelValidator;

        protected BaseTrainingSessionState(
            IServiceProvider serviceProvider,
            IB210033DbContext context,
            IMapper mapper,
            IHttpContextAccessor httpContextAccessor,
            INotificationService notificationService,
            IValidator<TrainingSessionUpsertRequest> validator,
            IValidator<TrainingSessionCancelRequest> cancelValidator)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
            _httpContextAccessor = httpContextAccessor;
            _notificationService = notificationService;
            _validator = validator;
            _cancelValidator = cancelValidator;
        }

        public virtual Task<TrainingSession> CreateAsync(TrainingSessionUpsertRequest request)
            => throw new InvalidOperationException("Cannot create a training session from the current state.");

        public virtual Task<TrainingSession> UpdateAsync(TrainingSession entity, TrainingSessionUpsertRequest request)
            => throw new InvalidOperationException($"Cannot update a training session in '{entity.Status}' state.");

        public virtual Task<TrainingSession> ConfirmAsync(TrainingSession entity)
            => throw new InvalidOperationException($"Cannot confirm a training session in '{entity.Status}' state.");

        public virtual Task<TrainingSession> CancelAsync(TrainingSession entity, TrainingSessionCancelRequest request)
            => throw new InvalidOperationException($"Cannot cancel a training session in '{entity.Status}' state.");

        public virtual Task<TrainingSession> CompleteAsync(TrainingSession entity)
            => throw new InvalidOperationException($"Cannot complete a training session in '{entity.Status}' state.");

        public virtual Task<TrainingSession> MarkNoShowAsync(TrainingSession entity)
            => throw new InvalidOperationException($"Cannot mark no-show in '{entity.Status}' state.");

        public virtual List<string> AllowedActions(TrainingSession entity)
            => new List<string>();

        protected BaseTrainingSessionState GetState(TrainingSessionStatus status)
        {
            return status switch
            {
                TrainingSessionStatus.Pending => _serviceProvider.GetRequiredService<PendingTrainingSessionState>(),
                TrainingSessionStatus.Confirmed => _serviceProvider.GetRequiredService<ConfirmedTrainingSessionState>(),
                TrainingSessionStatus.Completed => _serviceProvider.GetRequiredService<CompletedTrainingSessionState>(),
                TrainingSessionStatus.Cancelled => _serviceProvider.GetRequiredService<CancelledTrainingSessionState>(),
                TrainingSessionStatus.NoShow => _serviceProvider.GetRequiredService<NoShowTrainingSessionState>(),
                _ => throw new InvalidOperationException($"Unknown TrainingSessionStatus: {status}")
            };
        }

        protected int GetCurrentUserId()
        {
            var userIdClaim = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrWhiteSpace(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
                throw new UnauthorizedAccessException("User is not authenticated");

            return userId;
        }

        protected bool IsCurrentUserTrainer(int trainerId)
        {
            var userId = GetCurrentUserId();
            return _context.Set<PersonalTrainer>()
                .Any(pt => pt.Id == trainerId && pt.UserId == userId);
        }

        protected async Task EnsureValidAsync(TrainingSessionUpsertRequest request)
        {
            var result = await _validator.ValidateAsync(request);
            if (!result.IsValid)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }
        }

        protected async Task EnsureCancelValidAsync(TrainingSessionCancelRequest request)
        {
            var result = await _cancelValidator.ValidateAsync(request);
            if (!result.IsValid)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }
        }

        protected async Task<bool> IsTrainerAvailableAsync(int trainerId, DateTime scheduledDateTime, int durationMinutes, int? excludeSessionId = null)
        {
            var endTime = scheduledDateTime.AddMinutes(durationMinutes);

            var query = _context.Set<TrainingSession>()
                .Where(ts => ts.PersonalTrainerId == trainerId)
                .Where(ts => ts.Status != TrainingSessionStatus.Cancelled);

            if (excludeSessionId.HasValue)
                query = query.Where(ts => ts.Id != excludeSessionId);

            return !await query
                .Where(ts =>
                    ts.ScheduledDateTime < endTime &&
                    ts.ScheduledDateTime.AddMinutes(ts.DurationMinutes) > scheduledDateTime)
                .AnyAsync();
        }
    }
}
