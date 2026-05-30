using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Filters
{
    public class AdminOrTrainerOnlyFilter : IAsyncActionFilter
    {
        private readonly IB210033DbContext _context;
        private readonly ICurrentUserService _currentUser;

        public AdminOrTrainerOnlyFilter(IB210033DbContext context, ICurrentUserService currentUser)
        {
            _context = context;
            _currentUser = currentUser;
        }

        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            if (_currentUser.IsAdmin)
            {
                await next();
                return;
            }

            var userId = _currentUser.UserId;
            if (!userId.HasValue)
            {
                context.Result = new ForbidResult();
                return;
            }

            var isTrainer = await _context.PersonalTrainers.AnyAsync(pt => pt.UserId == userId.Value);
            if (!isTrainer)
            {
                context.Result = new ForbidResult();
                return;
            }

            await next();
        }
    }
}
