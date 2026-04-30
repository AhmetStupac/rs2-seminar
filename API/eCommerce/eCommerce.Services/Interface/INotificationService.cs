using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eCommerce.Services.Interface
{
    public interface INotificationService : IService<NotificationResponse, NotificationSearchObject>
    {
        Task<NotificationResponse> CreateAsync(NotificationCreateRequest request);
        Task CreateBulkAsync(IEnumerable<int> userIds, string title, string message, string type);
        Task MarkAsReadAsync(int userId, int notificationId);
        Task MarkAllAsReadAsync(int userId);
    }
}
