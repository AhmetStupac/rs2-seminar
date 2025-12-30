using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TrainingController : BaseCRUDController
        <TrainingResponse, NameSearchObject, TrainingUpsertRequest, TrainingUpsertRequest>
    {
        public TrainingController(ITrainingService service) : base(service)
        {
        }
    }
}