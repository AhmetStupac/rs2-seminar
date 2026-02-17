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

        public UserService(IB210033DbContext context, ITokenService tokenService, IEmailService emailService)
        {
            _context = context;
            _tokenService = tokenService;
            _emailService = emailService;
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
            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(salt);
            }

            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations))
            {
                return Convert.ToBase64String(pbkdf2.GetBytes(KeySize));
            }
        }

        public async Task<UserResponse> CreateAsync(UserUpsertRequest request)
        {
            // Check for duplicate email and username
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
                CreatedAt = DateTime.UtcNow
            };

            // Handle password if provided
            if (!string.IsNullOrEmpty(request.Password))
            {
                byte[] salt;
                user.PasswordHash = HashPassword(request.Password, out salt);
                user.PasswordSalt = Convert.ToBase64String(salt);
            }

            // Add user to database first to get the ID
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            // Now assign roles if any are specified
            if (request.RoleIds != null && request.RoleIds.Count > 0)
            {
                foreach (var roleId in request.RoleIds)
                {
                    // Check if role exists
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
                await _context.SaveChangesAsync();
            }

            return await GetUserResponseWithRolesAsync(user.Id);
        }

        public async Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest request)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return null;

            // Check for duplicate email and username (excluding current user)
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

            // Handle password if provided
            if (!string.IsNullOrEmpty(request.Password))
            {
                byte[] salt;
                user.PasswordHash = HashPassword(request.Password, out salt);
                user.PasswordSalt = Convert.ToBase64String(salt);
            }
            
            // Update roles
            // First, remove all existing roles
            var existingUserRoles = await _context.UserRoles.Where(ur => ur.UserId == id).ToListAsync();
            _context.UserRoles.RemoveRange(existingUserRoles);
            
            // Then add the new roles
            if (request.RoleIds != null && request.RoleIds.Count > 0)
            {
                foreach (var roleId in request.RoleIds)
                {
                    // Check if role exists
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
            return await GetUserResponseWithRolesAsync(user.Id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return false;

            // Soft delete - samo postavi flag
            user.IsDeleted = true;
            user.DeletedAt = DateTime.UtcNow;
            // user.DeletedBy = currentUserId; // Možeš dodati ako znaš trenutnog korisnika

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
                ProfileImageUrl = user.ProfileImage?.Url
                //Token = _tokenService.CreateToken(user)
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

            if (!VerifyPassword(request.Password!, user.PasswordHash, user.PasswordSalt))
                return null;

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
            
            return response;
        }
        private bool VerifyPassword(string password, string passwordHash, string passwordSalt)
        {
            var salt = Convert.FromBase64String(passwordSalt);
            var hash = Convert.FromBase64String(passwordHash);
            var hashBytes = new Rfc2898DeriveBytes(password, salt, Iterations).GetBytes(KeySize);
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
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == email);

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
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
                return false;

            // Validate code
            if (string.IsNullOrEmpty(user.ResetCode) || 
                user.ResetCode != code || 
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
            var random = new Random();
            return random.Next(100000, 999999).ToString();
        }

    }
}