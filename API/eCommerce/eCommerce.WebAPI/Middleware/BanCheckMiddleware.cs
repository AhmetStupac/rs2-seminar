using eCommerce.Services;
using System.Security.Claims;

namespace eCommerce.WebAPI.Middleware
{
    public class BanCheckMiddleware
    {
        private readonly RequestDelegate _next;

        public BanCheckMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IUserService userService)
        {
            if (context.User.Identity?.IsAuthenticated == true)
            {
                var userIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int userId))
                {
                    if (await userService.IsUserBannedAsync(userId))
                    {
                        context.Response.StatusCode = 403;
                        await context.Response.WriteAsJsonAsync(new
                        {
                            message = "You have been banned"
                        });
                        return;
                    }
                }
            }

            await _next(context);
        }
    }

    // U Program.cs dodajte:
    // app.UseMiddleware<BanCheckMiddleware>();
}
