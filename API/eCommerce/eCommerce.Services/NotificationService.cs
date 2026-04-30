using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class NotificationService : BaseService<NotificationResponse, NotificationSearchObject, Notification>, INotificationService
    {
        private readonly IB210033DbContext _context;

        public NotificationService(IB210033DbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        protected override IQueryable<Notification> ApplyFilter(IQueryable<Notification> query, NotificationSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(n => n.UserId == search.UserId.Value);

            if (search.IsRead.HasValue)
                query = query.Where(n => n.IsRead == search.IsRead.Value);

            if (search.CreatedAfter.HasValue)
                query = query.Where(n => n.CreatedAt >= search.CreatedAfter.Value);

            return query.OrderByDescending(n => n.CreatedAt);
        }

        public async Task<NotificationResponse> CreateAsync(NotificationCreateRequest request)
        {
            var entity = new Notification
            {
                UserId = request.UserId,
                Title = request.Title,
                Message = request.Message,
                Type = request.Type,
                IsRead = false,
                CreatedAt = DateTime.UtcNow
            };

            _context.Set<Notification>().Add(entity);
            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        public async Task CreateBulkAsync(IEnumerable<int> userIds, string title, string message, string type)
        {
            var now = DateTime.UtcNow;
            var notifications = userIds.Select(userId => new Notification
            {
                UserId = userId,
                Title = title,
                Message = message,
                Type = type,
                IsRead = false,
                CreatedAt = now
            }).ToList();

            if (notifications.Count == 0)
                return;

            _context.Set<Notification>().AddRange(notifications);
            await _context.SaveChangesAsync();
        }

        public async Task MarkAsReadAsync(int userId, int notificationId)
        {
            var notification = await _context.Set<Notification>()
                .FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId);

            if (notification == null)
                throw new KeyNotFoundException("Notification not found.");

            if (notification.IsRead)
                return;

            notification.IsRead = true;
            notification.ReadAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }

        public async Task MarkAllAsReadAsync(int userId)
        {
            var notifications = await _context.Set<Notification>()
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync();

            if (notifications.Count == 0)
                return;

            var now = DateTime.UtcNow;
            foreach (var notification in notifications)
            {
                notification.IsRead = true;
                notification.ReadAt = now;
            }

            await _context.SaveChangesAsync();
        }

        protected override NotificationResponse MapToResponse(Notification entity)
        {
            return new NotificationResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                Title = entity.Title,
                Message = entity.Message,
                Type = entity.Type,
                IsRead = entity.IsRead,
                CreatedAt = entity.CreatedAt,
                ReadAt = entity.ReadAt
            };
        }
    }
}
