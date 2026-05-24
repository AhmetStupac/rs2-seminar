using eCommerce.Model.Constants;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class CurrentUserService : ICurrentUserService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IB210033DbContext _context;

        public CurrentUserService(IHttpContextAccessor httpContextAccessor, IB210033DbContext context)
        {
            _httpContextAccessor = httpContextAccessor;
            _context = context;
        }

        private ClaimsPrincipal? User => _httpContextAccessor.HttpContext?.User;

        public int? UserId
        {
            get
            {
                var value = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value
                            ?? User?.FindFirst("nameid")?.Value;
                return int.TryParse(value, out var id) ? id : null;
            }
        }

        public bool IsAuthenticated => User?.Identity?.IsAuthenticated == true;

        public bool IsSuperAdmin => User?.IsInRole(Roles.SuperAdmin) == true;

        public bool IsAdministrator => User?.IsInRole(Roles.Administrator) == true;

        public bool IsAdmin => IsSuperAdmin || IsAdministrator;

        public async Task<int?> GetPersonalTrainerIdAsync()
        {
            if (!UserId.HasValue)
                return null;

            return await _context.PersonalTrainers
                .Where(pt => pt.UserId == UserId.Value)
                .Select(pt => (int?)pt.Id)
                .FirstOrDefaultAsync();
        }
    }
}
