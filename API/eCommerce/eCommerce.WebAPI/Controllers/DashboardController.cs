using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using eCommerce.Model.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardReportService _dashboardReportService;
        private readonly IB210033DbContext _context;
        private readonly ICurrentUserService _currentUser;

        public DashboardController(IDashboardReportService dashboardReportService, IB210033DbContext context, ICurrentUserService currentUser)
        {
            _dashboardReportService = dashboardReportService;
            _context = context;
            _currentUser = currentUser;
        }

        /// <summary>SuperAdmin only – platform-wide overview + top 3 trainers.</summary>
        [HttpGet("report")]
        [Authorize(Roles = Roles.SuperAdmin)]
        public async Task<IActionResult> GetReport()
        {
            var report = await _dashboardReportService.GetReportAsync();
            return Ok(report);
        }

        /// <summary>Administrator (PersonalTrainer) – own stats only.</summary>
        [HttpGet("trainer-dashboard")]
        [Authorize(Roles = Roles.Administrator)]
        public async Task<IActionResult> GetTrainerDashboard()
        {
            if (!_currentUser.UserId.HasValue)
                return Unauthorized("Could not identify the current user.");

            var trainer = await _context.Set<PersonalTrainer>()
                .FirstOrDefaultAsync(pt => pt.UserId == _currentUser.UserId.Value);

            if (trainer == null)
                return NotFound("No PersonalTrainer profile found for the current user.");

            var dashboard = await _dashboardReportService.GetTrainerDashboardAsync(trainer.Id);
            return Ok(dashboard);
        }
    }
}
