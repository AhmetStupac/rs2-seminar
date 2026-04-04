using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class GroupTrainingSessionController
        : BaseCRUDController<GroupTrainingSessionResponse, GroupTrainingSessionSearchObject, GroupTrainingSessionUpsertRequest, GroupTrainingSessionUpsertRequest>
    {
        private readonly IGroupTrainingSessionService _groupTrainingSessionService;

        public GroupTrainingSessionController(IGroupTrainingSessionService service) : base(service)
        {
            _groupTrainingSessionService = service;
        }

        [HttpPost("{id}/join")]
        public async Task<ActionResult<GroupTrainingSessionResponse>> Join(int id)
        {
            var userId = GetCurrentUserId();
            if (!userId.HasValue)
                return Forbid();

            return await _groupTrainingSessionService.JoinAsync(id, userId.Value);
        }

        [HttpDelete("{id}/leave")]
        public async Task<ActionResult<bool>> Leave(int id)
        {
            var userId = GetCurrentUserId();
            if (!userId.HasValue)
                return Forbid();

            return await _groupTrainingSessionService.LeaveAsync(id, userId.Value);
        }

        private int? GetCurrentUserId()
        {
            var claim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value
                        ?? User?.FindFirst("nameid")?.Value;

            return int.TryParse(claim, out var userId) ? userId : null;
        }
    }
}
