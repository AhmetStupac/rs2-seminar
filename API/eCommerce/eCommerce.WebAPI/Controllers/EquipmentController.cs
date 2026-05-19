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
    public class EquipmentController : BaseCRUDController
        <EquipmentResponse, NameSearchObject, EquipmentUpsertRequest, EquipmentUpsertRequest>
    {
        public EquipmentController(IEquipmentService service) : base(service)
        {
            
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpPost]
        public override async Task<EquipmentResponse> Create([FromBody] EquipmentUpsertRequest request)
        {
            return await base.Create(request);
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpPut("{id}")]
        public override async Task<EquipmentResponse?> Update(int id, [FromBody] EquipmentUpsertRequest request)
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
