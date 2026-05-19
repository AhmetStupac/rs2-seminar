using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using eCommerce.WebAPI.Filters;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

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

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpPost]
        public override async Task<MuscleGroupResponse> Create([FromBody] MuscleGroupUpsertRequest request)
        {
            return await base.Create(request);
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpPut("{id}")]
        public override async Task<MuscleGroupResponse?> Update(int id, [FromBody] MuscleGroupUpsertRequest request)
        {
            return await base.Update(id, request);
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpDelete("{id}")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

    }
}