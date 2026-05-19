using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services
{
    public class CityService : BaseCRUDService<CityResponse, CitySearchObject, City, CityUpsertRequest, CityUpsertRequest>, ICityService
    {
        public CityService(IB210033DbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<City> ApplyFilter(IQueryable<City> query, CitySearchObject search)
        {
            query = query.Include(c => c.Country);

            if (!string.IsNullOrWhiteSpace(search.Name))
                query = query.Where(c => c.Name.Contains(search.Name));

            if (search.CountryId.HasValue)
                query = query.Where(c => c.CountryId == search.CountryId.Value);

            return query;
        }

        protected override CityResponse MapToResponse(City entity)
        {
            var response = _mapper.Map<CityResponse>(entity);
            response.CountryName = entity.Country?.Name ?? string.Empty;
            return response;
        }
    }
}
