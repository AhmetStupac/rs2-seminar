using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class PersonalTrainerController : BaseCRUDController
        <PersonalTrainerResponse, PersonalTrainerSearchObject, PersonalTrainerUpsertRequest, PersonalTrainerUpsertRequest>
    {
        public PersonalTrainerController(IPersonalTrainerService service) : base(service)
        {
            
        }
    }
}
