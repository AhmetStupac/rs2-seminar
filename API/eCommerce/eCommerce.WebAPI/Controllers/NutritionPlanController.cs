using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NutritionPlanController : BaseCRUDController
        <NutritionPlanResponse, NameSearchObject, NutritionPlanUpsertRequest, NutritionPlanUpsertRequest>
    {
        private readonly INutritionPlanService _nutritionPlanService;

        public NutritionPlanController(INutritionPlanService service) : base(service)
        {
            _nutritionPlanService = service;
        }

        [HttpGet("catalog")]
        public async Task<IActionResult> GetCatalog()
        {
            var result = await _nutritionPlanService.GetCatalogAsync();
            return Ok(result);
        }
    }
}
