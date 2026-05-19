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
    public class TrainingController : BaseCRUDController
        <TrainingResponse, NameSearchObject, TrainingUpsertRequest, TrainingUpsertRequest>
    {
        public TrainingController(ITrainingService service) : base(service)
        {
        }

        [ServiceFilter(typeof(TrainingOwnershipFilter))]
        [HttpPost]
        public override async Task<TrainingResponse> Create([FromBody] TrainingUpsertRequest request)
        {
            return await base.Create(request);
        }

        [ServiceFilter(typeof(TrainingOwnershipFilter))]
        [HttpPut("{id}")]
        public override async Task<TrainingResponse?> Update(int id, [FromBody] TrainingUpsertRequest request)
        {
            return await base.Update(id, request);
        }

        [ServiceFilter(typeof(TrainingOwnershipFilter))]
        [HttpDelete("{id}")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
}