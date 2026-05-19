using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CityController : BaseCRUDController<CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest>
    {
        public CityController(ICityService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator,SuperAdmin")]
        [HttpPost]
        public override async Task<CityResponse> Create([FromBody] CityUpsertRequest request)
            => await base.Create(request);

        [Authorize(Roles = "Administrator,SuperAdmin")]
        [HttpPut("{id}")]
        public override async Task<CityResponse?> Update(int id, [FromBody] CityUpsertRequest request)
            => await base.Update(id, request);

        [Authorize(Roles = "Administrator,SuperAdmin")]
        [HttpDelete("{id}")]
        public override async Task<bool> Delete(int id)
            => await base.Delete(id);
    }
}
