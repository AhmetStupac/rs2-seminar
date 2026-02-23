using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
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

        [HttpPost("{id}/join/{userId}")]
        public async Task<GroupTrainingSessionResponse> Join(int id, int userId)
        {
            return await _groupTrainingSessionService.JoinAsync(id, userId);
        }

        [HttpDelete("{id}/leave/{userId}")]
        public async Task<bool> Leave(int id, int userId)
        {
            return await _groupTrainingSessionService.LeaveAsync(id, userId);
        }
    }
}
