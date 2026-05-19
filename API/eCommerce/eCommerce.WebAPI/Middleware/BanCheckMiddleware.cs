using eCommerce.Services;
using eCommerce.Services.Interface;

namespace eCommerce.WebAPI.Middleware
{
    public class BanCheckMiddleware
    {
        private readonly RequestDelegate _next;

        public BanCheckMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IUserService userService, ICurrentUserService currentUser)
        {
            if (currentUser.IsAuthenticated && currentUser.UserId.HasValue)
            {
                if (await userService.IsUserBannedAsync(currentUser.UserId.Value))
                {
                    context.Response.StatusCode = 403;
                    await context.Response.WriteAsJsonAsync(new { message = "You have been banned" });
                    return;
                }
            }

            await _next(context);
        }
    }

    // U Program.cs dodajte:
    // app.UseMiddleware<BanCheckMiddleware>();
}
