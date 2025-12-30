using eCommerce.Model.Requests;
using eCommerce.Model.SearchObjects;

namespace eCommerce.Services.Interface
{
    public interface IEquipmentService : ICRUDService
        <EquipmentUpsertRequest, NameSearchObject, EquipmentUpsertRequest, EquipmentUpsertRequest>
    {

    }
}
