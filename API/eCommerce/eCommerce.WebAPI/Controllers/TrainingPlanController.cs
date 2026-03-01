using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class TrainingPlanController : BaseCRUDController
        <TrainingPlanResponse, TrainingPlanSearchObject, TrainingPlanUpsertRequest, TrainingPlanUpsertRequest>
    {
        private readonly ITrainingPlanService _trainingPlanService;

        public TrainingPlanController(ITrainingPlanService service) : base(service)
        {
            _trainingPlanService = service;
        }

        [HttpGet("catalog")]
        public async Task<IActionResult> GetCatalog()
        {
            var result = await _trainingPlanService.GetCatalogAsync();
            return Ok(result);
        }
    }
}
