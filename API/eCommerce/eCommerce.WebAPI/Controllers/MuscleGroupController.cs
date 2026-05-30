using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Constants;
using eCommerce.Services.Interface;
using eCommerce.WebAPI.Filters;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class MuscleGroupController : BaseCRUDController
        <MuscleGroupResponse, MuscleGroupSearchObject, MuscleGroupUpsertRequest, MuscleGroupUpsertRequest>
    {

        public MuscleGroupController(IMuscleGroupService service) : base(service)
        {
            
        }

        [ServiceFilter(typeof(AdminOrTrainerOnlyFilter))]
        [HttpGet]
        public override async Task<PagedResult<MuscleGroupResponse>> Get([FromQuery] MuscleGroupSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [ServiceFilter(typeof(AdminOrTrainerOnlyFilter))]
        [HttpGet("{id}")]
        public override async Task<MuscleGroupResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpPost]
        public override async Task<MuscleGroupResponse> Create([FromBody] MuscleGroupUpsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpPut("{id}")]
        public override async Task<MuscleGroupResponse?> Update(int id, [FromBody] MuscleGroupUpsertRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpDelete("{id}")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

    }
}