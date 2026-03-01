using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
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
    }
}