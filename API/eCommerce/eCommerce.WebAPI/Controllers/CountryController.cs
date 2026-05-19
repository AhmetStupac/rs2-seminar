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
    public class CountryController : BaseCRUDController<CountryResponse, CountrySearchObject, CountryUpsertRequest, CountryUpsertRequest>
    {
        public CountryController(ICountryService service) : base(service)
        {
        }

        [Authorize(Roles = "Administrator,SuperAdmin")]
        [HttpPost]
        public override async Task<CountryResponse> Create([FromBody] CountryUpsertRequest request)
            => await base.Create(request);

        [Authorize(Roles = "Administrator,SuperAdmin")]
        [HttpPut("{id}")]
        public override async Task<CountryResponse?> Update(int id, [FromBody] CountryUpsertRequest request)
            => await base.Update(id, request);

        [Authorize(Roles = "Administrator,SuperAdmin")]
        [HttpDelete("{id}")]
        public override async Task<bool> Delete(int id)
            => await base.Delete(id);
    }
}
