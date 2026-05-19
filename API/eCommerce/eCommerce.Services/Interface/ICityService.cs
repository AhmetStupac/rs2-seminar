using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;

namespace eCommerce.Services.Interface
{
    public interface ICityService : ICRUDService<CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest>
    {
    }
}
