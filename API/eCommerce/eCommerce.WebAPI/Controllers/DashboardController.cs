using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
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

        public DashboardController(IDashboardReportService dashboardReportService, IB210033DbContext context)
        {
            _dashboardReportService = dashboardReportService;
            _context = context;
        }

        /// <summary>SuperAdmin only – platform-wide overview + top 3 trainers.</summary>
        [HttpGet("report")]
        [Authorize(Roles = "SuperAdmin")]
        public async Task<IActionResult> GetReport()
        {
            var report = await _dashboardReportService.GetReportAsync();
            return Ok(report);
        }

        /// <summary>Administrator (PersonalTrainer) – own stats only.</summary>
        [HttpGet("trainer-dashboard")]
        [Authorize(Roles = "Administrator")]
        public async Task<IActionResult> GetTrainerDashboard()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
                return Unauthorized("Could not identify the current user.");

            var trainer = await _context.Set<PersonalTrainer>()
                .FirstOrDefaultAsync(pt => pt.UserId == userId);

            if (trainer == null)
                return NotFound("No PersonalTrainer profile found for the current user.");

            var dashboard = await _dashboardReportService.GetTrainerDashboardAsync(trainer.Id);
            return Ok(dashboard);
        }
    }
}
