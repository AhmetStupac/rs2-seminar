using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class TrainingSessionController : BaseCRUDController<TrainingSessionResponse, TrainingSessionSearchObject, TrainingSessionUpsertRequest, TrainingSessionUpsertRequest>
    {
        private readonly ITrainingSessionService _trainingSessionService;

        public TrainingSessionController(ITrainingSessionService service) : base(service)
        {
            _trainingSessionService = service;
        }

        [HttpPut("{id}/confirm")]
        public async Task<ActionResult<TrainingSessionResponse>> Confirm(int id)
        {
            try
            {
                var result = await _trainingSessionService.ConfirmAsync(id);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}/cancel")]
        public async Task<ActionResult<TrainingSessionResponse>> Cancel(int id, [FromBody] TrainingSessionCancelRequest request)
        {
            try
            {
                var result = await _trainingSessionService.CancelAsync(id, request);
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("availability/{trainerId}")]
        public async Task<ActionResult<List<DateTime>>> GetAvailableSlots(
            int trainerId,
            [FromQuery] DateTime date,
            [FromQuery] int durationMinutes = 60)
        {
            var result = await _trainingSessionService.GetAvailableTimeSlotsAsync(trainerId, date, durationMinutes);
            return Ok(result);
        }

        [HttpGet("check-availability")]
        public async Task<ActionResult<bool>> CheckAvailability(
            [FromQuery] int trainerId,
            [FromQuery] DateTime scheduledDateTime,
            [FromQuery] int durationMinutes)
        {
            var result = await _trainingSessionService.CheckAvailabilityAsync(trainerId, scheduledDateTime, durationMinutes);
            return Ok(result);
        }
    }
}
