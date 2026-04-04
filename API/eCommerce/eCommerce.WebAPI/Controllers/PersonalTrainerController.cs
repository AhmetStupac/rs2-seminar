using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
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

        [HttpGet("recommend")]
        public async Task<ActionResult<PersonalTrainerResponse>> Recommend()
        {
            var userId = GetCurrentUserId();
            if (!userId.HasValue)
                return Forbid();

            var trainer = await _personalTrainerService.RecommendForUserAsync(userId.Value);
            if (trainer == null)
                return NotFound();
            return Ok(trainer);
        }

        private int? GetCurrentUserId()
        {
            var claim = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value
                        ?? User?.FindFirst("nameid")?.Value;

            return int.TryParse(claim, out var userId) ? userId : null;
        }
    }
}
