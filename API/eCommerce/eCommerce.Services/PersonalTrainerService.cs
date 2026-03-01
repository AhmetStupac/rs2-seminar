using EasyNetQ.Internals;
using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace eCommerce.Services
{
    public class PersonalTrainerService : BaseCRUDService<PersonalTrainerResponse, PersonalTrainerSearchObject, PersonalTrainer, PersonalTrainerUpsertRequest, PersonalTrainerUpsertRequest>, IPersonalTrainerService
    {
        private readonly IValidator<PersonalTrainerUpsertRequest> _validator;

        public PersonalTrainerService(IB210033DbContext context, IMapper mapper, IValidator<PersonalTrainerUpsertRequest> validator)
            : base(context, mapper)
        {
            _validator = validator;
        }


        protected override IQueryable<Database.PersonalTrainer> ApplyFilter(IQueryable<Database.PersonalTrainer> query, PersonalTrainerSearchObject search)
        {
            var result = query.Include(pt => pt.User)
                              .Include(pt => pt.Ratings.Where(r => true)); // Load all ratings ignoring filters

            var firstTrainer = result.FirstOrDefault();
            if (firstTrainer?.User == null)
            {
                // User is not being included
            }

            return result;
        }

        protected override PersonalTrainerResponse MapToResponse(PersonalTrainer entity)
        {
            var response = _mapper.Map<PersonalTrainerResponse>(entity);

            // Calculate average rating and total ratings
            if (entity.Ratings != null && entity.Ratings.Any())
            {
                response.AverageRating = Math.Round(entity.Ratings.Average(r => r.Rating), 2);
                response.TotalRatings = entity.Ratings.Count;
            }
            else
            {
                response.AverageRating = 0;
                response.TotalRatings = 0;
            }

            return response;
        }

        protected override async Task BeforeInsert(PersonalTrainer entity, PersonalTrainerUpsertRequest insertRequest)
        {
            var result = _validator.Validate(insertRequest);

            if (!result.IsValid)
            {
                var errors = string.Join(";", result.Errors.Select(e => e.ErrorMessage));
                throw new ArgumentException($"Validation failed: {errors}");
            }

            var alreadyExists = await _context.PersonalTrainers
                .Include(pt => pt.User)
                .AnyAsync(pt => pt.UserId == insertRequest.UserId);

            if (alreadyExists)
            {
                var user = await _context.Users.FindAsync(insertRequest.UserId);
                throw new InvalidOperationException($"A personal trainer with user name '{user?.FirstName}' already exists.");
            }
        }

        protected override Task BeforeUpdate(PersonalTrainer entity, PersonalTrainerUpsertRequest updateRequest)
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
