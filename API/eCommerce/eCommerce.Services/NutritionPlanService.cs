using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services
{
    public class NutritionPlanService : BaseCRUDService<NutritionPlanResponse, NameSearchObject, Database.NutritionPlan, NutritionPlanUpsertRequest, NutritionPlanUpsertRequest>, INutritionPlanService
    {

        public NutritionPlanService(IB210033DbContext context, IMapper mapper)
            : base(context, mapper)
        {
                        
        }


        protected override IQueryable<Database.NutritionPlan> ApplyFilter(IQueryable<Database.NutritionPlan> query, NameSearchObject search)
        {

          return query;
        }
    }
}
