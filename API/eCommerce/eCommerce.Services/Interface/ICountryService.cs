using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;

namespace eCommerce.Services.Interface
{
    public interface ICountryService : ICRUDService<CountryResponse, CountrySearchObject, CountryUpsertRequest, CountryUpsertRequest>
    {
    }
}
