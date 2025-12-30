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
    public class TrainingPlanController : BaseCRUDController
        <TrainingPlanResponse, NameSearchObject, TrainingPlanUpsertRequest, TrainingPlanUpsertRequest>
    {
        public TrainingPlanController(ITrainingPlanService service) : base(service)
        {
            
        }
    }
}
