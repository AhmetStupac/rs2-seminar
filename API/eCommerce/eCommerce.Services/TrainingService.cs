using eCommerce.Model.Requests;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services.Database;
using eCommerce.Services.Interface;
using MapsterMapper;

namespace eCommerce.Services
{
    public class TrainingService : BaseCRUDService
        <TrainingResponse, NameSearchObject, Database.Training, TrainingUpsertRequest, TrainingUpsertRequest>, ITrainingService
    {
        public TrainingService(IB210033DbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Database.Training> ApplyFilter(IQueryable<Database.Training> query, NameSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(t => t.Name.Contains(search.Name));
            }

            return query;
        }


        protected override TrainingResponse MapToResponse(Database.Training entity)
        {
            var response = _mapper.Map<TrainingResponse>(entity);

            // If the response is ExerciseResponse, set the MuscleGroupId and MuscleGroupName
            if (response is TrainingResponse exerciseResponse)
            {
                var firstMuscleGroup = entity.ExerciseMuscleGroups?.FirstOrDefault()?.MuscleGroup;
                if (firstMuscleGroup != null)
                {
                    exerciseResponse.MuscleGroupId = firstMuscleGroup.Id;
                    exerciseResponse.MuscleGroupName = firstMuscleGroup.Name;
                }
            }

            return response;
        }
    }
}