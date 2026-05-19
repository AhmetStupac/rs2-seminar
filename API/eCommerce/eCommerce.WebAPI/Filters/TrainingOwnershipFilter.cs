using eCommerce.Model.Requests;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Filters
{
    public class TrainingOwnershipFilter : IAsyncActionFilter
    {
        private readonly IB210033DbContext _context;
        private readonly ICurrentUserService _currentUser;

        public TrainingOwnershipFilter(IB210033DbContext context, ICurrentUserService currentUser)
        {
            _context = context;
            _currentUser = currentUser;
        }

        public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
        {
            if (_currentUser.IsSuperAdmin)
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

            var request = context.ActionArguments.Values.OfType<TrainingUpsertRequest>().FirstOrDefault();
            if (request != null)
            {
                var ownsTrainer = await _context.PersonalTrainers
                    .AnyAsync(pt => pt.Id == request.PersonalTrainerId && pt.UserId == userId.Value);

                if (!ownsTrainer)
                {
                    context.Result = new ForbidResult();
                    return;
                }
            }

            if (context.ActionArguments.TryGetValue("id", out var idValue) && idValue is int id)
            {
                var training = await _context.Trainings.AsNoTracking().FirstOrDefaultAsync(t => t.Id == id);
                if (training != null)
                {
                    var ownsTrainer = await _context.PersonalTrainers
                        .AnyAsync(pt => pt.Id == training.PersonalTrainerId && pt.UserId == userId.Value);

                    if (!ownsTrainer || (request != null && request.PersonalTrainerId != training.PersonalTrainerId))
                    {
                        context.Result = new ForbidResult();
                        return;
                    }
                }
            }

            await next();
        }
    }
}
