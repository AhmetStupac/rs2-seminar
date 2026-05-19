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
        private readonly ICurrentUserService _currentUser;

        public PersonalTrainerController(IPersonalTrainerService service, ICurrentUserService currentUser) : base(service)
        {
            _personalTrainerService = service;
            _currentUser = currentUser;
        }

        [HttpGet("recommend")]
        public async Task<ActionResult<PersonalTrainerResponse>> Recommend()
        {
            if (!_currentUser.UserId.HasValue)
                return Forbid();

            var trainer = await _personalTrainerService.RecommendForUserAsync(_currentUser.UserId.Value);
            if (trainer == null)
                return NotFound();
            return Ok(trainer);
        }
    }
}
