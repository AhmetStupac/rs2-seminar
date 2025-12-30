using eCommerce.Model.Requests;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Interface;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EquipmentController : BaseCRUDController
        <EquipmentUpsertRequest, NameSearchObject, EquipmentUpsertRequest, EquipmentUpsertRequest>
    {
        public EquipmentController(IEquipmentService service) : base(service)
        {
            
        }
    }
}
