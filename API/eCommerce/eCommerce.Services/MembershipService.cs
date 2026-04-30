using eCommerce.Model.Responses;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class MembershipService : IMembershipService
    {
        private readonly IB210033DbContext _context;

        public MembershipService(IB210033DbContext context)
        {
            _context = context;
        }

        public async Task<List<MembershipResponse>> GetClientMembershipsAsync(int clientUserId)
        {
            var now = DateTime.UtcNow;

            var memberships = await _context.Set<Membership>()
                .Include(m => m.Client)
                .Include(m => m.PersonalTrainer).ThenInclude(pt => pt.User)
                .Where(m => m.ClientUserId == clientUserId)
                .OrderByDescending(m => m.CreatedAt)
                .ToListAsync();

            return memberships.Select(m => MapToResponse(m, now)).ToList();
        }

        public async Task<List<MembershipResponse>> GetTrainerMembershipsAsync(int personalTrainerId)
        {
            var now = DateTime.UtcNow;

            var memberships = await _context.Set<Membership>()
                .Include(m => m.Client)
                .Include(m => m.PersonalTrainer).ThenInclude(pt => pt.User)
                .Where(m => m.PersonalTrainerId == personalTrainerId)
                .OrderByDescending(m => m.CreatedAt)
                .ToListAsync();

            return memberships.Select(m => MapToResponse(m, now)).ToList();
        }

        public async Task<int> GetActiveClientCountAsync(int personalTrainerId)
        {
            var now = DateTime.UtcNow;
            return await _context.Set<Membership>()
                .CountAsync(m => m.PersonalTrainerId == personalTrainerId
                    && !m.IsRevoked
                    && m.ExpiryDate > now);
        }

        public async Task<bool> HasActiveMembershipAsync(int clientUserId, int personalTrainerId)
        {
            var now = DateTime.UtcNow;
            return await _context.Set<Membership>()
                .AnyAsync(m => m.ClientUserId == clientUserId
                    && m.PersonalTrainerId == personalTrainerId
                    && !m.IsRevoked
                    && m.ExpiryDate > now);
        }

        public async Task<MembershipResponse> RevokeAsync(int membershipId, int requestingUserId)
        {
            var membership = await _context.Set<Membership>()
                .Include(m => m.Client)
                .Include(m => m.PersonalTrainer).ThenInclude(pt => pt.User)
                .FirstOrDefaultAsync(m => m.Id == membershipId);

            if (membership == null)
                throw new KeyNotFoundException($"Membership {membershipId} not found.");

            // Only the trainer who owns this membership may revoke it
            var isTrainer = await _context.Set<PersonalTrainer>()
                .AnyAsync(pt => pt.Id == membership.PersonalTrainerId && pt.UserId == requestingUserId);

            if (!isTrainer)
                throw new UnauthorizedAccessException("Only the personal trainer can revoke a membership.");

            if (membership.IsRevoked)
                throw new InvalidOperationException("Membership is already revoked.");

            membership.IsRevoked = true;
            await _context.SaveChangesAsync();

            return MapToResponse(membership, DateTime.UtcNow);
        }

        private static MembershipResponse MapToResponse(Membership m, DateTime now)
        {
            var isActive = !m.IsRevoked && now <= m.ExpiryDate;
            return new MembershipResponse
            {
                Id = m.Id,
                ClientUserId = m.ClientUserId,
                ClientFullName = m.Client != null
                    ? $"{m.Client.FirstName} {m.Client.LastName}"
                    : null,
                PersonalTrainerId = m.PersonalTrainerId,
                TrainerFullName = m.PersonalTrainer?.User != null
                    ? $"{m.PersonalTrainer.User.FirstName} {m.PersonalTrainer.User.LastName}"
                    : null,
                PaymentId = m.PaymentId,
                StartDate = m.StartDate,
                ExpiryDate = m.ExpiryDate,
                IsActive = isActive,
                IsRevoked = m.IsRevoked,
                DaysRemaining = isActive ? Math.Max(0, (int)(m.ExpiryDate - now).TotalDays) : 0,
                CreatedAt = m.CreatedAt
            };
        }
    }
}
