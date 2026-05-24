using eCommerce.Model.Constants;
using eCommerce.Model.Responses;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class MembershipController : ControllerBase
    {
        private readonly IMembershipService _membershipService;
        private readonly ICurrentUserService _currentUser;

        public MembershipController(IMembershipService membershipService, ICurrentUserService currentUser)
        {
            _membershipService = membershipService;
            _currentUser = currentUser;
        }

        /// <summary>
        /// Returns all memberships (active and expired) for the currently authenticated client.
        /// </summary>
        [HttpGet("my")]
        public async Task<IActionResult> GetMyMemberships()
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            var result = await _membershipService.GetClientMembershipsAsync(_currentUser.UserId.Value);
            return Ok(result);
        }

        /// <summary>
        /// Checks whether the current user has an active membership with the specified trainer.
        /// </summary>
        [HttpGet("active/{trainerId:int}")]
        public async Task<IActionResult> HasActiveMembership(int trainerId)
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            var result = await _membershipService.HasActiveMembershipAsync(_currentUser.UserId.Value, trainerId);
            return Ok(new { isActive = result });
        }

        /// <summary>
        /// Returns all memberships for the authenticated trainer's clients.
        /// The trainer scope is resolved from the JWT user; route ids from the client are not used.
        /// </summary>
        [HttpGet("trainer/clients")]
        [Authorize(Roles = Roles.Administrator)]
        public async Task<IActionResult> GetMyTrainerMemberships()
        {
            if (!_currentUser.UserId.HasValue)
                return Forbid();

            var trainerId = await _currentUser.GetPersonalTrainerIdAsync();
            if (!trainerId.HasValue)
                return NotFound(new { message = "No PersonalTrainer profile found for the current user." });

            var result = await _membershipService.GetTrainerMembershipsAsync(trainerId.Value);
            return Ok(result);
        }

        /// <summary>
        /// Returns the count of active clients for a trainer.
        /// </summary>
        [HttpGet("trainer/{personalTrainerId:int}/active-count")]
        public async Task<IActionResult> GetActiveClientCount(int personalTrainerId)
        {
            var count = await _membershipService.GetActiveClientCountAsync(personalTrainerId);
            return Ok(new { personalTrainerId, activeClientCount = count, maxClients = 5 });
        }

        /// <summary>
        /// Revokes a membership early (trainer-only). Does not trigger a refund.
        /// </summary>
        [HttpPut("{membershipId:int}/revoke")]
        [Authorize(Roles = Roles.Administrator)]
        public async Task<IActionResult> Revoke(int membershipId)
        {
            if (!_currentUser.UserId.HasValue) return Forbid();

            try
            {
                var result = await _membershipService.RevokeAsync(membershipId, _currentUser.UserId.Value);
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

    }
}
