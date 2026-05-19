using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MonthlyTrainingStatisticsController : ControllerBase
    {
        private readonly IMonthlyTrainingStatisticsService _statisticsService;
        private readonly ICurrentUserService _currentUser;

        public MonthlyTrainingStatisticsController(IMonthlyTrainingStatisticsService statisticsService, ICurrentUserService currentUser)
        {
            _statisticsService = statisticsService;
            _currentUser = currentUser;
        }

        /// <summary>
        /// Get yearly training statistics for a user (all 12 months)
        /// </summary>
        [HttpGet("user/{userId}/year/{year}")]
        public async Task<ActionResult<List<MonthlyTrainingStatisticsResponse>>> GetYearlyStatistics(int userId, int year)
        {
            try
            {
                var statistics = await _statisticsService.GetYearlyStatisticsAsync(userId, year);
                return Ok(statistics);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Get training statistics for a specific month
        /// </summary>
        [HttpGet("user/{userId}/year/{year}/month/{month}")]
        public async Task<ActionResult<MonthlyTrainingStatisticsResponse>> GetMonthlyStatistics(int userId, int year, int month)
        {
            try
            {
                var statistics = await _statisticsService.GetMonthlyStatisticsAsync(userId, year, month);
                return Ok(statistics);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Update or add a comment for a specific month
        /// </summary>
        [HttpPut("user/{userId}/comment")]
        public async Task<ActionResult<MonthlyTrainingStatisticsResponse>> UpdateMonthlyComment(int userId, [FromBody] MonthlyCommentUpsertRequest request)
        {
            try
            {
                var statistics = await _statisticsService.UpdateMonthlyCommentAsync(userId, request);
                return Ok(statistics);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid();
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while updating the comment" });
            }
        }

        /// <summary>
        /// Get current year statistics for authenticated user
        /// </summary>
        [HttpGet("my-statistics")]
        public async Task<ActionResult<List<MonthlyTrainingStatisticsResponse>>> GetMyStatistics()
        {
            if (!_currentUser.UserId.HasValue) return Unauthorized();
            var statistics = await _statisticsService.GetYearlyStatisticsAsync(_currentUser.UserId.Value, DateTime.UtcNow.Year);
            return Ok(statistics);
        }

        /// <summary>
        /// Get statistics for a specific year for authenticated user
        /// </summary>
        [HttpGet("my-statistics/year/{year}")]
        public async Task<ActionResult<List<MonthlyTrainingStatisticsResponse>>> GetMyStatisticsByYear(int year)
        {
            if (!_currentUser.UserId.HasValue) return Unauthorized();
            var statistics = await _statisticsService.GetYearlyStatisticsAsync(_currentUser.UserId.Value, year);
            return Ok(statistics);
        }
    }
}
