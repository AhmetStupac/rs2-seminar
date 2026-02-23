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
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class GroupTrainingSessionService
        : BaseCRUDService<GroupTrainingSessionResponse, GroupTrainingSessionSearchObject, GroupTrainingSession, GroupTrainingSessionUpsertRequest, GroupTrainingSessionUpsertRequest>,
          IGroupTrainingSessionService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IValidator<GroupTrainingSessionUpsertRequest> _validator;

        public GroupTrainingSessionService(
            IB210033DbContext context,
            IMapper mapper,
            IHttpContextAccessor httpContextAccessor,
            IValidator<GroupTrainingSessionUpsertRequest> validator)
            : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
            _validator = validator;
        }

        protected override IQueryable<GroupTrainingSession> ApplyFilter(IQueryable<GroupTrainingSession> query, GroupTrainingSessionSearchObject search)
        {
            query = query
                .Include(g => g.Creator)
                .Include(g => g.Participants)
                    .ThenInclude(p => p.User);

            if (!string.IsNullOrWhiteSpace(search.Name))
                query = query.Where(g => g.Name.Contains(search.Name));

            if (!string.IsNullOrWhiteSpace(search.TrainingType))
                query = query.Where(g => g.TrainingType.Contains(search.TrainingType));

            if (search.CreatorId.HasValue)
                query = query.Where(g => g.CreatorId == search.CreatorId.Value);

            return query.OrderByDescending(g => g.CreatedAt);
        }

        protected override async Task BeforeInsert(GroupTrainingSession entity, GroupTrainingSessionUpsertRequest request)
        {
            var result = await _validator.ValidateAsync(request);
            if (!result.IsValid)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            var creatorId = GetCurrentUserId();
            if (creatorId == 0)
                throw new UnauthorizedAccessException("User must be authenticated to create a group training session.");

            entity.CreatorId = creatorId;
            entity.CreatedAt = DateTime.UtcNow;
        }

        protected override async Task BeforeUpdate(GroupTrainingSession entity, GroupTrainingSessionUpsertRequest request)
        {
            var result = await _validator.ValidateAsync(request);
            if (!result.IsValid)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }
        }

        protected override GroupTrainingSessionResponse MapToResponse(GroupTrainingSession entity)
        {
            var response = _mapper.Map<GroupTrainingSessionResponse>(entity);

            if (entity.Creator != null)
                response.CreatorName = $"{entity.Creator.FirstName} {entity.Creator.LastName}";

            if (entity.Participants != null)
            {
                response.ParticipantCount = entity.Participants.Count;
                response.Participants = entity.Participants
                    .Select(p => new GroupTrainingSessionParticipantResponse
                    {
                        UserId = p.UserId,
                        UserName = p.User != null ? $"{p.User.FirstName} {p.User.LastName}" : string.Empty,
                        JoinedAt = p.JoinedAt
                    })
                    .ToList();
            }

            return response;
        }

        public async Task<GroupTrainingSessionResponse> JoinAsync(int groupTrainingSessionId, int userId)
        {
            var session = await _context.Set<GroupTrainingSession>()
                .Include(g => g.Creator)
                .Include(g => g.Participants)
                    .ThenInclude(p => p.User)
                .FirstOrDefaultAsync(g => g.Id == groupTrainingSessionId);

            if (session == null)
                throw new KeyNotFoundException("Group training session not found.");

            var alreadyJoined = session.Participants.Any(p => p.UserId == userId);
            if (alreadyJoined)
                throw new InvalidOperationException("User has already joined this training session.");

            var participant = new GroupTrainingSessionParticipant
            {
                GroupTrainingSessionId = groupTrainingSessionId,
                UserId = userId,
                JoinedAt = DateTime.UtcNow
            };

            _context.Set<GroupTrainingSessionParticipant>().Add(participant);
            await _context.SaveChangesAsync();

            // Reload to include the new participant's user info
            await _context.Entry(participant).Reference(p => p.User).LoadAsync();
            session.Participants.Add(participant);

            return MapToResponse(session);
        }

        public async Task<bool> LeaveAsync(int groupTrainingSessionId, int userId)
        {
            var participant = await _context.Set<GroupTrainingSessionParticipant>()
                .FirstOrDefaultAsync(p => p.GroupTrainingSessionId == groupTrainingSessionId && p.UserId == userId);

            if (participant == null)
                return false;

            _context.Set<GroupTrainingSessionParticipant>().Remove(participant);
            await _context.SaveChangesAsync();
            return true;
        }

        private int GetCurrentUserId()
        {
            var claim = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier);
            return int.TryParse(claim?.Value, out var id) ? id : 0;
        }
    }
}
