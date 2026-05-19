using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class PersonalTrainerRatingController : ControllerBase
    {
        private readonly IPersonalTrainerRatingService _ratingService;
        private readonly ICurrentUserService _currentUser;

        public PersonalTrainerRatingController(IPersonalTrainerRatingService ratingService, ICurrentUserService currentUser)
        {
            _ratingService = ratingService;
            _currentUser = currentUser;
        }

        // Get current user's rating for a specific trainer
        [HttpGet("my-rating/{personalTrainerId}")]
        public async Task<ActionResult<PersonalTrainerRatingResponse>> GetMyRating(int personalTrainerId)
        {
            var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
            var rating = await _ratingService.GetUserRatingForTrainerAsync(userId, personalTrainerId);

            if (rating == null)
                return NotFound(new { message = "You haven't rated this trainer yet" });

            return Ok(rating);
        }

        // Get all ratings for a specific trainer
        [AllowAnonymous]
        [HttpGet("trainer/{personalTrainerId}")]
        public async Task<ActionResult<List<PersonalTrainerRatingResponse>>> GetTrainerRatings(int personalTrainerId)
        {
            var ratings = await _ratingService.GetRatingsForTrainerAsync(personalTrainerId);
            return Ok(ratings);
        }

        // Get rating statistics for a trainer
        [AllowAnonymous]
        [HttpGet("trainer/{personalTrainerId}/stats")]
        public async Task<ActionResult> GetTrainerRatingStats(int personalTrainerId)
        {
            var (averageRating, totalRatings) = await _ratingService.GetTrainerRatingStatsAsync(personalTrainerId);
            return Ok(new { averageRating, totalRatings });
        }

        // Create a new rating
        [HttpPost]
        public async Task<ActionResult<PersonalTrainerRatingResponse>> CreateRating([FromBody] PersonalTrainerRatingUpsertRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
                var rating = await _ratingService.CreateRatingAsync(userId, request);
                return CreatedAtAction(nameof(GetMyRating), new { personalTrainerId = rating.PersonalTrainerId }, rating);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // Update existing rating
        [HttpPut("{ratingId}")]
        public async Task<ActionResult<PersonalTrainerRatingResponse>> UpdateRating(int ratingId, [FromBody] PersonalTrainerRatingUpsertRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
            var rating = await _ratingService.UpdateRatingAsync(ratingId, userId, request);

            if (rating == null)
                return NotFound(new { message = "Rating not found or you don't have permission to update it" });

            return Ok(rating);
        }

        // Delete rating
        [HttpDelete("{ratingId}")]
        public async Task<ActionResult> DeleteRating(int ratingId)
        {
            var userId = _currentUser.UserId ?? throw new UnauthorizedAccessException();
            var success = await _ratingService.DeleteRatingAsync(ratingId, userId);

            if (!success)
                return NotFound(new { message = "Rating not found or you don't have permission to delete it" });

            return NoContent();
        }

    }
}
