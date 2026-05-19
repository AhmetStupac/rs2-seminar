using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;

namespace eCommerce.Services
{
    public class CountryService : BaseCRUDService<CountryResponse, CountrySearchObject, Country, CountryUpsertRequest, CountryUpsertRequest>, ICountryService
    {
        public CountryService(IB210033DbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Country> ApplyFilter(IQueryable<Country> query, CountrySearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
                query = query.Where(c => c.Name.Contains(search.Name));

            return query;
        }
    }
}
