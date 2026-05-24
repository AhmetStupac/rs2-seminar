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
        Task<UserResponse> CreateAsync(UserCreateRequest request);
        Task<UserResponse> RegisterAsync(RegisterRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserUpdateRequest request);
        Task<UserResponse?> UpdateRolesAsync(int id, List<int> roleIds);
        Task<bool> DeleteAsync(int id);
        Task<bool> PermanentDeleteAsync(int id);
        Task<bool> RestoreUserAsync(int id);
        Task<List<UserResponse>> GetDeletedUsersAsync();
        Task<UserResponse?> AuthenticateAsync(UserLoginRequest request);
        Task<bool> BanUserAsync(int userId, string reason, DateTime? expiresAt);
        Task<bool> UnbanUserAsync(int userId);
        Task<bool> IsUserBannedAsync(int userId);
        Task<User> GetUserByIdAsync(int userId);
        Task<bool> ChangePasswordAsync(int userId, string currentPassword, string newPassword);
        Task<bool> ForgotPasswordAsync(string email);
        Task<bool> ResetPasswordAsync(string email, string code, string newPassword);
    }
} 