using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.Constants;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using TrainingSessionStatus = eCommerce.Model.Enums.TrainingSessionStatus;

namespace eCommerce.Services
{
    public class MonthlyTrainingStatisticsService : IMonthlyTrainingStatisticsService
    {
        private readonly IB210033DbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public MonthlyTrainingStatisticsService(IB210033DbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        public async Task<List<MonthlyTrainingStatisticsResponse>> GetYearlyStatisticsAsync(int userId, int year)
        {
            // Validate that the user is requesting their own statistics or is authorized
            var currentUserId = GetCurrentUserId();
            if (currentUserId != userId && !await IsAuthorizedToViewStatistics(userId))
            {
                throw new UnauthorizedAccessException("You don't have permission to view these statistics");
            }

            var yearStart = new DateTime(year, 1, 1);
            var yearEnd = yearStart.AddYears(1);

            var monthlyDataByMonth = await (
                from x in
                    (
                        from ts in _context.Set<TrainingSession>()
                        where ts.ClientId == userId
                              && ts.Status == TrainingSessionStatus.Completed
                              && ts.ScheduledDateTime >= yearStart
                              && ts.ScheduledDateTime < yearEnd
                        group ts by ts.ScheduledDateTime.Month
                        into g
                        select new
                        {
                            Month = g.Key,
                            SessionCount = g.Count(),
                            StatisticsId = (int?)null,
                            Comment = (string?)null,
                            CreatedAt = (DateTime?)null,
                            UpdatedAt = (DateTime?)null
                        }
                    )
                    .Concat(
                        from s in _context.Set<MonthlyTrainingStatistics>()
                        where s.UserId == userId && s.Year == year
                        select new
                        {
                            Month = s.Month,
                            SessionCount = 0,
                            StatisticsId = (int?)s.Id,
                            Comment = s.Comment,
                            CreatedAt = (DateTime?)s.CreatedAt,
                            UpdatedAt = s.UpdatedAt
                        }
                    )
                group x by x.Month
                into g
                select new
                {
                    Month = g.Key,
                    SessionCount = g.Max(v => v.SessionCount),
                    StatisticsId = g.Max(v => v.StatisticsId),
                    Comment = g.Max(v => v.Comment),
                    CreatedAt = g.Max(v => v.CreatedAt),
                    UpdatedAt = g.Max(v => v.UpdatedAt)
                })
                .ToDictionaryAsync(x => x.Month);

            var statistics = new List<MonthlyTrainingStatisticsResponse>(12);

            for (int month = 1; month <= 12; month++)
            {
                monthlyDataByMonth.TryGetValue(month, out var monthlyData);

                statistics.Add(new MonthlyTrainingStatisticsResponse
                {
                    Id = monthlyData?.StatisticsId ?? 0,
                    UserId = userId,
                    UserName = string.Empty,
                    Year = year,
                    Month = month,
                    MonthName = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month),
                    TrainingSessionCount = monthlyData?.SessionCount ?? 0,
                    Comment = monthlyData?.Comment,
                    CreatedAt = monthlyData?.CreatedAt ?? DateTime.UtcNow,
                    UpdatedAt = monthlyData?.UpdatedAt
                });
            }

            return statistics;
        }

        public async Task<MonthlyTrainingStatisticsResponse> GetMonthlyStatisticsAsync(int userId, int year, int month)
        {
            // Validate that the user is requesting their own statistics or is authorized
            var currentUserId = GetCurrentUserId();
            if (currentUserId != userId && !await IsAuthorizedToViewStatistics(userId))
            {
                throw new UnauthorizedAccessException("You don't have permission to view these statistics");
            }

            var monthStart = new DateTime(year, month, 1);
            var monthEnd = monthStart.AddMonths(1);

            // Count completed training sessions for the month
            var sessionCount = await _context.Set<TrainingSession>()
                .Where(ts => ts.ClientId == userId)
                .Where(ts => ts.Status == TrainingSessionStatus.Completed)
                .Where(ts => ts.ScheduledDateTime >= monthStart && ts.ScheduledDateTime < monthEnd)
                .CountAsync();

            // Get saved comment if exists
            var savedStatistics = await _context.Set<MonthlyTrainingStatistics>()
                .FirstOrDefaultAsync(s => s.UserId == userId && s.Year == year && s.Month == month);

            var monthName = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month);

            return new MonthlyTrainingStatisticsResponse
            {
                Id = savedStatistics?.Id ?? 0,
                UserId = userId,
                UserName = string.Empty,
                Year = year,
                Month = month,
                MonthName = monthName,
                TrainingSessionCount = sessionCount,
                Comment = savedStatistics?.Comment,
                CreatedAt = savedStatistics?.CreatedAt ?? DateTime.UtcNow,
                UpdatedAt = savedStatistics?.UpdatedAt
            };
        }

        public async Task<MonthlyTrainingStatisticsResponse> UpdateMonthlyCommentAsync(int userId, MonthlyCommentUpsertRequest request)
        {
            // Validate that the user is updating their own comment
            var currentUserId = GetCurrentUserId();
            if (currentUserId != userId)
            {
                throw new UnauthorizedAccessException("You can only update your own monthly comments");
            }

            // Validate year and month
            if (request.Year < 2000 || request.Year > DateTime.UtcNow.Year + 1)
            {
                throw new ArgumentException("Invalid year");
            }

            var existingStatistics = await _context.Set<MonthlyTrainingStatistics>()
                .FirstOrDefaultAsync(s => s.UserId == userId && s.Year == request.Year && s.Month == request.Month);

            if (existingStatistics != null)
            {
                // Update existing comment
                existingStatistics.Comment = request.Comment;
                existingStatistics.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                // Create new entry
                existingStatistics = new MonthlyTrainingStatistics
                {
                    UserId = userId,
                    Year = request.Year,
                    Month = request.Month,
                    TrainingSessionCount = 0, // Will be calculated dynamically
                    Comment = request.Comment,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Set<MonthlyTrainingStatistics>().Add(existingStatistics);
            }

            await _context.SaveChangesAsync();

            // Return the full statistics for this month
            return await GetMonthlyStatisticsAsync(userId, request.Year, request.Month);
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier);
            return int.Parse(userIdClaim?.Value ?? "0");
        }

        private async Task<bool> IsAuthorizedToViewStatistics(int userId)
        {
            var currentUserId = GetCurrentUserId();
            
            // Check if current user is the personal trainer of this user
            var isTrainer = await _context.Set<PersonalTrainer>()
                .AnyAsync(pt => pt.UserId == currentUserId && 
                    _context.Set<TrainingSession>().Any(ts => ts.ClientId == userId && ts.PersonalTrainerId == pt.Id));

            // Check if current user is admin/superadmin
            var isAdmin = _httpContextAccessor.HttpContext?.User?.IsInRole(Roles.Administrator) ?? false;
            var isSuperAdmin = _httpContextAccessor.HttpContext?.User?.IsInRole(Roles.SuperAdmin) ?? false;

            return isTrainer || isAdmin || isSuperAdmin;
        }
    }
}
