using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
        private readonly ICurrentUserService _currentUser;

        public GroupTrainingSessionController(IGroupTrainingSessionService service, ICurrentUserService currentUser) : base(service)
        {
            _groupTrainingSessionService = service;
            _currentUser = currentUser;
        }

        [HttpPost("{id}/join")]
        public async Task<ActionResult<GroupTrainingSessionResponse>> Join(int id)
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            return await _groupTrainingSessionService.JoinAsync(id, _currentUser.UserId.Value);
        }

        [HttpDelete("{id}/leave")]
        public async Task<ActionResult<bool>> Leave(int id)
        {
            if (!_currentUser.UserId.HasValue) return Forbid();
            return await _groupTrainingSessionService.LeaveAsync(id, _currentUser.UserId.Value);
        }
    }
}
