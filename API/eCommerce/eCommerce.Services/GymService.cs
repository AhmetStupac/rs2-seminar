using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services
{
    public class GymService : BaseCRUDService<GymResponse, GymSearchObject, Database.Gym, GymUpsertRequest, GymUpsertRequest>, IGymService
    {
        private readonly IValidator<GymUpsertRequest> _validator;

        public GymService(IB210033DbContext context, IMapper mapper, IValidator<GymUpsertRequest> validator) : base(context, mapper)
        {
            _validator = validator;
        }

        protected override IQueryable<Database.Gym> ApplyFilter(IQueryable<Database.Gym> query, GymSearchObject search)
        {
            query = query.Include(g => g.Image);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(g => g.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.City))
            {
                query = query.Where(g => g.City.Contains(search.City));
            }

            if (!string.IsNullOrEmpty(search.Country))
            {
                query = query.Where(g => g.Country.Contains(search.Country));
            }

            return query;
        }

        protected override GymResponse MapToResponse(Database.Gym entity)
        {
            var response = _mapper.Map<GymResponse>(entity);

            if (entity.Image != null)
            {
                response.ImageUrl = entity.Image.Url;
            }

            return response;
        }

        protected override Task BeforeInsert(Database.Gym entity, GymUpsertRequest insertRequest)
        {
            var result = _validator.Validate(insertRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            return Task.CompletedTask;
        }

        protected override Task BeforeUpdate(Database.Gym entity, GymUpsertRequest updateRequest)
        {
            var result = _validator.Validate(updateRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            return Task.CompletedTask;
        }
    }
}
