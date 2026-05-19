using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Constants;
using eCommerce.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [Authorize]
    // [Authorize(Roles = "Administrator")]
    public class RoleController : BaseCRUDController<RoleResponse, RoleSearchObject, RoleUpsertRequest, RoleUpsertRequest>
    {
        public RoleController(IRoleService service) : base(service)
        {
        }
        
        [HttpGet]
        public override async Task<PagedResult<RoleResponse>> Get([FromQuery] RoleSearchObject? search = null)
        {
            return await _service.GetAsync(search ?? new RoleSearchObject());
        }
        
        [HttpGet("{id}")]
        public override async Task<RoleResponse?> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpPost]
        public override async Task<RoleResponse> Create([FromBody] RoleUpsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpPut("{id}")]
        public override async Task<RoleResponse?> Update(int id, [FromBody] RoleUpsertRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = Roles.SuperAdmin)]
        [HttpDelete("{id}")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
} 