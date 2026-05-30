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
    public class ExerciseController : BaseCRUDController
        <ExerciseResponse,ExerciseSearchObject , ExerciseUpsertRequest, ExerciseUpsertRequest>
    {

        public ExerciseController(IExerciseService service) : base(service)
        {
            
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpGet]
        public override async Task<PagedResult<ExerciseResponse>> Get([FromQuery] ExerciseSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpGet("{id}")]
        public override async Task<ExerciseResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpPost]
        public override async Task<ExerciseResponse> Create([FromBody] ExerciseUpsertRequest request)
        {
            return await base.Create(request);
        }

        [ServiceFilter(typeof(PersonalTrainerOnlyFilter))]
        [HttpPut("{id}")]
        public override async Task<ExerciseResponse?> Update(int id, [FromBody] ExerciseUpsertRequest request)
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
