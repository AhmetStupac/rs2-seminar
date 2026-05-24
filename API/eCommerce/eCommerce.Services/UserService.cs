using eCommerce.Model.Messages;
using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Validators;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class UserService : IUserService
    {
        private readonly IB210033DbContext _context;
        private const int SaltSize = 16;
        private const int KeySize = 32;
        private const int Iterations = 10000;
        private readonly ITokenService _tokenService;
        private readonly IEmailService _emailService;
        private readonly IRabbitMQPublisher _rabbitMQPublisher;
        private readonly IValidator<RegisterRequest> _registerValidator;
        private readonly IValidator<UserCreateRequest> _createValidator;
        private readonly IValidator<UserUpdateRequest> _updateValidator;

        public UserService(
            IB210033DbContext context,
            ITokenService tokenService,
            IEmailService emailService,
            IRabbitMQPublisher rabbitMQPublisher,
            IValidator<RegisterRequest> registerValidator,
            IValidator<UserCreateRequest> createValidator,
            IValidator<UserUpdateRequest> updateValidator)
        {
            _context = context;
            _tokenService = tokenService;
            _emailService = emailService;
            _rabbitMQPublisher = rabbitMQPublisher;
            _registerValidator = registerValidator;
            _createValidator = createValidator;
            _updateValidator = updateValidator;
        }

        public async Task<List<UserResponse>> GetAsync(UserSearchObject search)
        {
            var query = _context.Users
                .Include(u => u.ProfileImage)
                .AsQueryable();
            
            if (!string.IsNullOrEmpty(search.Username))
            {
                query = query.Where(u => u.Username.Contains(search.Username));
            }
            
            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(u => u.Email.Contains(search.Email));
            }
            
            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(u => 
                    u.FirstName.Contains(search.FTS) || 
                    u.LastName.Contains(search.FTS) || 
                    u.Username.Contains(search.FTS) || 
                    u.Email.Contains(search.FTS));
            }

            query = query.OrderBy(u => u.Id);

            var pageSize = Math.Min(search.PageSize ?? 10, 50);
            var page = search.Page ?? 0;
            query = query.Skip(page * pageSize).Take(pageSize);

            var users = await query.ToListAsync();
            return users.Select(MapToResponse).ToList();
        }

        public async Task<UserResponse?> GetByIdAsync(int id)
        {
            var user = await _context.Users
                .Include(u => u.ProfileImage)
                .FirstOrDefaultAsync(u => u.Id == id);
            return user != null ? MapToResponse(user) : null;
        }

        private string HashPassword(string password, out byte[] salt)
        {
            salt = new byte[SaltSize];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations))
            {
                return Convert.ToBase64String(pbkdf2.GetBytes(KeySize));
            }
        }

        // image upload koraci, prvo se upload slika na azure, azure vrati imageId na front end...

        public async Task<UserResponse> CreateAsync(UserCreateRequest request)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            UserResponse? createdUser = null;

            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();

                await EnsureValidAsync(_createValidator, request);

                var user = new User
                {
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    Email = request.Email,
                    Username = request.Username,
                    PhoneNumber = request.PhoneNumber,
                    IsActive = true,
                    ProfileImageId = request.ProfileImageId,
                    CreatedAt = DateTime.UtcNow,
                    IsDeleted = false
                };

                if (!string.IsNullOrEmpty(request.Password))
                {
                    byte[] salt;
                    user.PasswordHash = HashPassword(request.Password, out salt);
                    user.PasswordSalt = Convert.ToBase64String(salt);
                }

                const int defaultRoleId = 2;
                var defaultRoleExists = await _context.Roles.AnyAsync(r => r.Id == defaultRoleId);
                if (!defaultRoleExists)
                {
                    throw new InvalidOperationException("Default role (Id = 2) not found.");
                }

                user.UserRoles.Add(new UserRole
                {
                    RoleId = defaultRoleId,
                    DateAssigned = DateTime.UtcNow
                });

                _context.Users.Add(user);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                createdUser = await GetUserResponseWithRolesAsync(user.Id);
            });

            return createdUser!;
        }

        public async Task<UserResponse> RegisterAsync(RegisterRequest request)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            UserResponse? createdUser = null;

            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();

                await EnsureValidAsync(_registerValidator, request);

                var user = new User
                {
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    Email = request.Email,
                    Username = request.Username,
                    PhoneNumber = request.PhoneNumber,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    IsDeleted = false
                };

                byte[] salt;
                user.PasswordHash = HashPassword(request.Password, out salt);
                user.PasswordSalt = Convert.ToBase64String(salt);

                const int defaultRoleId = 2;
                var defaultRoleExists = await _context.Roles.AnyAsync(r => r.Id == defaultRoleId);
                if (!defaultRoleExists)
                {
                    throw new InvalidOperationException("Default role (Id = 2) not found.");
                }

                user.UserRoles.Add(new UserRole
                {
                    RoleId = defaultRoleId,
                    DateAssigned = DateTime.UtcNow
                });

                _context.Users.Add(user);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                createdUser = await GetUserResponseWithRolesAsync(user.Id);
            });

            return createdUser!;
        }

        public async Task<UserResponse?> UpdateAsync(int id, UserUpdateRequest request)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            UserResponse? updatedUser = null;

            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();

                var user = await _context.Users.FindAsync(id);
                if (user == null)
                {
                    updatedUser = null;
                    return;
                }

                await EnsureValidAsync(_updateValidator, request, id);

                user.FirstName = request.FirstName;
                user.LastName = request.LastName;
                user.Email = request.Email;
                user.Username = request.Username;
                user.PhoneNumber = request.PhoneNumber;
                user.IsActive = request.IsActive;
                user.ProfileImageId = request.ProfileImageId;

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                updatedUser = await GetUserResponseWithRolesAsync(user.Id);
            });

            return updatedUser;
        }

        public async Task<UserResponse?> UpdateRolesAsync(int id, List<int> roleIds)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            UserResponse? updatedUser = null;

            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();

                var user = await _context.Users.FindAsync(id);
                if (user == null)
                {
                    updatedUser = null;
                    return;
                }

                var existingUserRoles = await _context.UserRoles.Where(ur => ur.UserId == id).ToListAsync();
                _context.UserRoles.RemoveRange(existingUserRoles);

                if (roleIds != null && roleIds.Count > 0)
                {
                    foreach (var roleId in roleIds)
                    {
                        if (await _context.Roles.AnyAsync(r => r.Id == roleId))
                        {
                            var userRole = new UserRole
                            {
                                UserId = user.Id,
                                RoleId = roleId,
                                DateAssigned = DateTime.UtcNow
                            };
                            _context.UserRoles.Add(userRole);
                        }
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                updatedUser = await GetUserResponseWithRolesAsync(user.Id);
            });

            return updatedUser;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return false;

            // Soft delete - samo postavi flag
            user.IsDeleted = true;
            user.DeletedAt = DateTime.UtcNow;
            // user.DeletedBy = currentUserId; // Mo�e� dodati ako zna� trenutnog korisnika

            await _context.SaveChangesAsync();
            return true;
        }

        // Nova metoda za permanentno brisanje (samo za admin)
        public async Task<bool> PermanentDeleteAsync(int id)
        {
            var user = await _context.Users.IgnoreQueryFilters()
                .FirstOrDefaultAsync(u => u.Id == id);
            
            if (user == null)
                return false;

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            return true;
        }

        // Nova metoda za restore obrisanog korisnika
        public async Task<bool> RestoreUserAsync(int id)
        {
            var user = await _context.Users.IgnoreQueryFilters()
                .FirstOrDefaultAsync(u => u.Id == id && u.IsDeleted == true);
            
            if (user == null)
                return false;

            user.IsDeleted = false;
            user.DeletedAt = null;
            user.DeletedBy = null;

            await _context.SaveChangesAsync();
            return true;
        }

        // Nova metoda za dobijanje obrisanih korisnika
        public async Task<List<UserResponse>> GetDeletedUsersAsync()
        {
            var deletedUsers = await _context.Users
                .IgnoreQueryFilters()
                .Where(u => u.IsDeleted)
                .ToListAsync();
            
            return deletedUsers.Select(MapToResponse).ToList();
        }

        private UserResponse MapToResponse(User user)
        {
            return new UserResponse
            {
                Id = user.Id,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                Username = user.Username,
                PhoneNumber = user.PhoneNumber,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                LastLoginAt = user.LastLoginAt,
                IsBanned = user.IsBanned ?? false,
                BannedAt = null,
                BanReason = user.BanReason,
                BanExpiresAt = user.BanExpiresAt,
                IsDeleted = user.IsDeleted,
                DeletedAt = user.DeletedAt,
                ProfileImageId = user.ProfileImageId,
                ProfileImage = user.ProfileImage != null ? MapToImageResponse(user.ProfileImage) : null
                //Token = _tokenService.CreateToken(user)
            };
        }

        private ImageResponse MapToImageResponse(Image image)
        {
            return new ImageResponse
            {
                Id = image.Id,
                Name = image.Name,
                Url = image.Url,
                Size = image.Size,
                IsHeader = image.IsHeader
            };
        }

        // New method to get user with roles
        private async Task<UserResponse> GetUserResponseWithRolesAsync(int userId)
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == userId);
            
            if (user == null)
                throw new InvalidOperationException("User not found");
            
            var response = MapToResponse(user);
            
            // Add roles to the response
            response.Roles = user.UserRoles
                .Where(ur => ur.Role.IsActive)
                .Select(ur => new RoleResponse
                {
                    Id = ur.Role.Id,
                    Name = ur.Role.Name,
                    Description = ur.Role.Description
                })
                .ToList();
            
            return response;
        }
         
        //login metoda
        public async Task<UserResponse?> AuthenticateAsync(UserLoginRequest request)
        {
            var user = await _context.Users
                .IgnoreQueryFilters()
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Username == request.Username);
            
            if (user == null)
                return null;

            // Check if user is soft deleted
            if (user.IsDeleted)
                throw new InvalidOperationException("This account has been deleted.");

            if (!VerifyPassword(request.Password!, user.PasswordHash, user.PasswordSalt))
                return null;

            // Check if user is banned
            if (user.IsBanned == true)
            {
                if (user.BanExpiresAt.HasValue && user.BanExpiresAt.Value <= DateTime.UtcNow)
                {
                    // Ban has expired, unban the user
                    user.IsBanned = false;
                    user.BanExpiresAt = null;
                    user.BanReason = null;
                }
                else
                {
                    throw new InvalidOperationException(user.BanExpiresAt.HasValue
                        ? $"Your account is banned until {user.BanExpiresAt.Value:yyyy-MM-dd HH:mm} UTC. Reason: {user.BanReason}"
                        : $"Your account is permanently banned. Reason: {user.BanReason}");
                }
            }

            // Update last login time
            user.LastLoginAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            var response = MapToResponse(user);
            
            // Add roles to the response
            response.Roles = user.UserRoles
                .Where(ur => ur.Role.IsActive)
                .Select(ur => new RoleResponse
                {
                    Id = ur.Role.Id,
                    Name = ur.Role.Name,
                    Description = ur.Role.Description
                })
                .ToList();

            try
            {
                await _rabbitMQPublisher.PublishAsync(new LoginNotificationMessage
                {
                    Email = user.Email,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    LoginTime = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss") + " UTC"
                }, "user-login");
            }
            catch (Exception)
            {
                // RabbitMQ failure should not prevent login
            }
            
            return response;
        }
        private bool VerifyPassword(string password, string passwordHash, string passwordSalt)
        {
            var salt = Convert.FromBase64String(passwordSalt);
            var hash = Convert.FromBase64String(passwordHash);
            byte[] hashBytes;
            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations))
            {
                hashBytes = pbkdf2.GetBytes(KeySize);
            }

            return hash.SequenceEqual(hashBytes);
        }



        public async Task<bool> BanUserAsync(int userId, string reason, DateTime? expiresAt = null)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return false;

            user.IsBanned = true;
            user.BanReason = reason;
            user.BanExpiresAt = expiresAt;  // Null = permanent ban

            await _context.SaveChangesAsync();

            // Opciono: Revoke svih aktivnih sesija/tokena
            //await RevokeUserSessionsAsync(userId);

            return true;
        }

        public async Task<bool> UnbanUserAsync(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return false;

            user.IsBanned = false;
            user.BanReason = null;
            user.BanExpiresAt = null;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> IsUserBannedAsync(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null || user.IsBanned != true) return false;

            // Proveri da li je privremeni ban istekao
            if (user.BanExpiresAt.HasValue && user.BanExpiresAt.Value <= DateTime.UtcNow)
            {
                await UnbanUserAsync(userId);
                return false;
            }

            return true;
        }

        public async Task<User> GetUserByIdAsync(int userId)
        {
            return await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == userId);
        }

        public async Task<bool> ChangePasswordAsync(int userId, string currentPassword, string newPassword)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return false;

            if (!VerifyPassword(currentPassword, user.PasswordHash, user.PasswordSalt))
                return false;

            byte[] salt;
            var hash = HashPassword(newPassword, out salt);
            user.PasswordHash = hash;
            user.PasswordSalt = Convert.ToBase64String(salt);

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> ForgotPasswordAsync(string email)
        {
            email = email?.Trim();

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower());

            // Don't reveal if email exists in the system (security best practice)
            if (user == null)
                return true;

            // Generate 6-digit verification code
            var resetCode = GenerateVerificationCode();
            
            // Save code and expiry to database (expires in 15 minutes)
            user.ResetCode = resetCode;
            user.ResetCodeExpiry = DateTime.UtcNow.AddMinutes(15);
            await _context.SaveChangesAsync();

            // Send email with code (best-effort — don't fail the whole request if SMTP is misconfigured)
            try
            {
                await _emailService.SendPasswordResetEmailAsync(email, resetCode, user.FirstName);
            }
            catch (Exception ex)
            {
                // Log the code to console so it can be used during development
                Console.WriteLine($"[ForgotPassword] Email sending failed: {ex.Message}");
                Console.WriteLine($"[ForgotPassword] Reset code for {email}: {resetCode}");
            }

            return true;
        }

        public async Task<bool> ResetPasswordAsync(string email, string code, string newPassword)
        {
            email = email?.Trim();
            code = code?.Trim();

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower());

            if (user == null)
                return false;

            // Validate code
            if (string.IsNullOrEmpty(user.ResetCode) || 
                user.ResetCode.Trim() != code || 
                user.ResetCodeExpiry == null || 
                user.ResetCodeExpiry < DateTime.UtcNow)
            {
                return false;
            }

            // Hash new password
            byte[] salt;
            var hash = HashPassword(newPassword, out salt);
            user.PasswordHash = hash;
            user.PasswordSalt = Convert.ToBase64String(salt);

            // Clear reset code
            user.ResetCode = null;
            user.ResetCodeExpiry = null;

            await _context.SaveChangesAsync();
            return true;
        }

        private string GenerateVerificationCode()
        {
            return RandomNumberGenerator.GetInt32(100000, 1000000).ToString();
        }

        private static async Task EnsureValidAsync<T>(IValidator<T> validator, T request, int? excludeUserId = null)
        {
            var context = new ValidationContext<T>(request);
            if (excludeUserId.HasValue)
                context.RootContextData[UserValidationContextKeys.ExcludeUserId] = excludeUserId.Value;

            var result = await validator.ValidateAsync(context);
            if (!result.IsValid)
            {
                var errors = string.Join("; ", result.Errors.Select(e => e.ErrorMessage));
                throw new InvalidOperationException(errors);
            }
        }

    }
}