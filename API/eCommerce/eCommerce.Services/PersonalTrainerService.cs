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

            var result = query.Include(pt=>pt.User);


            var firstTrainer = result.FirstOrDefault();
            if (firstTrainer?.User == null)
            {
                // User is not being included
            }

            return result;
        }
    }
}
