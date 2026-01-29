using eCommerce.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using eCommerce.Model.Responses;
using eCommerce.Model.Requests;
using eCommerce.Model.SearchObjects;

namespace eCommerce.Services
{
    public interface IUserService
    {
        Task<List<UserResponse>> GetAsync(UserSearchObject search);
        Task<UserResponse?> GetByIdAsync(int id);
        Task<UserResponse> CreateAsync(UserUpsertRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest request);
        Task<bool> DeleteAsync(int id);
        Task<bool> PermanentDeleteAsync(int id);
        Task<bool> RestoreUserAsync(int id);
        Task<List<UserResponse>> GetDeletedUsersAsync();
        Task<UserResponse?> AuthenticateAsync(UserLoginRequest request);
        Task<bool> BanUserAsync(int userId, string reason, DateTime? expiresAt);
        Task<bool> UnbanUserAsync(int userId);
        Task<bool> IsUserBannedAsync(int userId);
        Task<User> GetUserByIdAsync(int userId);
    }
} 