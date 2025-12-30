using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ExerciseController : BaseCRUDController
        <ExerciseResponse,ExerciseSearchObject , ExerciseUpsertRequest, ExerciseUpsertRequest>
    {

        public ExerciseController(IExerciseService service) : base(service)
        {
            
        }

    }
}
