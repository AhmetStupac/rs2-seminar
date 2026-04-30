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
        public Task<ActionResult<TrainingSessionResponse>> Confirm(int id)
            => HandleStateTransition(() => _trainingSessionService.ConfirmAsync(id));

        [HttpPut("{id}/cancel")]
        public Task<ActionResult<TrainingSessionResponse>> Cancel(int id, [FromBody] TrainingSessionCancelRequest request)
            => HandleStateTransition(() => _trainingSessionService.CancelAsync(id, request));

        [HttpPut("{id}/complete")]
        public Task<ActionResult<TrainingSessionResponse>> Complete(int id)
            => HandleStateTransition(() => _trainingSessionService.CompleteAsync(id));

        [HttpPut("{id}/no-show")]
        public Task<ActionResult<TrainingSessionResponse>> MarkNoShow(int id)
            => HandleStateTransition(() => _trainingSessionService.MarkNoShowAsync(id));

        [HttpGet("{id}/allowed-actions")]
        public async Task<ActionResult<List<string>>> AllowedActions(int id)
        {
            try
            {
                var actions = await _trainingSessionService.AllowedActionsAsync(id);
                return Ok(actions);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
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

        private async Task<ActionResult<TrainingSessionResponse>> HandleStateTransition(Func<Task<TrainingSessionResponse>> action)
        {
            try
            {
                var result = await action();
                return Ok(result);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
