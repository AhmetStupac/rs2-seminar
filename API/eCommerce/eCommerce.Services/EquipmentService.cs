using eCommerce.Model.Requests;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class EquipmentService : BaseCRUDService
        <EquipmentUpsertRequest, NameSearchObject, Database.Equipment, EquipmentUpsertRequest, EquipmentUpsertRequest>, IEquipmentService
    {
        public EquipmentService(IB210033DbContext context, IMapper mapper)
            : base(context, mapper)
        {
            
        }
    }
}
