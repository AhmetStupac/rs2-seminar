using eCommerce.Model.Constants;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace eCommerce.Services
{
    public class CurrentUserService : ICurrentUserService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CurrentUserService(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
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
    }
}
