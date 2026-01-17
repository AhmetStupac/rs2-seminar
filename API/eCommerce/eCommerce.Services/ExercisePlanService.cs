using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services
{
    public class ExercisePlanService : BaseCRUDService<ExercisePlanResponse, ExercisePlanSearchObject, Database.ExercisePlan, ExercisePlanUpsertRequest, ExercisePlanUpsertRequest>, IExercisePlanService
    {
        public ExercisePlanService(IB210033DbContext context, IMapper mapper) : base(context, mapper)
        {
            
        }

        protected override IQueryable<Database.ExercisePlan> ApplyFilter(IQueryable<Database.ExercisePlan> query, ExercisePlanSearchObject search)
        {
            query = query.Include(ep => ep.Exercise)
                .Include(ep => ep.TrainingPlan);

            if (search.TrainingPlanId.HasValue && search.TrainingPlanId.Value > 0)
            {
                query = query.Where(ep => ep.TrainingPlanId == search.TrainingPlanId.Value);
            }

            if (search.ExerciseId.HasValue && search.ExerciseId.Value > 0)
            {
                query = query.Where(ep => ep.ExerciseId == search.ExerciseId.Value);
            }

            return query;
        }

        protected override ExercisePlanResponse MapToResponse(Database.ExercisePlan entity)
        {
            var response = _mapper.Map<ExercisePlanResponse>(entity);
            
            if (response is ExercisePlanResponse exercisePlanResponse)
            {
                if (entity.Exercise != null)
                {
                    exercisePlanResponse.ExerciseName = entity.Exercise.Name;
                }

                if (entity.TrainingPlan != null)
                {
                    exercisePlanResponse.TrainingPlanName = entity.TrainingPlan.Title;
                }
            }
            
            return response;
        }
    }
}