using EasyNetQ.Internals;
using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services
{
    public class PersonalTrainerService : BaseCRUDService<PersonalTrainerResponse, PersonalTrainerSearchObject, PersonalTrainer, PersonalTrainerUpsertRequest, PersonalTrainerUpsertRequest>, IPersonalTrainerService
    {
        public PersonalTrainerService(IB210033DbContext context, IMapper mapper)
            : base(context, mapper)
        {

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
    }
}
