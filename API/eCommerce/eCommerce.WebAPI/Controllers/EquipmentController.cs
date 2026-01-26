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
    public class EquipmentController : BaseCRUDController
        <EquipmentResponse, NameSearchObject, EquipmentUpsertRequest, EquipmentUpsertRequest>
    {
        public EquipmentController(IEquipmentService service) : base(service)
        {
            
        }
    }
}
