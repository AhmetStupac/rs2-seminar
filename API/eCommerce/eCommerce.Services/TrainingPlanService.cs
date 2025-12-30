using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class TrainingPlanService : BaseCRUDService<TrainingPlanResponse, NameSearchObject, Database.TrainingPlan, TrainingPlanUpsertRequest, TrainingPlanUpsertRequest>
        , ITrainingPlanService
    {

        public TrainingPlanService(IB210033DbContext context, IMapper mapper)
            : base(context, mapper)
        {
       
        }


        protected override IQueryable<Database.TrainingPlan> ApplyFilter(IQueryable<Database.TrainingPlan> query, NameSearchObject search)
        {

            var result = query.Include(t=> t.PersonalTrainer).ThenInclude(pt=> pt.User);

            var firstTrainer = result.FirstOrDefault();
            if (firstTrainer?.User == null)
            {
                // User is not being included
            }

            return result;
        }
    }
}
