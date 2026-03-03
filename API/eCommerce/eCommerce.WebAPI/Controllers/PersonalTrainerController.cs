using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class PersonalTrainerController : BaseCRUDController
        <PersonalTrainerResponse, PersonalTrainerSearchObject, PersonalTrainerUpsertRequest, PersonalTrainerUpsertRequest>
    {
        private readonly IPersonalTrainerService _personalTrainerService;

        public PersonalTrainerController(IPersonalTrainerService service) : base(service)
        {
            _personalTrainerService = service;
        }

        [HttpGet("recommend/{userId}")]
        public async Task<ActionResult<PersonalTrainerResponse>> Recommend(int userId)
        {
            var trainer = await _personalTrainerService.RecommendForUserAsync(userId);
            if (trainer == null)
                return NotFound();
            return Ok(trainer);
        }
    }
}
