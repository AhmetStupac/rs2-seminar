using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using TrainingSessionStatus = eCommerce.Model.Enums.TrainingSessionStatus;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class TrainingSessionService : BaseCRUDService<TrainingSessionResponse, TrainingSessionSearchObject, TrainingSession, TrainingSessionUpsertRequest, TrainingSessionUpsertRequest>, ITrainingSessionService
    {
        private readonly IValidator<TrainingSessionUpsertRequest> _validator;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public TrainingSessionService(
            IB210033DbContext context,
            IMapper mapper,
            IValidator<TrainingSessionUpsertRequest> validator,
            IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _validator = validator;
            _httpContextAccessor = httpContextAccessor;
        }

        protected override IQueryable<TrainingSession> ApplyFilter(IQueryable<TrainingSession> query, TrainingSessionSearchObject search)
        {
            query = query
                .Include(ts => ts.Client)
                .Include(ts => ts.PersonalTrainer)
                    .ThenInclude(pt => pt.User)
                .Include(ts => ts.Gym);

            if (search.ClientId.HasValue)
                query = query.Where(ts => ts.ClientId == search.ClientId);

            if (search.PersonalTrainerId.HasValue)
                query = query.Where(ts => ts.PersonalTrainerId == search.PersonalTrainerId);

            if (search.GymId.HasValue)
                query = query.Where(ts => ts.GymId == search.GymId);

            if (search.DateFrom.HasValue)
                query = query.Where(ts => ts.ScheduledDateTime >= search.DateFrom);

            if (search.DateTo.HasValue)
                query = query.Where(ts => ts.ScheduledDateTime <= search.DateTo);

            if (search.Status.HasValue)
                query = query.Where(ts => ts.Status == (TrainingSessionStatus)search.Status);

            return query.OrderBy(ts => ts.ScheduledDateTime);
        }

        protected override async Task BeforeInsert(TrainingSession entity, TrainingSessionUpsertRequest request)
        {
            var result = await _validator.ValidateAsync(request);
            if (!result.IsValid)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            // Set ClientId from authenticated user
            var userId = GetCurrentUserId();
            entity.ClientId = userId;
            entity.Status = TrainingSessionStatus.Pending;
            entity.CreatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(TrainingSession entity, TrainingSessionUpsertRequest request)
        {
            var result = await _validator.ValidateAsync(request);
            if (!result.IsValid)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            // Check permissions
            var currentUserId = GetCurrentUserId();
            var isTrainer = IsCurrentUserTrainer(entity.PersonalTrainerId);

            if (entity.ClientId != currentUserId && !isTrainer)
                throw new UnauthorizedAccessException("You don't have permission to update this training session");

            // Check availability if datetime or duration changed
            if (request.ScheduledDateTime != entity.ScheduledDateTime || request.DurationMinutes != entity.DurationMinutes)
            {
                var isAvailable = await CheckAvailabilityAsync(
                    entity.PersonalTrainerId,
                    request.ScheduledDateTime,
                    request.DurationMinutes,
                    entity.Id);

                if (!isAvailable)
                    throw new ArgumentException("Trainer is not available at the requested time");
            }

            entity.UpdatedAt = DateTime.UtcNow;
        }

        protected override TrainingSessionResponse MapToResponse(TrainingSession entity)
        {
            var response = _mapper.Map<TrainingSessionResponse>(entity);

            if (entity.Client != null)
                response.ClientName = $"{entity.Client.FirstName} {entity.Client.LastName}";

            if (entity.PersonalTrainer?.User != null)
                response.TrainerName = $"{entity.PersonalTrainer.User.FirstName} {entity.PersonalTrainer.User.LastName}";

            if (entity.Gym != null)
                response.GymName = entity.Gym.Name;

            response.StatusDisplay = entity.Status.ToString();

            // Check permissions
            var userId = GetCurrentUserId();
            response.CanEdit = entity.ClientId == userId || IsCurrentUserTrainer(entity.PersonalTrainerId);
            response.CanCancel = response.CanEdit && entity.Status != TrainingSessionStatus.Completed;

            return response;
        }

        public async Task<TrainingSessionResponse> ConfirmAsync(int id)
        {
            var entity = await _context.Set<TrainingSession>().FindAsync(id);
            if (entity == null)
                throw new KeyNotFoundException("Training session not found");

            var isTrainer = IsCurrentUserTrainer(entity.PersonalTrainerId);
            if (!isTrainer)
                throw new UnauthorizedAccessException("Only the trainer can confirm the training session");

            if (entity.Status != TrainingSessionStatus.Pending)
                throw new InvalidOperationException("Only pending training sessions can be confirmed");

            entity.Status = TrainingSessionStatus.Confirmed;
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        public async Task<TrainingSessionResponse> CancelAsync(int id, TrainingSessionCancelRequest request)
        {
            var entity = await _context.Set<TrainingSession>().FindAsync(id);
            if (entity == null)
                throw new KeyNotFoundException("Training session not found");

            var userId = GetCurrentUserId();
            var isTrainer = IsCurrentUserTrainer(entity.PersonalTrainerId);

            if (entity.ClientId != userId && !isTrainer)
                throw new UnauthorizedAccessException("You don't have permission to cancel this training session");

            if (entity.Status == TrainingSessionStatus.Completed)
                throw new InvalidOperationException("Cannot cancel a completed training session");

            entity.Status = TrainingSessionStatus.Cancelled;
            entity.CancelledAt = DateTime.UtcNow;
            entity.CancellationReason = request.CancellationReason;
            entity.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        public async Task<bool> CheckAvailabilityAsync(int trainerId, DateTime scheduledDateTime, int durationMinutes, int? excludeSessionId = null)
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

        public async Task<List<DateTime>> GetAvailableTimeSlotsAsync(int trainerId, DateTime date, int durationMinutes)
        {
            var workStart = date.Date.AddHours(6); // 6:00 AM
            var workEnd = date.Date.AddHours(22); // 10:00 PM
            var slotDuration = TimeSpan.FromMinutes(durationMinutes);

            var slots = new List<DateTime>();
            var currentSlot = workStart;

            while (currentSlot.Add(slotDuration) <= workEnd)
            {
                if (await CheckAvailabilityAsync(trainerId, currentSlot, durationMinutes))
                    slots.Add(currentSlot);

                currentSlot = currentSlot.AddMinutes(30); // 30 minute intervals
            }

            return slots;
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier);
            return int.Parse(userIdClaim?.Value ?? "0");
        }

        private bool IsCurrentUserTrainer(int trainerId)
        {
            var userId = GetCurrentUserId();
            return _context.Set<PersonalTrainer>()
                .Any(pt => pt.Id == trainerId && pt.UserId == userId);
        }
    }
}

