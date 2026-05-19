using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using eCommerce.WebAPI.Filters;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class GymController : BaseCRUDController<GymResponse, GymSearchObject, GymUpsertRequest, GymUpsertRequest>
    {
        public GymController(IGymService service) : base(service)
        {
            
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpPost]
        public override async Task<GymResponse> Create([FromBody] GymUpsertRequest request)
        {
            return await base.Create(request);
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpPut("{id}")]
        public override async Task<GymResponse?> Update(int id, [FromBody] GymUpsertRequest request)
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
