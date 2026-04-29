using eCommerce.Model.Messages;
using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
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

        public UserService(IB210033DbContext context, ITokenService tokenService, IEmailService emailService, IRabbitMQPublisher rabbitMQPublisher)
        {
            _context = context;
            _tokenService = tokenService;
            _emailService = emailService;
            _rabbitMQPublisher = rabbitMQPublisher;
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

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value)
                                 .Take(search.PageSize.Value);
                }
                else if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }
            
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

        public async Task<UserResponse> CreateAsync(UserUpsertRequest request)
        {
            var strategy = _context.Database.CreateExecutionStrategy();
            UserResponse? createdUser = null;

            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();

                if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                {
                    throw new InvalidOperationException("A user with this email already exists.");
                }

                if (await _context.Users.AnyAsync(u => u.Username == request.Username))
                {
                    throw new InvalidOperationException("A user with this username already exists.");
                }

                var user = new User
                {
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    Email = request.Email,
                    Username = request.Username,
                    PhoneNumber = request.PhoneNumber,
                    IsActive = request.IsActive,
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

        public async Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest request)
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

                if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != id))
                {
                    throw new InvalidOperationException("A user with this email already exists.");
                }

                if (await _context.Users.AnyAsync(u => u.Username == request.Username && u.Id != id))
                {
                    throw new InvalidOperationException("A user with this username already exists.");
                }

                user.FirstName = request.FirstName;
                user.LastName = request.LastName;
                user.Email = request.Email;
                user.Username = request.Username;
                user.PhoneNumber = request.PhoneNumber;
                user.IsActive = request.IsActive;
                user.ProfileImageId = request.ProfileImageId;

                if (!string.IsNullOrEmpty(request.Password))
                {
                    byte[] salt;
                    user.PasswordHash = HashPassword(request.Password, out salt);
                    user.PasswordSalt = Convert.ToBase64String(salt);
                }

                var existingUserRoles = await _context.UserRoles.Where(ur => ur.UserId == id).ToListAsync();
                _context.UserRoles.RemoveRange(existingUserRoles);

                if (request.RoleIds != null && request.RoleIds.Count > 0)
                {
                    foreach (var roleId in request.RoleIds)
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

            // Send email with code
            await _emailService.SendPasswordResetEmailAsync(email, resetCode, user.FirstName);

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

    }
}