using eCommerce.Model.Validators;
using eCommerce.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Threading;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class UserDuplicateChecker : IUserDuplicateChecker
    {
        private readonly IB210033DbContext _context;

        public UserDuplicateChecker(IB210033DbContext context)
        {
            _context = context;
        }

        public Task<bool> EmailExistsAsync(string email, int? excludeUserId = null, CancellationToken cancellationToken = default)
        {
            return _context.Users.AnyAsync(
                u => u.Email == email && (!excludeUserId.HasValue || u.Id != excludeUserId),
                cancellationToken);
        }

        public Task<bool> UsernameExistsAsync(string username, int? excludeUserId = null, CancellationToken cancellationToken = default)
        {
            return _context.Users.AnyAsync(
                u => u.Username == username && (!excludeUserId.HasValue || u.Id != excludeUserId),
                cancellationToken);
        }
    }
}
