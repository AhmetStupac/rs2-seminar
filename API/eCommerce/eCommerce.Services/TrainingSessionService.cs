using eCommerce.Model.Constants;
using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using eCommerce.Services.States;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TrainingSessionStatus = eCommerce.Model.Enums.TrainingSessionStatus;

namespace eCommerce.Services
{
    /// <summary>
    /// Context (in the State Design Pattern). All status-driven business rules live in
    /// the concrete <see cref="BaseTrainingSessionState"/> implementations under
    /// <c>eCommerce.Services.States</c>. This class only:
    ///   1. resolves the current state for a session,
    ///   2. delegates the requested action to that state, and
    ///   3. maps the resulting entity to a response DTO.
    /// </summary>
    public class TrainingSessionService
        : BaseCRUDService<TrainingSessionResponse, TrainingSessionSearchObject, TrainingSession, TrainingSessionUpsertRequest, TrainingSessionUpsertRequest>,
          ITrainingSessionService
    {
        private readonly IServiceProvider _serviceProvider;

        public TrainingSessionService(
            IB210033DbContext context,
            IMapper mapper,
            IServiceProvider serviceProvider)
            : base(context, mapper)
        {
            _serviceProvider = serviceProvider;
        }

        // --- State machine entry points -----------------------------------------------------

        public override async Task<TrainingSessionResponse> CreateAsync(TrainingSessionUpsertRequest request)
        {
            var initialState = _serviceProvider.GetRequiredService<InitialTrainingSessionState>();
            var entity = await initialState.CreateAsync(request);
            return MapToResponse(entity);
        }

        public override async Task<TrainingSessionResponse?> UpdateAsync(int id, TrainingSessionUpsertRequest request)
        {
            var entity = await _context.Set<TrainingSession>().FindAsync(id);
            if (entity == null)
                return null;

            var state = ResolveState(entity.Status);
            await state.UpdateAsync(entity, request);
            return MapToResponse(entity);
        }

        public async Task<TrainingSessionResponse> ConfirmAsync(int id)
        {
            var entity = await GetSessionOrThrowAsync(id);
            var state = ResolveState(entity.Status);
            await state.ConfirmAsync(entity);
            return MapToResponse(entity);
        }

        public async Task<TrainingSessionResponse> CancelAsync(int id, TrainingSessionCancelRequest request)
        {
            var entity = await GetSessionOrThrowAsync(id);
            var state = ResolveState(entity.Status);
            await state.CancelAsync(entity, request);
            return MapToResponse(entity);
        }

        public async Task<TrainingSessionResponse> CompleteAsync(int id)
        {
            var entity = await GetSessionOrThrowAsync(id);
            var state = ResolveState(entity.Status);
            await state.CompleteAsync(entity);
            return MapToResponse(entity);
        }

        public async Task<TrainingSessionResponse> MarkNoShowAsync(int id)
        {
            var entity = await GetSessionOrThrowAsync(id);
            var state = ResolveState(entity.Status);
            await state.MarkNoShowAsync(entity);
            return MapToResponse(entity);
        }

        public async Task<List<string>> AllowedActionsAsync(int id)
        {
            var entity = await _context.Set<TrainingSession>().FindAsync(id);
            if (entity == null)
                throw new KeyNotFoundException("Training session not found");

            return ResolveState(entity.Status).AllowedActions(entity);
        }

        public override async Task<TrainingSessionResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<TrainingSession>()
                .Include(ts => ts.Client)
                .Include(ts => ts.PersonalTrainer)
                    .ThenInclude(pt => pt.User)
                .Include(ts => ts.Gym)
                .Include(ts => ts.History)
                    .ThenInclude(h => h.ChangedByUser)
                .FirstOrDefaultAsync(ts => ts.Id == id);

            return entity == null ? null : MapToResponse(entity);
        }

        // --- Filtering / mapping (unchanged) -------------------------------------------------

        protected override IQueryable<TrainingSession> ApplyFilter(IQueryable<TrainingSession> query, TrainingSessionSearchObject search)
        {
            query = query
                .Include(ts => ts.Client)
                .Include(ts => ts.PersonalTrainer)
                    .ThenInclude(pt => pt.User)
                .Include(ts => ts.Gym)
                .Include(ts => ts.History)
                    .ThenInclude(h => h.ChangedByUser);

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

            var allowedActions = ResolveState(entity.Status).AllowedActions(entity);
            response.CanEdit = allowedActions.Contains(TrainingSessionConstants.AllowedActions.Update);
            response.CanCancel = allowedActions.Contains(TrainingSessionConstants.AllowedActions.Cancel);

            response.History = entity.History
                .OrderBy(h => h.ChangedAt)
                .Select(h => new TrainingSessionHistoryResponse
                {
                    Id = h.Id,
                    TrainingSessionId = h.TrainingSessionId,
                    FromStatus = h.FromStatus,
                    ToStatus = h.ToStatus,
                    ChangedAt = h.ChangedAt,
                    ChangedByUserId = h.ChangedByUserId,
                    ChangedByUserName = h.ChangedByUser != null
                        ? $"{h.ChangedByUser.FirstName} {h.ChangedByUser.LastName}"
                        : null,
                    Note = h.Note
                })
                .ToList();

            return response;
        }

        // --- Availability helpers (still used by controller endpoints) ----------------------

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
            var workStart = date.Date.AddHours(6);
            var workEnd = date.Date.AddHours(22);
            var slotDuration = TimeSpan.FromMinutes(durationMinutes);

            var slots = new List<DateTime>();
            var currentSlot = workStart;

            while (currentSlot.Add(slotDuration) <= workEnd)
            {
                if (await CheckAvailabilityAsync(trainerId, currentSlot, durationMinutes))
                    slots.Add(currentSlot);

                currentSlot = currentSlot.AddMinutes(30);
            }

            return slots;
        }

        // --- Internal helpers ----------------------------------------------------------------

        private BaseTrainingSessionState ResolveState(TrainingSessionStatus status)
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

        private async Task<TrainingSession> GetSessionOrThrowAsync(int id)
        {
            var entity = await _context.Set<TrainingSession>().FindAsync(id);
            if (entity == null)
                throw new KeyNotFoundException("Training session not found");
            return entity;
        }
    }
}
